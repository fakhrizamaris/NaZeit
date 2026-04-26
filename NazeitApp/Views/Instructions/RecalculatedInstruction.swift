//
//  RecalculatedInstruction.swift
//  NazeitApp
//
//  Shown when a user deviates from schedule — displays the recalculated instruction.
//  Now reads dynamic times and respects §4.1 recalcCount.
//

import SwiftUI

struct ScreenNewB_RecalculatedInstruction: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var isCompleted = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    /// The light/wake instruction from in-flight protocol
    private var lightInstruction: Instruction? {
        let inflight = appState.tripPlan?.inflightProtocol?.instructions ?? []
        return inflight.first(where: { $0.type == .wake || $0.type == .seekLight })
    }

    /// Original vs adjusted time (shifted +2h for recalculation)
    private var originalTime: String {
        guard let inst = lightInstruction else { return "7:00 AM" }
        return PlanBuilder.time(inst.scheduledTime)
    }

    private var adjustedTime: String {
        guard let inst = lightInstruction else { return "9:00 AM" }
        // Recalculated: shift by grace window (60-90 min → use 2h for readability)
        let shifted = inst.scheduledTime.addingTimeInterval(2 * 3600)
        return PlanBuilder.time(shifted)
    }

    private var inflightLabel: String {
        appState.tripPlan?.inflightProtocol?.shiftLabel ?? "In-Flight"
    }

    /// Recalc count display
    private var recalcLabel: String {
        let count = appState.tripPlan?.recalcCount ?? 0
        return "Recalculated from \(originalTime) (#\(count + 1))"
    }

    /// Whether recalc is still allowed
    private var canRecalculate: Bool {
        (appState.tripPlan?.recalcCount ?? 0) < 2
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // MARK: Contextual Adjustment Banner
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "airplane")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.nazeitTeal, in: Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("In-Flight")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(Color.nazeitTeal)
                                    Text(inflightLabel)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color(uiColor: .label))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundStyle(Color.semanticWarningAmber)
                            }
                            
                            Divider()
                            
                            HStack(spacing: 16) {
                                if appState.inputMethod == .manual {
                                    HStack(spacing: 4) {
                                        Image(systemName: "moon.fill").foregroundStyle(.indigo)
                                        Text(appState.bedtimeString)
                                            .font(.caption.weight(.semibold))
                                    }
                                    HStack(spacing: 4) {
                                        Image(systemName: "sunrise.fill").foregroundStyle(.orange)
                                        Text(appState.wakeTimeString)
                                            .font(.caption.weight(.semibold))
                                    }
                                }
                                
                                Spacer()
                                
                                Text(canRecalculate ? recalcLabel : "Conservative mode active")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(canRecalculate ? Color.semanticWarningAmber : .orange, in: Capsule())
                            }
                            
                            Text(canRecalculate
                                 ? "Plan shifted to stay aligned"
                                 : "Max adjustments reached — safe defaults applied")
                                .font(.caption)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.semanticWarningAmber.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 0)
                        .padding(.top, 16)

                        if !canRecalculate {
                            // MARK: Conservative Mode (§4.1) — after 2x misalignment
                            HStack(spacing: 8) {
                                Image(systemName: "shield.checkered")
                                    .foregroundStyle(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Conservative Mode Active")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color(uiColor: .label))
                                    Text("Max adjustments reached. Focus on these 3 priorities.")
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

                            if isCompleted {
                                VStack(spacing: 12) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundStyle(Color.nazeitTeal)
                                        Text("Understood")
                                            .font(.system(.title, design: .rounded).weight(.bold))
                                            .foregroundStyle(Color.semanticPrimaryTeal)
                                        Text("Following safe defaults")
                                            .font(.title3.weight(.medium))
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
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                        isCompleted = true
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("Understood")
                                        Image(systemName: "checkmark")
                                    }
                                    .appPrimaryCTAStyle()
                                }
                            }
                        } else {
                            // Normal recalculated instructions
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 12) {
                                    Image(systemName: "sun.max.fill")
                                        .font(.system(size: heroIconSize * 0.56))
                                        .foregroundStyle(Color.semanticWarningAmber)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Get sunlight at \(adjustedTime)")
                                            .font(.system(.title2, design: .rounded).weight(.bold))
                                            .foregroundStyle(Color(uiColor: .label))
                                        Text("20 min · adjusted from \(originalTime)")
                                            .font(.title3.weight(.semibold))
                                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    }
                                }

                                if showWhy {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Why adjusted?")
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(Color.semanticPrimaryTeal)
                                        Text("Because your sleep time shifted, the sunlight window also needs to shift. This update keeps your circadian direction on track without forcing your body.")
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
                                        Text("Plan Updated")
                                            .font(.system(.title, design: .rounded).weight(.bold))
                                            .foregroundStyle(Color.semanticPrimaryTeal)
                                        Text("New sunlight window confirmed")
                                            .font(.title3.weight(.medium))
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
                                        // Credit ~2% for completing recalculated step (reduced vs normal)
                                        appState.adaptationPercent = min(1.0, appState.adaptationPercent + 0.02)
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
                    }
                    .padding(.horizontal, 24)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 20)
                }
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { NavigationStack { ScreenNewB_RecalculatedInstruction().environmentObject(AppState()) } }
