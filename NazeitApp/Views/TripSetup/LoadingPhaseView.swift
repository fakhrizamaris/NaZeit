//
//  LoadingPhaseView.swift
//  NazeitApp
//
//  Displays the Pre-Flight Loading Phase — now driven by tripPlan from PlanBuilder.
//

import SwiftUI

struct LoadingPhaseView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigatetoDashboard: Bool = false
    /// P3.1 (§2.A0): Detect timezone anchor changes
    @State private var showTimezoneAlert: Bool = false

    /// Dynamically read from tripPlan. Falls back to empty if no plan exists.
    private var days: [DailyProtocol] {
        appState.tripPlan?.loadingPhase ?? []
    }

    private var dayCount: Int { max(days.count, 1) }

    /// Offsets for DayProgressTracker (days before departure)
    private var offsets: [Int] {
        guard !days.isEmpty else { return [1] }
        return days.map { days.count - $0.dayIndex }
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    private func dateString(for offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: appState.departureDate) ?? Date()
        return Self.dayFormatter.string(from: date)
    }

    /// Current day's protocol, safely bounded
    private var currentDay: DailyProtocol? {
        guard !days.isEmpty, appState.loadingPhaseDayIndex < days.count else { return nil }
        return days[appState.loadingPhaseDayIndex]
    }

    /// Sleep target string from the plan
    private var sleepTargetString: String {
        guard let day = currentDay else { return "--:-- - --:--" }
        return "\(PlanBuilder.time(day.sleepWindow.bedtime)) - \(PlanBuilder.time(day.sleepWindow.wakeTime))"
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(uiColor: .secondarySystemBackground), Color(uiColor: .systemBackground)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.nazeitTeal.opacity(0.12))
                .frame(maxWidth: 400)
                .blur(radius: 120)
                .offset(x: -80, y: -200)

            if days.isEmpty {
                // MARK: No Prep Days — Skip to In-Flight
                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "airplane.departure")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.nazeitTeal)

                    VStack(spacing: 8) {
                        Text("No Pre-flight Prep Needed")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(Color(uiColor: .label))

                        Text("Your departure is too soon for a loading phase. Don't worry — your in-flight and recovery protocols are ready to guide you.")
                            .font(.subheadline)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    if let plan = appState.tripPlan {
                        VStack(spacing: 6) {
                            HStack(spacing: 4) {
                                Image(systemName: plan.direction == .eastward ? "sunrise.fill" : "sunset.fill")
                                    .foregroundStyle(.orange)
                                Text("\(plan.direction == .eastward ? "Eastward" : "Westward") • \(plan.totalGapHours, specifier: "%.0f")h gap")
                            }
                            .font(.subheadline.weight(.semibold))

                            Text("Est. \(plan.estimatedRecoveryDays) recovery days at destination")
                                .font(.caption)
                                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .padding(.horizontal, 32)
                    }

                    Spacer()

                    Button {
                        navigatetoDashboard = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue to In-Flight")
                            Image(systemName: "arrow.right")
                        }
                        .appPrimaryCTAStyle(isEnabled: true)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            } else {
                // MARK: Normal Loading Phase
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {

                            VStack(spacing: 6) {
                                Text("Pre-flight Loading Phase")
                                    .font(.system(.title2, design: .rounded).weight(.bold))
                                    .foregroundStyle(Color(uiColor: .label))

                                Text("Your circadian adjustment has started. Follow this schedule to minimize fast cognition shock upon arrival.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 8)

                            DayProgressTracker(offsets: offsets, dateProvider: dateString, selectedIndex: appState.loadingPhaseDayIndex, activeColor: Color.nazeitTeal)
                                .padding(.horizontal, 24)

                            VStack(spacing: 24) {
                                HeroSleepTargetView(
                                    title: "Tonight's Sleep Target",
                                    timeRange: sleepTargetString,
                                    shiftLabel: currentDay?.shiftLabel ?? "—",
                                    color: Color.nazeitTeal
                                )
                                .padding(.horizontal, 24)

                                VStack(alignment: .leading, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(alignment: .center) {
                                            Text("Daily Protocol")
                                                .font(.system(.title3, design: .rounded).weight(.bold))
                                                .foregroundStyle(Color(uiColor: .label))

                                            Spacer()

                                            CurrentTimeBadge(title: "Now", timeZone: appState.fromTimeZone, accentColor: Color.nazeitTeal, isProminent: true)
                                        }

                                        Text("Complete these tasks to begin syncing your circadian rhythm even before your flight.")
                                            .font(.subheadline)
                                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    }
                                    .padding(.horizontal, 32)

                                    // Dynamic protocol cards from the plan
                                    VStack(spacing: 12) {
                                        if appState.isRestDayActive {
                                            // Rest Day UI
                                            VStack(spacing: 16) {
                                                Image(systemName: "powersleep")
                                                    .font(.system(size: 48))
                                                    .foregroundStyle(Color.nazeitTeal)
                                                
                                                Text("Rest Mode Active")
                                                    .font(.title2.weight(.bold))
                                                    .foregroundStyle(Color(uiColor: .label))
                                                
                                                Text("You've chosen to rest today. Take it easy and let your body recover without circadian pressure. You can resume tomorrow.")
                                                    .font(.body)
                                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 24)
                                            }
                                            .padding(.vertical, 32)
                                            .frame(maxWidth: .infinity)
                                            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))
                                        } else if let day = currentDay {
                                            ForEach(day.instructions) { instruction in
                                                ProtocolCard(
                                                    time: PlanBuilder.time(instruction.scheduledTime),
                                                    icon: instruction.iconName,
                                                    title: instruction.title,
                                                    detail: instruction.detail,
                                                    reasoning: instruction.reasoning,
                                                    accentColor: Color(instruction.accentColorName)
                                                )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                            .id(appState.loadingPhaseDayIndex)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))

                            // MARK: Safety Override (§5.3/§6.2)
                            if appState.inputMethod == .manual && !appState.isRestDayActive {
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        appState.skipTodayAdaptation()
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "battery.25percent")
                                        Text("I'm too tired today")
                                    }
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                                .padding(.top, 4)
                            }

                            Spacer(minLength: 24)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.clear.frame(height: 20)
                    }

                    // MARK: Bottom Navigation
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if appState.loadingPhaseDayIndex > 0 { 
                                    appState.loadingPhaseDayIndex -= 1 
                                    appState.isRestDayActive = false
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.headline)
                                .foregroundStyle(appState.loadingPhaseDayIndex > 0 ? Color.nazeitTeal : Color(uiColor: .tertiaryLabel))
                                .frame(width: 56, height: 56)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                                .shadow(color: Color.black.opacity(appState.loadingPhaseDayIndex > 0 ? 0.05 : 0), radius: 8, y: 4)
                        }
                        .disabled(appState.loadingPhaseDayIndex == 0)

                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if appState.loadingPhaseDayIndex < dayCount - 1 {
                                    appState.loadingPhaseDayIndex += 1
                                    appState.isRestDayActive = false
                                    // §4.1: Completing a day without deviation resets recalcCount
                                    appState.completeSuccessfulDay()
                                } else {
                                    navigatetoDashboard = true
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(appState.loadingPhaseDayIndex == dayCount - 1 ? "Commit to Plan" : "Next Day")
                                if appState.loadingPhaseDayIndex < dayCount - 1 {
                                    Image(systemName: "arrow.right")
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .font(.headline)
                            .foregroundStyle(appState.loadingPhaseDayIndex == dayCount - 1 ? .white : Color.nazeitTeal)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(appState.loadingPhaseDayIndex == dayCount - 1 ? Color.nazeitTeal : Color.nazeitTeal.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 100, style: .continuous)
                                    .stroke(
                                        appState.loadingPhaseDayIndex == dayCount - 1
                                        ? Color.clear
                                        : Color.nazeitTeal.opacity(0.35),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                            .animation(.spring(response: 0.32, dampingFraction: 0.82), value: appState.loadingPhaseDayIndex)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .background(
                        LinearGradient(
                            stops: [
                                .init(color: Color(uiColor: .systemBackground).opacity(0), location: 0),
                                .init(color: Color(uiColor: .systemBackground), location: 0.2)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigatetoDashboard) {
            AdaptationProgressView()
                .environmentObject(appState)
                .onAppear { appState.transitionPhase(to: .inflight) }
        }
        // P3.1 (§2.A0): Timezone anchor override detection
        .onAppear {
            let deviceTZ = TimeZone.current
            if deviceTZ.identifier != appState.fromTimeZone.identifier {
                showTimezoneAlert = true
            }
        }
        .alert("Timezone Changed", isPresented: $showTimezoneAlert) {
            Button("Update Schedule") {
                appState.fromTimeZone = .current
                appState.generatePlan()
            }
            Button("Keep Current", role: .cancel) { }
        } message: {
            Text("You're now in \(TimeZone.current.localizedName(for: .shortGeneric, locale: .current) ?? TimeZone.current.identifier). Update your loading phase schedule to match?")
        }
    }
}

// MARK: - Color from String Helper
extension Color {
    init(_ name: String) {
        switch name {
        case "orange": self = .orange
        case "indigo": self = .indigo
        case "cyan": self = .cyan
        case "teal": self = .teal
        default: self = .primary
        }
    }
}


#Preview {
    LoadingPhaseView().environmentObject(AppState())
}
