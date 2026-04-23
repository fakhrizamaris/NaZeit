//
//  SleepNow.swift
//  NazeitApp
//
//  Instruction views for in-flight phase — driven by tripPlan.inflightProtocol.
//

import SwiftUI

// MARK: - Circadian Hero Card (Shared Component)
struct CircadianHeroCard: View {
    let level: Double
    var hrv: Double? = nil
    var dayLabel: String = ""
    var phaseTitle: String = ""
    var deltaText: String? = nil
    var etaText: String? = nil
    var bedtime: String? = nil
    var wakeTime: String? = nil

    private let circleSize: CGFloat = 120
    private var baseColor: Color { Color(uiColor: .nazeitTeal) }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color(uiColor: .quaternaryLabel), lineWidth: 5)
                        .frame(width: circleSize, height: circleSize)
                    Circle()
                        .trim(from: 0, to: level)
                        .stroke(baseColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: circleSize, height: circleSize)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.6), value: level)

                    VStack(spacing: 2) {
                        Text("\(Int(level * 100))%")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(Color(uiColor: .label))
                        Text(Circadian.stateLabel(for: level))
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(phaseTitle)
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundStyle(baseColor)
                        Text(dayLabel)
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundStyle(Color(uiColor: .label))
                    }

                    if let hrv {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill").foregroundStyle(.red)
                            Text("HRV \(Int(hrv)) ms")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }

                    if let bedtime, let wakeTime {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Image(systemName: "moon.fill").foregroundStyle(.indigo)
                                Text("Bed: \(bedtime)")
                            }
                            HStack(spacing: 4) {
                                Image(systemName: "sunrise.fill").foregroundStyle(.orange)
                                Text("Wake: \(wakeTime)")
                            }
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }

                    if let delta = deltaText {
                        Text(delta)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.semanticWarningAmber)
                    }

                    if let eta = etaText {
                        Text(eta)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color(uiColor: .tertiaryLabel))
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 24)
    }
}



// MARK: - Sleep Now (In-Flight Instruction 1)
struct SleepNowView: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy = false
    @State private var isCompleted = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    /// First instruction from in-flight protocol (type: .sleep)
    private var sleepInstruction: Instruction? {
        appState.tripPlan?.inflightProtocol?.instructions.first(where: { $0.type == .sleep })
    }

    /// In-flight protocol label
    private var inflightLabel: String {
        appState.tripPlan?.inflightProtocol?.shiftLabel ?? "In-Flight"
    }

    /// Dynamic subtitle
    private var subtitle: String {
        guard let inst = sleepInstruction else { return "Prepare for arrival" }
        return PlanBuilder.time(inst.scheduledTime)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()

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
                                Image(systemName: sleepInstruction?.iconName ?? "moon.zzz.fill")
                                    .font(.system(size: heroIconSize * 0.56))
                                    .foregroundStyle(Color(uiColor: .label))
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(sleepInstruction?.title ?? "Sleep now")
                                        .font(.system(.title2, design: .rounded).weight(.bold))
                                        .foregroundStyle(Color(uiColor: .label))
                                    Text(sleepInstruction?.detail ?? "4 hrs before destination arrival")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                            }

                            if showWhy {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Why now?")
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    Text(sleepInstruction?.reasoning
                                         ?? "Sleeping now anchors melatonin timing to destination night.")
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
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    Text("Done!")
                                        .font(.system(.title, design: .rounded).weight(.bold))
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    Text("Sleep logged")
                                        .font(.title3.weight(.medium))
                                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                                }
                                .padding(22)
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                                HStack(spacing: 10) {
                                    Image(systemName: "sun.max.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.semanticPrimaryTeal)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Up next")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                                        Text("Get sunlight")
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(Color(uiColor: .label))
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                                NavigationLink {
                                    GetSunlightView().environmentObject(appState)
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
                            NavDots(total: 3, current: 0)

                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                                    isCompleted = true
                                    // Credit ~3% for completing sleep step (1 of 3 in-flight steps)
                                    appState.adaptationPercent = min(1.0, appState.adaptationPercent + 0.034)
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
                            ScreenNewC_InFlightDeviated().environmentObject(appState)
                        } label: {
                            Text("Can't sleep right now")
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

// MARK: - WhyChip
struct WhyChip: View {
    @Binding var isShown: Bool
    let explanation: String

    var body: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isShown.toggle() }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "info.circle").font(.caption2).foregroundStyle(Color(uiColor: .nazeitTeal))
                    Text(isShown ? "Hide explanation" : "Why this instruction?")
                        .font(.caption).fontWeight(.medium)
                    Image(systemName: isShown ? "chevron.up" : "chevron.down").font(.caption2)
                }
                .foregroundStyle(Color(uiColor: .nazeitTeal))
            }
            if isShown {
                Text(explanation)
                    .font(.caption).foregroundStyle(Color(uiColor: .tertiaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - NavDots
struct NavDots: View {
    let total: Int; let current: Int
    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color(uiColor: .label) : Color(uiColor: .label).opacity(0.25))
                    .frame(width: i == current ? 7 : 5, height: i == current ? 7 : 5)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}


#Preview {
    NavigationStack { SleepNowView().environmentObject(AppState()) }
}
