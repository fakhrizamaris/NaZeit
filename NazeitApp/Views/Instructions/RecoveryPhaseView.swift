//
//  RecoveryPhaseView.swift
//  NazeitApp
//
//  Displays the Post-Flight Recovery Phase — driven by tripPlan from PlanBuilder.
//

import SwiftUI

struct RecoveryPhaseView: View {
    @EnvironmentObject var appState: AppState
    @State private var navigatetoDashboard: Bool = false
    @State private var navigateToFullyAdapted: Bool = false

    /// Dynamically read from tripPlan
    private var days: [DailyProtocol] {
        appState.tripPlan?.recoveryPhase ?? []
    }

    private var dayCount: Int { max(days.count, 1) }

    /// Offsets for DayProgressTracker (days after arrival)
    private var offsets: [Int] {
        guard !days.isEmpty else { return [1] }
        return days.map { $0.dayIndex + 1 }
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    private func dateString(for offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: appState.arrivalDate) ?? Date()
        return Self.dayFormatter.string(from: date)
    }

    /// Current day's protocol
    private var currentDay: DailyProtocol? {
        guard !days.isEmpty, appState.recoveryPhaseDayIndex < days.count else { return nil }
        return days[appState.recoveryPhaseDayIndex]
    }

    /// Sleep target string from the plan
    private var sleepTargetString: String {
        guard let day = currentDay else { return "--:-- - --:--" }
        return "\(PlanBuilder.time(day.sleepWindow.bedtime)) - \(PlanBuilder.time(day.sleepWindow.wakeTime))"
    }

    /// Adaptation progress for this phase — builds on top of loading + in-flight credit
    private var currentAdaptation: Double {
        guard dayCount > 0 else { return appState.adaptationPercent }
        let basePercent = appState.adaptationPercent
        let remainingPercent = 1.0 - basePercent
        let recoveryProgress = Double(appState.recoveryPhaseDayIndex + 1) / Double(dayCount)
        return min(1.0, basePercent + remainingPercent * recoveryProgress)
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

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        VStack(spacing: 6) {
                            Text("Post-flight Recovery")
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Color(uiColor: .label))

                            if let plan = appState.tripPlan {
                                Text("You have arrived. \(plan.direction == .eastward ? "Phase Advance" : "Phase Delay") recovery — est. \(plan.estimatedRecoveryDays) days to full sync.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            } else {
                                Text("Follow this protocol to sync your circadian rhythm at your destination.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .padding(.top, 8)

                        DayProgressTracker(offsets: offsets, dateProvider: dateString, selectedIndex: appState.recoveryPhaseDayIndex, activeColor: Color.nazeitTeal, dayLabelPrefix: "Day +")
                            .padding(.horizontal, 24)

                        VStack(spacing: 24) {
                            HeroSleepTargetView(
                                title: "Tonight's Sleep Window",
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

                                        CurrentTimeBadge(title: "Now", timeZone: appState.toTimeZone, accentColor: Color.nazeitTeal, isProminent: true)
                                    }

                                    Text("Strict adherence to these daily tasks will rapidly clear your sleep debt and adjust your body clock.")
                                        .font(.subheadline)
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                                .padding(.horizontal, 32)

                                // Dynamic protocol cards from the plan
                                VStack(spacing: 12) {
                                    // Conservative Mode Banner (§4.1)
                                    if appState.isConservativeMode {
                                        HStack(spacing: 8) {
                                            Image(systemName: "shield.checkered")
                                                .foregroundStyle(.orange)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Conservative Mode")
                                                    .font(.caption.weight(.bold))
                                                    .foregroundStyle(Color(uiColor: .label))
                                                Text("Simplified protocol — focus on consistency.")
                                                    .font(.caption2)
                                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                            }
                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }

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
                                    } else if appState.isConservativeMode, let day = currentDay {
                                        // Conservative: only 3 essential instructions
                                        let conservative = PlanBuilder.conservativeInstructions(
                                            bedtime: day.sleepWindow.bedtime,
                                            wakeTime: day.sleepWindow.wakeTime,
                                            direction: appState.tripPlan?.direction ?? .eastward,
                                            profile: appState.tripPlan?.profile ?? .normal
                                        )
                                        ForEach(conservative) { instruction in
                                            ProtocolCard(
                                                time: PlanBuilder.time(instruction.scheduledTime),
                                                icon: instruction.iconName,
                                                title: instruction.title,
                                                detail: instruction.detail,
                                                reasoning: instruction.reasoning,
                                                accentColor: Color(instruction.accentColorName)
                                            )
                                        }
                                    } else if let day = currentDay {
                                        // Normal: full protocol
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
                        .id(appState.recoveryPhaseDayIndex)
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
                            if appState.recoveryPhaseDayIndex > 0 { 
                                appState.recoveryPhaseDayIndex -= 1 
                                appState.isRestDayActive = false
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                            .foregroundStyle(appState.recoveryPhaseDayIndex > 0 ? Color.nazeitTeal : Color(uiColor: .tertiaryLabel))
                            .frame(width: 56, height: 56)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                            .shadow(color: Color.black.opacity(appState.recoveryPhaseDayIndex > 0 ? 0.05 : 0), radius: 8, y: 4)
                    }
                    .disabled(appState.recoveryPhaseDayIndex == 0)

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if appState.recoveryPhaseDayIndex < dayCount - 1 {
                                appState.recoveryPhaseDayIndex += 1
                                appState.isRestDayActive = false
                                // Update adaptation progressively per day
                                appState.adaptationPercent = currentAdaptation
                                appState.circadianLevel = appState.adaptationPercent
                                // §4.1: Completing a day without deviation resets recalcCount
                                appState.completeSuccessfulDay()
                            } else {
                                // Last day — fully adapted
                                appState.adaptationPercent = 1.0
                                appState.circadianLevel = 1.0
                                navigateToFullyAdapted = true
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(appState.recoveryPhaseDayIndex == dayCount - 1 ? "View Adaptation Status" : "Next Day")
                            if appState.recoveryPhaseDayIndex < dayCount - 1 {
                                Image(systemName: "arrow.right")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(appState.recoveryPhaseDayIndex == dayCount - 1 ? .white : Color.nazeitTeal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(appState.recoveryPhaseDayIndex == dayCount - 1 ? Color.nazeitTeal : Color.nazeitTeal.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                .stroke(
                                    appState.recoveryPhaseDayIndex == dayCount - 1
                                    ? Color.clear
                                    : Color.nazeitTeal.opacity(0.35),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: appState.recoveryPhaseDayIndex)
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigatetoDashboard) {
            AdaptationProgressView()
                .environmentObject(appState)
                .onAppear { appState.transitionPhase(to: .postflight) }
        }
        .navigationDestination(isPresented: $navigateToFullyAdapted) {
            FullyAdaptedView()
                .environmentObject(appState)
        }
        .onAppear {
            // Auto-detect if user is already fully adapted (§4)
            if appState.isFullyAdapted {
                appState.adaptationPercent = 1.0
                appState.circadianLevel = 1.0
                navigateToFullyAdapted = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecoveryPhaseView().environmentObject(AppState())
    }
}
