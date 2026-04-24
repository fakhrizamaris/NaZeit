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

    var id: String {
        "\(cityName)|\(subtitle)"
    }

    var displayTitle: String { cityName }

    var queryValue: String { cityName }
}

final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {

    private var completer: MKLocalSearchCompleter

    @Published var searchResults: [TripLocationSuggestion] = []

    private let blockedVenueTerms: [String] = [
        "hotel", "resort", "golf", "club", "mall", "hospital", "restaurant",
        "cafe", "café", "school", "university", "station", "terminal", "port",
        "beach", "park", "museum", "view", "apartment", "tower", "plaza"
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
        completer.resultTypes = [.address, .query]
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let normalizedQuery = normalized(searchQuery)

        let filteredResults = completer.results
            .filter { isLikelyAdministrativeResult($0) }
            .map { completion in
                TripLocationSuggestion(
                    cityName: completion.title,
                    subtitle: completion.subtitle
                )
            }
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

        if title.rangeOfCharacter(from: .decimalDigits) != nil { return false }

        let streetHints = [" street", " st", " road", " rd", " avenue", " ave", " no.", "blok"]
        if streetHints.contains(where: { title.contains($0) }) { return false }

        let hasRegionalSubtitle = !subtitle.isEmpty && (subtitle.contains(",") || subtitle.contains("province") || subtitle.contains("regency"))

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
}
