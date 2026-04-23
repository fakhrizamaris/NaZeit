//
//  LocationSearchService.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 20/04/26.
//

import Foundation
import Combine
import MapKit

struct TripLocationSuggestion: Hashable, Identifiable {
    let cityName: String
    let subtitle: String
    let airportCode: String?

    var id: String {
        "\(cityName)|\(subtitle)|\(airportCode ?? "")"
    }

    var displayTitle: String {
        guard let code = airportCode, !code.isEmpty else { return cityName }
        return "\(cityName) (\(code))"
    }

    var queryValue: String {
        cityName
    }
}

final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    private var completer: MKLocalSearchCompleter
    
    @Published var searchResults: [TripLocationSuggestion] = []

    private let blockedVenueTerms: [String] = [
        "hotel", "resort", "golf", "club", "mall", "hospital", "restaurant",
        "cafe", "café", "school", "university", "station", "terminal", "port",
        "beach", "park", "museum", "view", "apartment", "tower", "plaza"
    ]

    private let cityAirportSeed: [String: (code: String, subtitleHints: [String])] = [
        "batam": ("BTH", ["riau islands"]),
        "jakarta": ("CGK", ["jakarta"]),
        "denpasar": ("DPS", ["bali"]),
        "surabaya": ("SUB", ["east java"]),
        "medan": ("KNO", ["north sumatra"]),
        "yogyakarta": ("YIA", ["yogyakarta"]),
        "singapore": ("SIN", []),
        "kuala lumpur": ("KUL", []),
        "bangkok": ("BKK", []),
        "tokyo": ("HND", []),
        "osaka": ("KIX", []),
        "seoul": ("ICN", []),
        "hong kong": ("HKG", []),
        "dubai": ("DXB", []),
        "doha": ("DOH", []),
        "london": ("LHR", []),
        "paris": ("CDG", []),
        "amsterdam": ("AMS", []),
        "frankfurt": ("FRA", []),
        "new york": ("JFK", []),
        "los angeles": ("LAX", []),
        "san francisco": ("SFO", []),
        "sydney": ("SYD", []),
        "melbourne": ("MEL", [])
    ]
    
    @Published var searchQuery = "" {
        didSet {
            self.completer.queryFragment = self.searchQuery
            
            if searchQuery.isEmpty {
                searchResults.removeAll()
            }
        }
    }
    
    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        // Address + query memberi hasil geografi, lalu kita filter agar fokus kota/area administratif.
        completer.resultTypes = [.address, .query]
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let normalizedQuery = normalized(searchQuery)

        let filteredResults = completer.results
            .filter { isLikelyAdministrativeResult($0) }
            .map { completion in
                TripLocationSuggestion(
                    cityName: completion.title,
                    subtitle: completion.subtitle,
                    airportCode: airportCode(for: completion)
                )
            }
            .filter { $0.airportCode != nil }
            .sorted { lhs, rhs in
                let lhsTitle = normalized(lhs.cityName)
                let rhsTitle = normalized(rhs.cityName)
                let lhsStarts = lhsTitle.hasPrefix(normalizedQuery)
                let rhsStarts = rhsTitle.hasPrefix(normalizedQuery)

                if lhsStarts != rhsStarts {
                    return lhsStarts && !rhsStarts
                }
                return lhs.cityName.count < rhs.cityName.count
            }

        var uniqueResults: [TripLocationSuggestion] = []
        var seenDisplayTitles = Set<String>()

        for result in filteredResults {
            if seenDisplayTitles.insert(result.displayTitle).inserted {
                uniqueResults.append(result)
            }
            if uniqueResults.count == 8 {
                break
            }
        }

        DispatchQueue.main.async {
            self.searchResults = uniqueResults
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        DispatchQueue.main.async {
            self.searchResults = []
        }
    }

    private func isLikelyAdministrativeResult(_ result: MKLocalSearchCompletion) -> Bool {
        let title = normalized(result.title)
        let subtitle = normalized(result.subtitle)

        if title.isEmpty { return false }
        if containsVenueTerm(in: title) || containsVenueTerm(in: subtitle) { return false }

        // Hindari alamat jalan bernomor yang bukan level kota/region.
        if title.rangeOfCharacter(from: .decimalDigits) != nil { return false }

        let streetHints = [" street", " st", " road", " rd", " avenue", " ave", " no.", "blok"]
        if streetHints.contains(where: { title.contains($0) }) { return false }

        // Biasanya area administratif punya subtitle region/country.
        let hasRegionalSubtitle = !subtitle.isEmpty && (subtitle.contains(",") || subtitle.contains("province") || subtitle.contains("regency"))

        // Tetap izinkan nama kota sederhana yang tidak punya subtitle panjang.
        let wordCount = title.split(separator: " ").count
        return hasRegionalSubtitle || wordCount <= 3
    }

    private func containsVenueTerm(in value: String) -> Bool {
        blockedVenueTerms.contains(where: { value.contains($0) })
    }

    private func normalized(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func airportCode(for completion: MKLocalSearchCompletion) -> String? {
        if let extracted = extractAirportCode(from: completion.title) ?? extractAirportCode(from: completion.subtitle) {
            return extracted
        }

        let key = normalized(completion.title)
        guard let seed = cityAirportSeed[key] else { return nil }
        if seed.subtitleHints.isEmpty { return seed.code }

        let subtitle = normalized(completion.subtitle)
        if seed.subtitleHints.contains(where: { subtitle.contains($0) }) {
            return seed.code
        }
        return nil
    }

    private func extractAirportCode(from value: String) -> String? {
        let pattern = "\\b[A-Z]{3}\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsValue = value as NSString
        let range = NSRange(location: 0, length: nsValue.length)
        guard let match = regex.firstMatch(in: value, options: [], range: range) else { return nil }
        return nsValue.substring(with: match.range)
    }
    
}

    
    
