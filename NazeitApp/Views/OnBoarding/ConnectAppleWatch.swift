//
//  ConnectAppleWatch.swift
//  NazeitApp
//

import SwiftUI

struct ConnectAppleWatch: View {
    @EnvironmentObject var appState: AppState
    @State private var isSynced    = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            OnboardingChoiceBackgroundView(glowAnimated: isAnimating)
            
            VStack(spacing: 0) {
                StepIndicatorView(step: 2, totalSteps: 3)
                    .padding(.top, 12)
                
                Spacer()
                
                AnimatedWatchIcon(isAnimating: isAnimating, isSynced: isSynced)
                    .padding(.bottom, 40)
                
                Text(isSynced ? "Watch Connected!" : "Connect Apple Watch")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: isSynced)
                    .padding(.bottom, 8)
                
                Text("We'll read your biometric data in real-time.")
                    .font(.body)
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.bottom, 36)
                
                VStack(spacing: 8) {
                    WatchDataChip(icon: "heart.fill", label: "Heart Rate", value: "82 BPM", color: .pink, isSynced: isSynced)
                    WatchDataChip(icon: "waveform.path", label: "HRV Variability", value: "52 ms", color: Color(uiColor: .nazeitTeal), isSynced: isSynced)
                    WatchDataChip(icon: "moon.zzz.fill", label: "Sleep Duration", value: "7.2 Hrs", color: .indigo, isSynced: isSynced)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 44)
                
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isSynced = true
                        appState.circadianLevel = 0.45
                        appState.currentHRV     = 52
                        appState.sleepHours     = 7.2
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isSynced { Image(systemName: "checkmark").fontWeight(.bold) }
                        Text(isSynced ? "Data Synced" : "Sync Now")
                    }
                    .appPrimaryCTAStyle(isEnabled: !isSynced)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .disabled(isSynced)
                
                NavigationLink {
                    YourTrip().environmentObject(appState)
                } label: {
                    HStack(spacing: 4) {
                        Text("Continue to trip setup")
                        Image(systemName: "arrow.right").font(.footnote)
                    }
                    .appInteractiveTextStyle(isEnabled: isSynced)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    appState.resetTripFields()
                })
                .disabled(!isSynced)
                .animation(.easeInOut, value: isSynced)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isAnimating = true }
    }
}

// MARK: - Components
struct AnimatedWatchIcon: View {
    var isAnimating: Bool
    var isSynced: Bool
    
    @ScaledMetric(relativeTo: .largeTitle) private var watchIconSize: CGFloat = 44
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                let size: CGFloat = CGFloat(100 + i * 36)
                let delay: Double = Double(i) * 0.38
                let tScale: CGFloat = CGFloat(1.5 + Double(i) * 0.3)
                
                Circle()
                    .stroke(Color(uiColor: .nazeitTeal).opacity(isAnimating ? 0 : 0.25), lineWidth: 1.5)
                    .frame(width: size)
                    .scaleEffect(isAnimating ? tScale : 1.0)
                    .animation(.easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(delay), value: isAnimating)
            }
            ZStack {
                Circle()
                    .fill(isSynced ? Color.mint.opacity(0.18) : Color.cyan.opacity(0.14))
                    .frame(width: 96)
                    .animation(.spring(response: 0.4), value: isSynced)
                
                Image(systemName: isSynced ? "checkmark.circle.fill" : "applewatch")
                    .font(.system(size: watchIconSize, weight: .light))
                    .symbolRenderingMode(isSynced ? .multicolor : .monochrome)
                    .foregroundStyle(isSynced ? Color.mint : Color.cyan)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
    }
}

private struct WatchDataChip: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let isSynced: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color(uiColor: .label))
            Spacer()
            
            if isSynced {
                Text(value)
                    .font(.subheadline.monospacedDigit().weight(.bold))
                    .foregroundStyle(color)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Text("--")
                    .font(.subheadline.monospacedDigit().weight(.bold))
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSynced)
    }
}

#Preview {
    NavigationStack { ConnectAppleWatch().environmentObject(AppState()) }
}
