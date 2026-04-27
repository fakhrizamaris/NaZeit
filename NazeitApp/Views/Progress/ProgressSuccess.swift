//
//  ProgressSuccess.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 13/04/26.
//

import SwiftUI

// MARK: - Screen 6: Your Adaptation
struct AdaptationProgressView: View {
    @EnvironmentObject var appState: AppState
    @State private var ringProgress: Double = 0
    @State private var appeared = false
    @State private var showCancelConfirmation = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Text("Your Adaptation")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.top, 24).padding(.bottom, 8)
                
                Text("Based on your \(appState.inputMethod == .watch ? "Apple Watch data" : "Sleep Schedule")")
                    .font(.caption).foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding(.bottom, 32)
                
                // MARK: Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 14)
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(AngularGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.7),
                                Color.cyan,
                                Color.staticTeal
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(Int(appState.adaptationPercent * 100))%")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .foregroundStyle(Color(uiColor: .label))
                        Text(appState.isFullyAdapted ? "Aligned" : (appState.adaptationPercent < 0.4 ? "Misaligned" : "Adjusting"))
                            .font(.caption).foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                }
                .padding(.bottom, 32)
                
                // MARK: Metric Cards
                HStack(spacing: 12) {
                    MetricCard(value: String(format: "%.1f", appState.sleepHours) + "h",
                               label: "Sleep",
                               icon: "moon.zzz.fill",
                               iconColor: Color.indigo,
                               trend: nil)
                    if appState.inputMethod == .watch {
                        MetricCard(value: "\(appState.currentHRV)ms",
                                   label: "HRV",
                                   icon: "waveform.path",
                                   iconColor: .nazeitTeal,
                                   trend: "↑")
                    } else {
                        if appState.isFullyAdapted {
                            MetricCard(value: "In Sync",
                                       label: "Status",
                                       icon: "checkmark.circle.fill",
                                       iconColor: .nazeitTeal,
                                       trend: nil)
                        } else {
                            MetricCard(value: "\(appState.daysRemaining) days",
                                       label: "Remaining",
                                       icon: "calendar.badge.clock",
                                       iconColor: .nazeitTeal,
                                       trend: nil)
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 20)
                
                VStack(spacing: 8) {
                    if appState.isFullyAdapted {
                        Text("Adaptation successful")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                    } else {
                        Text("Keep going — \(appState.daysRemaining) days left")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemGray5)).frame(height: 4)
                            Capsule()
                                .fill(LinearGradient(colors: [Color.cyan, .staticTeal],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * ringProgress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 32)
                
                Spacer()
                
                if appState.isFullyAdapted {
                    NavigationLink {
                        FullyAdaptedView().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("View Journey Result")
                            Image(systemName: "flag.checkered").fontWeight(.semibold)
                        }
                        .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.mint, Color.staticTeal],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.mint.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                } else if appState.travelPhase == .inflight {
                    NavigationLink {
                        SleepNowView().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Start in-flight protocol")
                            Image(systemName: "airplane").fontWeight(.semibold)
                        }
                        .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.teal, Color.staticTeal],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                } else if appState.travelPhase == .postflight {
                    NavigationLink {
                        RecoveryPhaseView().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue recovery protocol")
                            Image(systemName: "figure.walk").fontWeight(.semibold)
                        }
                        .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.cyan, Color.staticTeal],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.cyan.opacity(0.20), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                }
            }
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showCancelConfirmation = true
                    } label: {
                        Label("Cancel Trip", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(Color.nazeitTeal)
                }
            }
        }
        .alert("Cancel This Trip?", isPresented: $showCancelConfirmation) {
            Button("Cancel Trip", role: .destructive) {
                withAnimation { appState.resetForNewTrip() }
            }
            Button("Keep Going", role: .cancel) { }
        } message: {
            Text("This will erase your entire adaptation plan and all progress. This action cannot be undone.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.7).delay(0.1)) { appeared = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) { ringProgress = appState.adaptationPercent }
        }
        .onChange(of: appState.adaptationPercent) { oldValue, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                ringProgress = newValue
            }
        }
    }
}


// MARK: - Fully Adapted
struct FullyAdaptedView: View {
    @EnvironmentObject var appState: AppState

    // MARK: Animation States
    @State private var ringProgress: Double = 0.0
    @State private var countedPercent: Int = 0
    @State private var showCheckmark = false
    @State private var checkmarkScale: CGFloat = 0.0
    @State private var showText = false
    @State private var showStats = false
    @State private var showCTA = false
    @State private var particlesOn = false
    @State private var pulseGlow = false
    @State private var outerRingScale: CGFloat = 0.6
    @State private var confettiBurst = false

    private let ringSize: CGFloat = 160
    private let ringLineWidth: CGFloat = 10

    private var totalAdaptationDays: Int {
        let loading = appState.tripPlan?.loadingPhase.count ?? 0
        let recovery = appState.tripPlan?.recoveryPhase.count ?? 0
        return loading + recovery + 1
    }

    private var gapHours: String {
        guard let plan = appState.tripPlan else { return "—" }
        return String(format: "%.0f", plan.totalGapHours)
    }

    var body: some View {
        ZStack {
            // Background glow
            RadialGradient(
                colors: [Color.nazeitTeal.opacity(pulseGlow ? 0.18 : 0.0), .clear],
                center: .center,
                startRadius: 10,
                endRadius: 300
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseGlow)

            // Confetti particles
            if particlesOn { SuccessParticles() }

            // Confetti burst circles
            if confettiBurst {
                ConfettiBurst()
                    .transition(.opacity)
            }

            VStack(spacing: 0) {
                Spacer()

                // MARK: Ring + Percentage / Checkmark
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(Color.nazeitTeal.opacity(0.12), lineWidth: 2)
                        .frame(width: ringSize + 40, height: ringSize + 40)
                        .scaleEffect(outerRingScale)

                    // Track ring
                    Circle()
                        .stroke(Color(uiColor: .quaternaryLabel), lineWidth: ringLineWidth)
                        .frame(width: ringSize, height: ringSize)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            AngularGradient(
                                colors: [Color.nazeitTeal, Color.cyan, Color.nazeitTeal],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                        )
                        .frame(width: ringSize, height: ringSize)
                        .rotationEffect(.degrees(-90))

                    // Inner glow when full
                    if showCheckmark {
                        Circle()
                            .fill(Color.nazeitTeal.opacity(0.15))
                            .frame(width: ringSize - 20, height: ringSize - 20)
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Percentage counter → Checkmark transition
                    if showCheckmark {
                        Image(systemName: appState.adaptationPercent >= 1.0 ? "checkmark" : "flag.fill")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.nazeitTeal)
                            .scaleEffect(checkmarkScale)
                            .transition(.scale(scale: 0.3).combined(with: .opacity))
                    } else {
                        VStack(spacing: 2) {
                            Text("\(countedPercent)%")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(uiColor: .label))
                                .contentTransition(.numericText(value: Double(countedPercent)))

                            let targetPercent = Int(appState.adaptationPercent * 100)
                            Text(countedPercent < targetPercent ? "Syncing..." : (appState.adaptationPercent >= 1.0 ? "Synced!" : "Completed"))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                    }
                }
                .padding(.bottom, 36)

                // MARK: Title & Subtitle
                VStack(spacing: 10) {
                    Text(appState.adaptationPercent >= 1.0 ? "Fully Adapted! 🎉" : "Journey Complete 🚩")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 16)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: showText)

                    Text(appState.adaptationPercent >= 1.0 
                         ? "Your body clock is fully synced\nwith the local time zone" 
                         : "You've finished the adaptation timeline,\nwith an adherence score of \(Int(appState.adaptationPercent * 100))%.")
                        .font(.subheadline)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1 : 0)
                        .offset(y: showText ? 0 : 10)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: showText)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)

                // MARK: Stats Row
                HStack(spacing: 0) {
                    StatPill(icon: "calendar", value: "\(totalAdaptationDays)", label: "Days")
                    StatDivider()
                    StatPill(icon: "globe.americas.fill", value: "\(gapHours)h", label: "Shifted")
                    StatDivider()
                    StatPill(icon: appState.inputMethod == .watch ? "applewatch" : "hand.tap.fill",
                             value: appState.inputMethod == .watch ? "Watch" : "Manual",
                             label: "Tracked")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5)
                )
                .padding(.horizontal, 32)
                .opacity(showStats ? 1 : 0)
                .scaleEffect(showStats ? 1.0 : 0.9)
                .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: showStats)

                // MARK: Misalignment Disclaimer
                if appState.adaptationPercent < 0.85 && showStats {
                    let isSevere = appState.adaptationPercent < 0.60
                    let disclaimerColor: Color = isSevere ? .orange : .yellow
                    let disclaimerIcon = isSevere ? "exclamationmark.triangle.fill" : "info.circle.fill"
                    let disclaimerTitle = isSevere
                        ? "Still Significantly Misaligned"
                        : "Partially Aligned"
                    let disclaimerBody = isSevere
                        ? "Your circadian rhythm is still significantly out of sync. Maintain consistent sleep/wake times at your destination for the next few days to reduce residual jetlag."
                        : "Your body clock is partially aligned. You may still experience mild symptoms like daytime drowsiness or disrupted sleep for 1–2 more days."

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: disclaimerIcon)
                                .font(.title3)
                                .foregroundStyle(disclaimerColor)

                            Text(disclaimerTitle)
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                                .foregroundStyle(Color(uiColor: .label))
                        }

                        Text(disclaimerBody)
                            .font(.footnote)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .fixedSize(horizontal: false, vertical: true)

                        // Adherence score badge
                        HStack(spacing: 6) {
                            Circle()
                                .fill(disclaimerColor)
                                .frame(width: 8, height: 8)
                            Text("Adherence: \(Int(appState.adaptationPercent * 100))%")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(disclaimerColor)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(disclaimerColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(disclaimerColor.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: showStats)
                }

                Spacer()

                // MARK: CTA
                NavigationLink {
                    YourTrip()
                        .environmentObject(appState)
                        .onAppear {
                            appState.resetForNewTrip()
                        }
                } label: {
                    PrimaryBtn(title: "Plan Next Trip")
                }
                .padding(.horizontal, 24)
                .opacity(showCTA ? 1 : 0)
                .offset(y: showCTA ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showCTA)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { startCelebrationSequence() }
    }

    // MARK: - Celebration Animation Sequence
    private func startCelebrationSequence() {
        // Phase 1: Outer ring scales in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            outerRingScale = 1.0
        }

        let targetPercent = Int(appState.adaptationPercent * 100)
        
        // Phase 2: Ring fills 0→targetPercent over 1.8s with counting number
        withAnimation(.easeInOut(duration: 1.8)) {
            ringProgress = appState.adaptationPercent
        }

        // Count from 0 to targetPercent
        let totalSteps = 50
        let interval = 1.8 / Double(totalSteps)
        for step in 0...totalSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {
                withAnimation(.linear(duration: interval)) {
                    countedPercent = Int(Double(step) / Double(totalSteps) * Double(targetPercent))
                }
                // Haptic ticks at milestones
                if countedPercent == targetPercent / 4 || countedPercent == targetPercent / 2 || countedPercent == (targetPercent * 3) / 4 {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }

        // Phase 3: At 100% → checkmark morphs in + confetti + haptic
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                showCheckmark = true
                checkmarkScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.3)) {
                confettiBurst = true
            }
            particlesOn = true
            pulseGlow = true
        }

        // Phase 4: Text fades in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation { showText = true }
        }

        // Phase 5: Stats appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation { showStats = true }
        }

        // Phase 6: CTA slides up
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation { showCTA = true }
        }
    }
}

// MARK: - Supporting Views
private struct StatPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.nazeitTeal)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(uiColor: .label))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color(uiColor: .tertiaryLabel))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StatDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(uiColor: .quaternaryLabel))
            .frame(width: 1, height: 32)
    }
}

private struct ConfettiBurst: View {
    @State private var animate = false

    private let colors: [Color] = [.nazeitTeal, .cyan, .mint, .orange, .indigo, .yellow]
    private let count = 24

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(
                        x: animate ? CGFloat.random(in: -160...160) : 0,
                        y: animate ? CGFloat.random(in: -200...200) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 0.3 : 1.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { animate = true }
        }
    }
}

#Preview("Screen 6") { NavigationStack { AdaptationProgressView().environmentObject(AppState()) } }
#Preview("Screen 7") { NavigationStack { FullyAdaptedView().environmentObject(AppState()) } }

