//
//  AvoidBrightLight.swift
//  NazeitApp
//
//  In-flight instruction: Avoid Bright Light — driven by tripPlan light windows.
//

import SwiftUI

struct AvoidBrightLightView: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var isCompleted = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    /// Avoid light window from Circadian engine
    private var avoidEndTime: String {
        guard let plan = appState.tripPlan,
              let inflight = plan.inflightProtocol else { return "local bedtime" }
        return PlanBuilder.time(inflight.sleepWindow.bedtime)
    }

    private var inflightLabel: String {
        appState.tripPlan?.inflightProtocol?.shiftLabel ?? "In-Flight"
    }

    var body: some View {
        ZStack {
            MoonDecoration()

            VStack(spacing: 0) {

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        CircadianHeroCard(
                            level: appState.circadianLevel,
                            hrv: appState.inputMethod == .watch ? Double(appState.currentHRV) : nil,
                            dayLabel: inflightLabel,
                            phaseTitle: "In-Flight",
                            bedtime: appState.inputMethod == .manual ? appState.bedtimeString : nil,
                            wakeTime: appState.inputMethod == .manual ? appState.wakeTimeString : nil
                        )
                            .padding(.top, 16)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 12) {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: heroIconSize * 0.56))
                                    .foregroundStyle(Color.semanticWarningAmber)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text("Avoid bright light")
                                        .font(.system(.title2, design: .rounded).weight(.bold))
                                        .foregroundStyle(Color(uiColor: .label))
                                    Text("Until \(avoidEndTime)")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                            }

                            if showWhy {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Why now?")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(Color.semanticWarningAmber)
                                    Text("Bright light late in the evening delays melatonin and pushes sleep timing later. Keeping light low protects your target bedtime.")
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
                                        .foregroundStyle(.white)
                                    Text("Done!")
                                        .font(.system(.title, design: .rounded).weight(.bold))
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    Text("Light avoidance logged")
                                        .font(.title3.weight(.medium))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                                .padding(22)
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                                HStack(spacing: 10) {
                                    Image(systemName: "bed.double.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Up next")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                                        Text("Sleep at \(avoidEndTime)")
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(Color(uiColor: .label))
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

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
                            NavDots(total: 3, current: 2)

                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                    isCompleted = true
                                    // Credit ~3% for completing light avoidance (3 of 3 in-flight steps)
                                    appState.adaptationPercent = min(1.0, appState.adaptationPercent + 0.033)
                                    appState.circadianLevel = appState.adaptationPercent
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Done")
                                    Image(systemName: "checkmark")
                                }
                                .appPrimaryCTAStyle()
                            }
                        }

                        NavigationLink {
                            ScreenNewA_WatchDetects().environmentObject(appState)
                        } label: {
                            Text("I can't avoid light right now")
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

#Preview { NavigationStack { AvoidBrightLightView().environmentObject(AppState()) } }
