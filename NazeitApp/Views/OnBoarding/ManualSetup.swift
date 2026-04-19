//
//  ManualSetup.swift
//  KamBing
//

import SwiftUI

struct ManualSetup: View {
    @EnvironmentObject var appState: AppState
    @State private var showBedtimePicker  = false
    @State private var showWakePicker     = false
    @State private var appeared           = false

    private var sleepDuration: Double {
        let wake = appState.preferredWakeTime.timeIntervalSinceReferenceDate
        var bed  = appState.preferredBedtime.timeIntervalSinceReferenceDate
        if wake < bed { bed -= 86400 }
        let diff = (wake - bed) / 3600
        return max(0, min(12, diff))
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }

    var body: some View {
        ZStack {
            // [Background Hierarchy]
            OnboardingChoiceBackgroundView(glowAnimated: false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // [Navigation Context]
                    HStack {
                        Spacer()
                        StepIndicatorView(step: 2, totalSteps: 3)
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .opacity(appeared ? 1 : 0)

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.largeTitle.weight(.light))
                            .foregroundStyle(Color.indigo)
                            .padding(.bottom, 8)
                            
                        Text("Manual Setup")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(Color(uiColor: .label))
                            
                        Text("Enter your daily sleep schedule so we can provide accurate adaptation instructions.")
                            .font(.body)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                    // MARK: Bedtime Picker
                    SectionCard(title: "Usual Bedtime", icon: "moon.fill", iconColor: .indigo) {
                        Button {
                            withAnimation(.spring(response: 0.4)) { showBedtimePicker.toggle() }
                        } label: {
                            TimeRow(label: timeString(appState.preferredBedtime),
                                    isExpanded: showBedtimePicker)
                        }
                        if showBedtimePicker {
                            DatePicker("", selection: $appState.preferredBedtime,
                                       displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .onChange(of: appState.preferredBedtime) { _, _ in
                                    appState.sleepHours = sleepDuration
                                }
                        }
                    }
                    .padding(.horizontal, 24).padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: Wake Time Picker
                    SectionCard(title: "Usual Wake Time", icon: "sun.horizon.fill", iconColor: Color.cyan) {
                        Button {
                            withAnimation(.spring(response: 0.4)) { showWakePicker.toggle() }
                        } label: {
                            TimeRow(label: timeString(appState.preferredWakeTime),
                                    isExpanded: showWakePicker)
                        }
                        if showWakePicker {
                            DatePicker("", selection: $appState.preferredWakeTime,
                                       displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .transition(.opacity.combined(with: .move(edge: .top)))
                                .onChange(of: appState.preferredWakeTime) { _, _ in
                                    appState.sleepHours = sleepDuration
                                }
                        }
                    }
                    .padding(.horizontal, 24).padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: Sleep Hours — calculated display
                    SectionCard(title: "Calculated Sleep", icon: "clock.fill", iconColor: Color(uiColor: .nazeitTeal)) {
                        HStack {
                            Text(String(format: "%.1f hours", sleepDuration))
                                .font(.title3).fontWeight(.semibold)
                                .foregroundStyle(Color(uiColor: .label))
                                
                            Spacer()
                            
                            let qualityColor: Color = sleepDuration >= 7
                                ? Color(uiColor: .nazeitTeal)
                                : (sleepDuration >= 6 ? Color.mint : Color.cyan.opacity(0.8))

                            Text(sleepDuration >= 7 ? "Good" : sleepDuration >= 6 ? "Fair" : "Low")
                                .font(.caption).fontWeight(.bold)
                                .foregroundStyle(qualityColor)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(qualityColor.opacity(0.15), in: Capsule())
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 40)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: CTA
                    NavigationLink {
                        YourTrip().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue to trip setup")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                                   startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) { appeared = true }
            appState.sleepHours = sleepDuration
        }
    }
}

// MARK: - SectionCard — card container untuk setiap input section
private struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.caption).foregroundStyle(iconColor)
                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            content()
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: .quaternaryLabel).opacity(0.25), lineWidth: 0.5)
        )
    }
}

// MARK: - TimeRow — tap-to-expand row untuk picker
private struct TimeRow: View {
    let label: String
    let isExpanded: Bool

    var body: some View {
        HStack {
            Text(label).font(.body).foregroundStyle(Color(uiColor: .label))
            Spacer()
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.footnote).foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }
}

#Preview {
    NavigationStack { ManualSetup().environmentObject(AppState()) }
}
