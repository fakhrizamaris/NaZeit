import SwiftUI
import MapKit

struct YourTrip: View {
    @EnvironmentObject var appState: AppState
    @State private var showDatePicker = false
    @State private var showArrivalDatePicker = false
    @State private var appeared       = false
    
    @State private var isGeocodingTo   = false
    @State private var isGeocodingFrom = false
    
    private var isValid: Bool { !appState.fromCity.isEmpty && !appState.toCity.isEmpty }
    private var dateLabel: String {
        var format = Date.FormatStyle.dateTime.year().month(.abbreviated).day().hour().minute()
        format.timeZone = appState.fromTimeZone
        return appState.departureDate.formatted(format)
    }
    
    private var arrivalDateLabel: String {
        var format = Date.FormatStyle.dateTime.year().month(.abbreviated).day().hour().minute()
        format.timeZone = appState.toTimeZone
        return appState.arrivalDate.formatted(format)
    }
    
    private var timezoneShift: Int {
        let fromSeconds = appState.fromTimeZone.secondsFromGMT(for: appState.departureDate)
        let toSeconds = appState.toTimeZone.secondsFromGMT(for: appState.arrivalDate)
        return (toSeconds - fromSeconds) / 3600
    }
    
    private var baseColor: Color { Color(uiColor: .nazeitTeal) }
    
    var body: some View {
        ZStack {
            OnboardingChoiceBackgroundView(glowAnimated: false)
                .onTapGesture { hideKeyboard() }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack {
                        Spacer()
                        StepIndicatorView(step: 3, totalSteps: 3)
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
                    SearchableTripField(label: "From (City Name)", placeholder: "e.g. Batam", text: $appState.fromCity, tintColor: baseColor)
                        .padding(.horizontal, 24).padding(.bottom, 16)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    // MARK: To
                    SearchableTripField(label: "To (City Name)", placeholder: "e.g. Los Angeles", text: $appState.toCity, tintColor: baseColor)
                        .padding(.horizontal, 24).padding(.bottom, 16)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    // MARK: Departure
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Departure Date & Time")
                            .font(.footnote).fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .label))
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
                            .foregroundStyle(Color(uiColor: .label))
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
                    
                    // MARK: Transit Option
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $appState.hasTransit.animation(.spring(response: 0.4))) {
                            Text("Add Transit / Layover")
                                .font(.footnote).fontWeight(.semibold)
                                .foregroundStyle(Color(uiColor: .label))
                        }
                        .tint(baseColor)
                        .padding(.horizontal, 28)
                        
                        if appState.hasTransit {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "building.2").font(.title3).foregroundStyle(Color.mint)
                                        .frame(width: 32)
                                    TextField("Transit City (e.g. Dubai)", text: $appState.transitCity)
                                        .font(.body)
                                        .foregroundStyle(Color(uiColor: .label))
                                        .frame(minHeight: 52)
                                }
                                .padding(.horizontal, 16)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                                
                                HStack {
                                    Image(systemName: "hourglass").font(.title3).foregroundStyle(Color.mint)
                                        .frame(width: 32)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Layover")
                                            .font(.body).foregroundStyle(Color(uiColor: .label))
                                        Text("\(appState.layoverDuration) hours")
                                            .font(.footnote.weight(.medium)).foregroundStyle(Color(uiColor: .secondaryLabel))
                                    }
                                    Spacer()
                                    Stepper("", value: $appState.layoverDuration, in: 1...24)
                                        .labelsHidden()
                                        .accessibilityLabel("Layover duration")
                                        .accessibilityValue("\(appState.layoverDuration) hours")
                                }
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    if timezoneShift != 0 && !appState.toCity.isEmpty {
                        HStack(spacing: 16) {
                            if isGeocodingTo || isGeocodingFrom {
                                ProgressView().tint(baseColor).scaleEffect(0.9)
                            } else {
                                Image(systemName: "globe.americas.fill")
                                    .font(.title2)
                                    .foregroundStyle(baseColor)
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
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(baseColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(baseColor.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 24).padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isGeocodingTo)
                    }
                    
                    if isValid {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundStyle(baseColor)
                            Text("We'll guide you with \(appState.inputMethod == .watch ? "live watch data" : "your sleep schedule") across the \(abs(timezoneShift))-hour shift.")
                                .font(.footnote)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .padding(16)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(baseColor.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 24).padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // MARK: CTA
                    NavigationLink {
                        LoadingPhaseView().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Generate Plan")
                            Image(systemName: "wand.and.stars")
                        }
                        .appPrimaryCTAStyle(isEnabled: isValid)
                    }
                    .disabled(!isValid)
                    .simultaneousGesture(TapGesture().onEnded {
                        appState.generatePlan()
                    })
                    .padding(.horizontal, 24).padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isValid)
                }
            }
        }
        .onTapGesture { hideKeyboard() }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isValid)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) { appeared = true }
        }
        .task(id: appState.fromCity) {
            guard !appState.fromCity.isEmpty else { appState.fromTimeZone = .current; return }
            isGeocodingFrom = true
            do {
                try await Task.sleep(for: .milliseconds(400))
                if let request = MKGeocodingRequest(addressString: appState.fromCity) {
                    let mapItems = try await request.mapItems
                    if let tz = mapItems.first?.timeZone {
                        await MainActor.run { appState.fromTimeZone = tz }
                    }
                }
            } catch {}
            isGeocodingFrom = false
        }
        .task(id: appState.toCity) {
            guard !appState.toCity.isEmpty else { return }
            isGeocodingTo = true
            do {
                try await Task.sleep(for: .milliseconds(400))
                if let request = MKGeocodingRequest(addressString: appState.toCity) {
                    let mapItems = try await request.mapItems
                    if let tz = mapItems.first?.timeZone {
                        await MainActor.run { appState.toTimeZone = tz }
                    }
                }
            } catch {}
            isGeocodingTo = false
        }
    }
}

private struct SearchableTripField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let tintColor: Color
    
 
    @StateObject private var searchService = LocationSearchService()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.footnote).fontWeight(.semibold)
                .foregroundStyle(Color(uiColor: .label))
                .padding(.horizontal, 4)
            
            TextField(placeholder, text: $searchService.searchQuery)
                .focused($isFocused)
                .font(.body)
                .foregroundStyle(Color(uiColor: .label))
                .frame(minHeight: 52)
                .padding(.horizontal, 16)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(searchService.searchQuery.isEmpty ? Color(uiColor: .quaternaryLabel) : tintColor.opacity(0.6), lineWidth: searchService.searchQuery.isEmpty ? 0.5 : 1.5)
                )
                .autocorrectionDisabled()
                .accessibilityLabel(label)
                .accessibilityHint("Enter city name")
                .onChange(of: searchService.searchQuery) { _, newValue in
                    text = geocodingQuery(from: newValue)
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
