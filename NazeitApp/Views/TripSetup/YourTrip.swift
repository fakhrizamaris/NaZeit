//  YourTrip.swift — KamBing
import SwiftUI

struct YourTrip: View {
    @EnvironmentObject var appState: AppState
    @State private var showDatePicker = false
    @State private var showArrivalDatePicker = false
    @State private var appeared       = false

    private var isValid: Bool { !appState.fromCity.isEmpty && !appState.toCity.isEmpty }
    private var dateLabel: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short // Menampilkan Jam juga
        return f.string(from: appState.departureDate)
    }
    
    private var arrivalDateLabel: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: appState.arrivalDate)
    }

    // [Color Harmony]
    private var baseColor: Color { Color(uiColor: .nazeitTeal) }

    var body: some View {
        ZStack {
            // [Background Hierarchy]
            OnboardingChoiceBackgroundView(glowAnimated: false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // [Navigation Context]
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
                                // [Typography Hierarchy]
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Color(uiColor: .label))
                            
                            Text("We'll build your adaptation plan from this.")
                                .font(.subheadline)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                        Spacer()
                        Label(appState.inputMethod == .watch ? "Watch" : "Manual",
                              systemImage: appState.inputMethod == .watch ? "applewatch" : "hand.tap.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(appState.inputMethod == .watch ? baseColor : Color.indigo)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background((appState.inputMethod == .watch ? baseColor : Color.indigo).opacity(0.12), in: Capsule())
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: TextField — From city
                    TripField(label: "From", placeholder: "e.g. Jakarta (JKT)", text: $appState.fromCity, tintColor: baseColor)
                        .padding(.horizontal, 24).padding(.bottom, 16)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: TextField — To city
                    TripField(label: "To", placeholder: "e.g. Los Angeles (LAX)", text: $appState.toCity, tintColor: baseColor)
                        .padding(.horizontal, 24).padding(.bottom, 16)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: DatePicker — Departure date & Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Departure Date & Time")
                            .font(.footnote).fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.horizontal, 28)
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showDatePicker.toggle() }
                        } label: {
                            HStack {
                                Label(dateLabel, systemImage: "airplane.departure")
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

                    // MARK: DatePicker — Arrival date & Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Arrival Date & Time (Local)")
                            .font(.footnote).fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.horizontal, 28)
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showArrivalDatePicker.toggle() }
                        } label: {
                            HStack {
                                Label(arrivalDateLabel, systemImage: "airplane.arrival")
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

                    // MARK: Time zone shift chip
                    if !appState.toCity.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.2.circlepath").font(.subheadline)
                            Text("+15 hr time zone shift detected")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Color.orange.opacity(0.12), in: Capsule())
                        .padding(.horizontal, 24).padding(.bottom, 24)
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }

                    // MARK: Plan summary card
                    if isValid {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundStyle(baseColor)
                            Text("We'll guide you with \(appState.inputMethod == .watch ? "live watch data" : "your sleep schedule") across the 15-hour shift.")
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

                    // MARK: NavigationLink → Loading Phase
                    NavigationLink {
                        // [Routing]: User explicitly requested connecting to LoadingPhaseView 
                        LoadingPhaseView().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Generate Plan")
                            Image(systemName: "wand.and.stars")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(isValid ? baseColor : Color(uiColor: .quaternaryLabel))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: isValid ? baseColor.opacity(0.30) : .clear, radius: 10, y: 5)
                    }
                    .disabled(!isValid)
                    .padding(.horizontal, 24).padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.toCity.isEmpty)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) { appeared = true }
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
