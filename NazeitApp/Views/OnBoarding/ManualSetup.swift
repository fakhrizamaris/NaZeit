//
//  ManualSetup.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 14/04/26.
//

//  ManualSetup.swift — KamBing
//  Screen 1B: Path Manual — user input sleep schedule & health info sendiri.
//  HiFi: dark gradient, time pickers, slider untuk sleep hours.

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

    private var panelBackground: Color { Color(uiColor: .secondarySystemBackground) }

    private var primaryText: Color { Color(uiColor: .label) }

    private var secondaryText: Color { Color(uiColor: .secondaryLabel) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: .bgOnboarding),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    Text("Langkah 2 dari 3")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(secondaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(panelBackground, in: Capsule())
                        .padding(.horizontal, 28)
                        .padding(.top, 10)
                        .padding(.bottom, 14)
                        .opacity(appeared ? 1 : 0)

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(Color(uiColor: .adaptOrange))
                            .padding(.bottom, 4)
                        Text("Manual setup")
                            .font(.title2).fontWeight(.bold).foregroundStyle(primaryText)
                        Text("Isi jadwal tidur harian Anda agar instruksi adaptasi lebih akurat.")
                            .font(.subheadline).foregroundStyle(secondaryText)
                    }
                    .padding(.horizontal, 28).padding(.top, 24).padding(.bottom, 32)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: Bedtime Picker — Pickers
                    // DatePicker dengan displayedComponents: .hourAndMinute dipakai
                    // bukan TextField karena waktu butuh format yang tepat dan
                    // user tidak perlu mengetik jam secara manual.
                    SectionCard(title: "Usual bedtime", icon: "moon.fill", iconColor: Color(red:0.55,green:0.4,blue:0.95)) {
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
                    .padding(.horizontal, 24).padding(.bottom, 14)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: Wake Time Picker
                    SectionCard(title: "Usual wake time", icon: "sun.horizon.fill", iconColor: Color.bgMorning) {
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
                    .padding(.horizontal, 24).padding(.bottom, 14)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: Sleep Hours — calculated display
                    // Label informatif hasil kalkulasi otomatis dari dua picker di atas.
                    // Tidak perlu input terpisah — derived dari bedtime + waketime.
                    SectionCard(title: "Calculated sleep", icon: "clock.fill", iconColor: .circadianTeal) {
                        HStack {
                            Text(String(format: "%.1f hours", sleepDuration))
                                .font(.title3).fontWeight(.semibold).foregroundStyle(primaryText)
                            Spacer()
                            // Visual quality indicator
                            let qualityColor: Color = sleepDuration >= 7
                                ? Color.circadianTeal
                                : (sleepDuration >= 6 ? Color.adaptOrange : Color.red.opacity(0.8))

                            Text(sleepDuration >= 7 ? "Good" : sleepDuration >= 6 ? "Fair" : "Low")
                                .font(.caption).fontWeight(.medium)
                                .foregroundStyle(qualityColor)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(qualityColor.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 20)

                    // MARK: CTA — Continue to trip setup
                    NavigationLink {
                        YourTrip().environmentObject(appState)
                    } label: {
                        PrimaryBtn(title: "Continue to trip setup →",
                                   color: Color(red:0.6,green:0.4,blue:1.0))
                    }
                    .padding(.horizontal, 24).padding(.bottom, 48)
                    .opacity(appeared ? 1 : 0)
                }
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
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
