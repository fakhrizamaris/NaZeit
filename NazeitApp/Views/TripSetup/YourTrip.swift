import SwiftUI
import MapKit

struct YourTrip: View {
    @EnvironmentObject var appState: AppState

    @State private var showDatePicker = false
    @State private var showArrivalDatePicker = false
    @State private var appeared       = false
    @State private var localFromCity: String = ""
    @State private var localToCity: String = ""
    @State private var localTransitCity: String = ""
    
    @State private var isGeocodingTo   = false
    @State private var isGeocodingFrom = false

    // MARK: - Timezone Cache
    // Prevents MKGeocodingRequest non-determinism from returning different
    // timezones for the same city name on repeated lookups. Once resolved,
    // the mapping is stable for the lifetime of the app session.
    private static var timezoneCache: [String: TimeZone] = [:]

    private static func cachedTimezone(for city: String) -> TimeZone? {
        timezoneCache[city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)]
    }

    private static func cacheTimezone(_ tz: TimeZone, for city: String) {
        timezoneCache[city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)] = tz
    }

    private static let baseFormat = Date.FormatStyle.dateTime.year().month(.abbreviated).day().hour().minute()
    
    private var isValid: Bool { !appState.fromCity.isEmpty && !appState.toCity.isEmpty }

    private var dateLabel: String {
        var format = Self.baseFormat
        format.timeZone = appState.fromTimeZone
        return appState.departureDate.formatted(format)
    }
    
    private var arrivalDateLabel: String {
        var format = Self.baseFormat
        format.timeZone = appState.toTimeZone
        return appState.arrivalDate.formatted(format)
    }
    
    private var timezoneShift: Int {
        let ref = appState.departureDate
        let fromSeconds = appState.fromTimeZone.secondsFromGMT(for: ref)
        let toSeconds = appState.toTimeZone.secondsFromGMT(for: ref)
        return (toSeconds - fromSeconds) / 3600
    }
    

    
    var body: some View {
        ZStack {
            OnboardingChoiceBackgroundView(glowAnimated: false)
                .onTapGesture { hideKeyboard() }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack {
                        Spacer()
                        StepIndicatorView(step: 2, totalSteps: 2)
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .opacity(appeared ? 1 : 0)
                    
                    // MARK: Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your Trip")
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Color(uiColor: .label))
                            
                            Text("We'll build your adaptation plan from this.")
                                .font(.subheadline)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    // MARK: From
                    SearchableTripField(label: "From (City Name)", placeholder: "e.g. Batam", text: $localFromCity, tintColor: Color.nazeitTeal)
                        .onAppear {
                            localFromCity = appState.fromCity
                        }
                        .onChange(of: appState.fromCity) { _, newValue in
                            if newValue.isEmpty { localFromCity = "" }
                        }
                        .onChange(of: localFromCity) { oldValue, newValue in
                            Task {
                                try? await Task.sleep(for: .seconds(0.5))
                                appState.fromCity = newValue
                            }
                        }
                        .padding(.horizontal, 24).padding(.bottom, 16)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    // MARK: To
                    SearchableTripField(label: "To (City Name)", placeholder: "e.g. Los Angeles", text: $localToCity, tintColor: Color.nazeitTeal)
                        .onAppear {
                            localToCity = appState.toCity
                        }
                        .onChange(of: appState.toCity) { _, newValue in
                            if newValue.isEmpty { localToCity = "" }
                        }
                        .onChange(of: localToCity) { oldValue, newValue in
                            Task {
                                try? await Task.sleep(for: .seconds(0.5))
                                appState.toCity = newValue
                            }
                        }
                        .padding(.horizontal, 24).padding(.bottom, 16)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    // MARK: Departure
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Departure Date & Time")
                            .font(.footnote).fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.horizontal, 28)
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showDatePicker.toggle() }
                        } label: {
                            HStack {
                                Label {
                                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                                        Text(dateLabel)
                                        if let abbrev = appState.fromTimeZone.abbreviation() {
                                            Text(abbrev)
                                                .font(.caption).fontWeight(.bold)
                                                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                                        }
                                    }
                                } icon: {
                                    Image(systemName: "airplane.departure")
                                        .foregroundStyle(Color(.nazeitTeal))
                                }
                                .font(.body)
                                .foregroundStyle(Color(uiColor: .label))
                                Spacer()
                                Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                    .font(.footnote).foregroundStyle(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.horizontal, 16).padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        if showDatePicker {
                            DatePicker("", selection: $appState.departureDate,
                                       in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.wheel).labelsHidden()
                            .environment(\.timeZone, appState.fromTimeZone)
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    // MARK: Arrival
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Arrival Date & Time (Local)")
                            .font(.footnote).fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.horizontal, 28)
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showArrivalDatePicker.toggle() }
                        } label: {
                            HStack {
                                Label {
                                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                                        Text(arrivalDateLabel)
                                        if let abbrev = appState.toTimeZone.abbreviation() {
                                            Text(abbrev)
                                                .font(.caption).fontWeight(.bold)
                                                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                                        }
                                    }
                                } icon: {
                                    Image(systemName: "airplane.arrival")
                                        .foregroundStyle(Color(.nazeitTeal))
                                }
                                .font(.body)
                                .foregroundStyle(Color(uiColor: .label))
                                Spacer()
                                Image(systemName: showArrivalDatePicker ? "chevron.up" : "chevron.down")
                                    .font(.footnote).foregroundStyle(Color(uiColor: .secondaryLabel))
                            }
                            .padding(.horizontal, 16).padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        if showArrivalDatePicker {
                            DatePicker("", selection: $appState.arrivalDate,
                                       in: appState.departureDate..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.wheel).labelsHidden()
                            .environment(\.timeZone, appState.toTimeZone)
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    

                    
                    if timezoneShift != 0 && !appState.toCity.isEmpty {
                        HStack(spacing: 16) {
                            if isGeocodingTo || isGeocodingFrom {
                                ProgressView().tint(Color.nazeitTeal).scaleEffect(0.9)
                            } else {
                                Image(systemName: "globe.americas.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.nazeitTeal)
                                    .symbolEffect(.bounce, value: timezoneShift)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Time Zone Shift")
                                    .font(.caption2).fontWeight(.bold)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .textCase(.uppercase)
                                
                                let sign = timezoneShift > 0 ? "+" : ""
                                Text("\(sign)\(timezoneShift) Hours Difference")
                                    .font(.headline)
                                    .foregroundStyle(Color(uiColor: .label))
                                
                                let fromAbbr = appState.fromTimeZone.abbreviation() ?? "?"
                                let toAbbr = appState.toTimeZone.abbreviation() ?? "?"
                                Text("\(fromAbbr) → \(toAbbr)")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.nazeitTeal.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.nazeitTeal.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 24).padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isGeocodingTo)
                    }
                    
                    if isValid {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundStyle(Color.nazeitTeal)
                            Text("We'll guide you with \(appState.inputMethod == .watch ? "live watch data" : "your sleep schedule") across the \(abs(timezoneShift))-hour shift.")
                                .font(.footnote)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(16)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.nazeitTeal.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 24).padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // MARK: CTA
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            appState.generatePlan()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Generate Plan")
                            Image(systemName: "wand.and.stars")
                        }
                        .appPrimaryCTAStyle(isEnabled: isValid)
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 24).padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isValid)
                }
            }
        }
        .onTapGesture { hideKeyboard() }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) { appeared = true }
        }
        .task(id: appState.fromCity) {
            let currentCity = appState.fromCity
            guard !currentCity.isEmpty else { appState.fromTimeZone = .current; return }
            
            // Cache hit → use immediately, skip network call
            if let cached = Self.cachedTimezone(for: currentCity) {
                appState.fromTimeZone = cached
                return
            }
            
            isGeocodingFrom = true
            do {
                try await Task.sleep(for: .milliseconds(400))
                try Task.checkCancellation() // IMPORTANT: Prevents lagging requests from overwriting newer ones
                
                if let request = MKGeocodingRequest(addressString: currentCity) {
                    let mapItems = try await request.mapItems
                    try Task.checkCancellation()
                    
                    if let tz = mapItems.first?.timeZone {
                        print("[Nazeit] Geocoded FROM '\(currentCity)' → \(tz.identifier) (UTC\(tz.secondsFromGMT()/3600 >= 0 ? "+" : "")\(tz.secondsFromGMT()/3600))")
                        Self.cacheTimezone(tz, for: currentCity)
                        await MainActor.run { appState.fromTimeZone = tz }
                    }
                }
            } catch {}
            isGeocodingFrom = false
        }
        .task(id: appState.toCity) {
            let currentCity = appState.toCity
            guard !currentCity.isEmpty else { return }
            
            // Cache hit → use immediately, skip network call
            if let cached = Self.cachedTimezone(for: currentCity) {
                appState.toTimeZone = cached
                return
            }
            
            isGeocodingTo = true
            do {
                try await Task.sleep(for: .milliseconds(400))
                try Task.checkCancellation() // IMPORTANT: Prevents lagging requests from overwriting newer ones
                
                if let request = MKGeocodingRequest(addressString: currentCity) {
                    let mapItems = try await request.mapItems
                    try Task.checkCancellation()
                    
                    if let tz = mapItems.first?.timeZone {
                        print("[Nazeit] Geocoded TO '\(currentCity)' → \(tz.identifier) (UTC\(tz.secondsFromGMT()/3600 >= 0 ? "+" : "")\(tz.secondsFromGMT()/3600))")
                        Self.cacheTimezone(tz, for: currentCity)
                        await MainActor.run { appState.toTimeZone = tz }
                    }
                }
            } catch {}
            isGeocodingTo = false
        }
        .task(id: appState.transitCity) {
            let currentCity = appState.transitCity
            guard !currentCity.isEmpty && appState.hasTransit else { return }
            
            // Cache hit → use immediately, skip network call
            if let cached = Self.cachedTimezone(for: currentCity) {
                appState.transitTimeZone = cached
                return
            }
            
            do {
                try await Task.sleep(for: .milliseconds(400))
                try Task.checkCancellation() // IMPORTANT: Prevents lagging requests from overwriting newer ones
                
                if let request = MKGeocodingRequest(addressString: currentCity) {
                    let mapItems = try await request.mapItems
                    try Task.checkCancellation()
                    
                    if let tz = mapItems.first?.timeZone {
                        Self.cacheTimezone(tz, for: currentCity)
                        await MainActor.run { appState.transitTimeZone = tz }
                    }
                }
            } catch {}
        }
    }
}

private struct SearchableTripField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let tintColor: Color
    var icon: String? = nil
    
 
    @StateObject private var searchService = LocationSearchService()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !label.isEmpty {
                Text(label)
                    .font(.footnote).fontWeight(.semibold)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding(.horizontal, 4)
            }
            
            HStack(spacing: 0) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(tintColor)
                        .frame(width: 32)
                        .padding(.leading, 12)
                }
                
                TextField(placeholder, text: $searchService.searchQuery)
                    .focused($isFocused)
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .label))
                    .frame(minHeight: 52)
                    .padding(.horizontal, icon == nil ? 16 : 8)
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(searchService.searchQuery.isEmpty ? Color(uiColor: .quaternaryLabel) : tintColor.opacity(0.6), lineWidth: searchService.searchQuery.isEmpty ? 0.5 : 1.5)
            )
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
                .accessibilityLabel(label)
                .accessibilityHint("Enter city name")
                .onChange(of: searchService.searchQuery) { _, newValue in
                    text = geocodingQuery(from: newValue)
                }
                .onChange(of: text) { _, newValue in
                    if newValue.isEmpty && !searchService.searchQuery.isEmpty {
                        searchService.searchQuery = ""
                    }
                }
                .onAppear {
                    searchService.searchQuery = text
                }
            
            if isFocused && !searchService.searchQuery.isEmpty && !searchService.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(searchService.searchResults) { result in
                        Button {
                            searchService.searchQuery = result.displayTitle
                            text = result.queryValue
                            isFocused = false
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.displayTitle)
                                    .font(.body)
                                    .foregroundStyle(Color(uiColor: .label))
                                if !result.subtitle.isEmpty {
                                    Text(result.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        if result.id != searchService.searchResults.last?.id {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                .padding(.top, 4)
                .shadow(color: Color.black.opacity(0.12), radius: 15, y: 8)
                .transition(.scale(scale: 0.98, anchor: .top).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.3), value: searchService.searchQuery.isEmpty)
        .animation(.snappy, value: isFocused)
    }

    private func geocodingQuery(from value: String) -> String {
        value
            .replacingOccurrences(of: "\\s*\\([A-Z]{3}\\)$", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


#Preview {
    NavigationStack { YourTrip().environmentObject(AppState()) }
}

// MARK: - Keyboard Dismissal Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
