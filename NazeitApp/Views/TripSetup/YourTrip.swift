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
        let f = DateFormatter()
        f.timeZone = appState.fromTimeZone
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: appState.departureDate)
    }
    
    private var arrivalDateLabel: String {
        let f = DateFormatter()
        f.timeZone = appState.toTimeZone
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: appState.arrivalDate)
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
                    TripField(label: "From", placeholder: "e.g. Jakarta (JKT)", text: $appState.fromCity, tintColor: baseColor)
                        .padding(.horizontal, 24).padding(.bottom, 16)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)
                    
                    // MARK: To
                    TripField(label: "To", placeholder: "e.g. Los Angeles (LAX)", text: $appState.toCity, tintColor: baseColor)
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
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
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
                                }
                                .padding(.horizontal, 16).padding(.vertical, 14)
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
                        HStack(spacing: 8) {
                            if isGeocodingTo || isGeocodingFrom {
                                ProgressView().tint(Color.mint).scaleEffect(0.8)
                            } else {
                                Image(systemName: "clock.arrow.2.circlepath").font(.subheadline)
                            }
                            
                            let sign = timezoneShift > 0 ? "+" : ""
                            Text("\(sign)\(timezoneShift) hr time zone shift detected")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color.mint)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color.mint.opacity(0.12), in: Capsule())
                        .padding(.horizontal, 24).padding(.bottom, 24)
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                        .animation(.spring, value: isGeocodingTo)
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
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(
                            isValid
                            ? AnyShapeStyle(LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color(uiColor: .quaternaryLabel))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: isValid ? Color.teal.opacity(0.20) : .clear, radius: 10, y: 5)
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 24).padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                }
            }
        }
        .onTapGesture { hideKeyboard() }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.toCity.isEmpty)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: timezoneShift)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) { appeared = true }
        }
        .task(id: appState.fromCity) {
            guard !appState.fromCity.isEmpty else { appState.fromTimeZone = .current; return }
            isGeocodingFrom = true
            do {
                try await Task.sleep(nanoseconds: 1_200_000_000)
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
                try await Task.sleep(nanoseconds: 1_200_000_000)
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

private struct TripField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let tintColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.footnote).fontWeight(.semibold)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .padding(.horizontal, 4)
            
            TextField(placeholder, text: $text)
                .font(.body)
                .foregroundStyle(Color(uiColor: .label))
                .padding(.horizontal, 16).padding(.vertical, 14)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(text.isEmpty ? Color(uiColor: .quaternaryLabel) : tintColor.opacity(0.6), lineWidth: text.isEmpty ? 0.5 : 1.5)
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .animation(.spring(response: 0.3), value: text.isEmpty)
        }
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
