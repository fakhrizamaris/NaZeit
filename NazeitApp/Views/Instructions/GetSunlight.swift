//
//  GetSunlight.swift
//  NazeitApp
//
//  In-flight instruction: Get Sunlight — driven by tripPlan.inflightProtocol.
//

import SwiftUI

struct GetSunlightView: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var isCompleted = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    /// Second instruction from in-flight protocol (type: .wake or .seekLight)
    private var lightInstruction: Instruction? {
        let inflight = appState.tripPlan?.inflightProtocol?.instructions ?? []
        return inflight.first(where: { $0.type == .wake || $0.type == .seekLight })
    }

    private var inflightLabel: String {
        appState.tripPlan?.inflightProtocol?.shiftLabel ?? "In-Flight"
    }

    /// Dynamic time subtitle
    private var timeDetail: String {
        guard let inst = lightInstruction else { return "20 min · seek bright light" }
        if let dur = inst.duration {
            return "\(Int(dur / 60)) min · \(PlanBuilder.time(inst.scheduledTime))"
        }
        return PlanBuilder.time(inst.scheduledTime)
    }

    var body: some View {
        ZStack {
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
                                Image(systemName: lightInstruction?.iconName ?? "sun.max.fill")
                                    .font(.system(size: heroIconSize * 0.56))
                                    .foregroundStyle(Color.semanticWarningAmber)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(lightInstruction?.title ?? "Get sunlight")
                                        .font(.system(.title2, design: .rounded).weight(.bold))
                                        .foregroundStyle(Color(uiColor: .label))
                                    Text(timeDetail)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                            }

                            if showWhy {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Why now?")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    Text(lightInstruction?.reasoning
                                         ?? "Morning light suppresses melatonin and signals your brain it is daytime in the new time zone.")
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
                                    Text("Sunlight exposure logged")
                                        .font(.title3.weight(.medium))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                                .padding(22)
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                                NavigationLink {
                                    AvoidBrightLightView().environmentObject(appState)
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
                            NavDots(total: 3, current: 1)

                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                    isCompleted = true
                                    // Credit ~3% for completing sunlight step (2 of 3 in-flight steps)
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
                            ScreenNewB_RecalculatedInstruction().environmentObject(appState)
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
    }
}

#Preview { NavigationStack { GetSunlightView().environmentObject(AppState()) } }
