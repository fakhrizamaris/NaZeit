//
//  InFlightDeviated.swift
//  NazeitApp
//
//  Deviation screen — triggered when user can't follow primary in-flight instruction.
//  Now reads recalculation data from tripPlan and respects §4.1 recalcCount limit.
//

import SwiftUI

enum InFlightDeviationType {
    case stayedAwake
    case fellAsleep
}

struct ScreenNewC_InFlightDeviated: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var isCompleted = false
    
    var deviationType: InFlightDeviationType = .stayedAwake
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    /// Adjusted sleep window from the plan
    private var adjustedBedtime: String {
        guard let inflight = appState.tripPlan?.inflightProtocol else { return "--:--" }
        // Shift the sleep window by 1 hour for the deviation scenario
        let shifted = inflight.sleepWindow.bedtime.addingTimeInterval(3600)
        return PlanBuilder.time(shifted)
    }

    /// Recalc status
    private var recalcStatus: String {
        let count = appState.tripPlan?.recalcCount ?? 0
        return "Recalculation \(count + 1) of 2"
    }

    /// Whether recalc is still allowed (§4.1: max 2)
    private var canRecalculate: Bool {
        (appState.tripPlan?.recalcCount ?? 0) < 2
    }

    private var inflightLabel: String {
        appState.tripPlan?.inflightProtocol?.shiftLabel ?? "In-Flight"
    }
    
    var body: some View {
        ZStack {
            StarsBackground()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        CircadianHeroCard(
                            level: appState.circadianLevel,
                            hrv: appState.inputMethod == .watch ? Double(appState.currentHRV) : nil,
                            dayLabel: inflightLabel,
                            phaseTitle: "In-Flight",
                            deltaText: canRecalculate ? "Plan adjusted" : "Conservative mode",
                            etaText: canRecalculate
                                ? (deviationType == .stayedAwake
                                   ? "Delay mode: sleep window shifted"
                                   : "Recovery mode: hold wake window")
                                : "Max adjustments reached — following safe defaults",
                            bedtime: appState.inputMethod == .manual ? appState.bedtimeString : nil,
                            wakeTime: appState.inputMethod == .manual ? appState.wakeTimeString : nil
                        )
                        .padding(.top, 16)

                        VStack(alignment: .leading, spacing: 2) {
                            if !canRecalculate {
                                // MARK: Conservative Mode (§4.1)
                                HStack(spacing: 8) {
                                    Image(systemName: "shield.checkered")
                                        .foregroundStyle(.orange)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Conservative Mode Active")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(Color(uiColor: .label))
                                        Text("Focus on these 3 priorities only.")
                                            .font(.caption2)
                                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                                let conservative = PlanBuilder.conservativeInstructions(
                                    bedtime: appState.tripPlan?.inflightProtocol?.sleepWindow.bedtime ?? appState.preferredBedtime,
                                    wakeTime: appState.tripPlan?.inflightProtocol?.sleepWindow.wakeTime ?? appState.preferredWakeTime,
                                    direction: appState.tripPlan?.direction ?? .eastward,
                                    profile: appState.tripPlan?.profile ?? .normal
                                )
                                ForEach(conservative) { instruction in
                                    HStack(spacing: 12) {
                                        Image(systemName: instruction.iconName)
                                            .font(.title3)
                                            .foregroundStyle(Color(instruction.accentColorName))
                                            .frame(width: 36, height: 36)
                                            .background(Color(instruction.accentColorName).opacity(0.12), in: Circle())
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(instruction.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(Color(uiColor: .label))
                                            Text(instruction.detail)
                                                .font(.caption)
                                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                        }
                                        Spacer()
                                    }
                                    .padding(14)
                                    .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                }
                            } else {
                                // Normal deviation instructions
                                HStack(spacing: 12) {
                                    Image(systemName: deviationType == .stayedAwake ? "moon.stars.fill" : "sun.max.fill")
                                        .font(.system(size: heroIconSize * 0.56))
                                        .foregroundStyle(Color.semanticWarningAmber)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(deviationType == .stayedAwake ? "Dim lights now" : "Get active and seek light")
                                            .font(.system(.title2, design: .rounded).weight(.bold))
                                            .foregroundStyle(Color(uiColor: .label))
                                        Text(deviationType == .stayedAwake
                                             ? "Sleep window: \(adjustedBedtime)"
                                             : "Stay awake until landing")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    }
                                }

                                // Recalc counter badge
                                Text(recalcStatus)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.semanticWarningAmber, in: Capsule())
                                    .padding(.top, 8)
                            }

                            if showWhy {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Why adjusted?")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    Text(deviationType == .stayedAwake
                                         ? "Since you are still awake, keep light low to help melatonin rise. Your sleep window is shifted to keep adaptation safe."
                                         : "Because you slept off-schedule, your body may drift backward. Activity and bright light keep your adaptation moving forward.")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(uiColor: .tertiarySystemFill), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .padding(.top, 10)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                showWhy.toggle()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "info.circle")
                                Text(showWhy ? "Hide why" : "Why now?")
                                Image(systemName: showWhy ? "chevron.up" : "chevron.down")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.semanticPrimaryTeal)
                        }

                        if isCompleted {
                            VStack(spacing: 12) {
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundStyle(Color.nazeitTeal)
                                    Text("Done!")
                                        .font(.system(.title, design: .rounded).weight(.bold))
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    Text("Adjusted action logged")
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                                .padding(22)
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                                NavigationLink {
                                    RecoveryPhaseView().environmentObject(appState)
                                } label: {
                                    HStack(spacing: 7) {
                                        Text("Continue")
                                        Image(systemName: "arrow.right")
                                    }
                                    .appPrimaryCTAStyle()
                                }
                            }
                            .transition(.opacity.combined(with: .scale(scale: 0.98)))
                        } else {
                            Button {
                                // Trigger recalculation per §4.1
                                appState.recalculatePlanIfAllowed()
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                    isCompleted = true
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Got it")
                                    Image(systemName: "checkmark")
                                }
                                .appPrimaryCTAStyle()
                            }
                        }

                        NavigationLink {
                            RecoveryPhaseView().environmentObject(appState)
                        } label: {
                            Text("Can't do this now")
                                .appInteractiveTextStyle()
                        }
                        .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 24)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 20)
                }
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview("Stayed Awake") { NavigationStack { ScreenNewC_InFlightDeviated(deviationType: .stayedAwake).environmentObject(AppState()) } }

#Preview("Fell Asleep") { NavigationStack { ScreenNewC_InFlightDeviated(deviationType: .fellAsleep).environmentObject(AppState()) } }
