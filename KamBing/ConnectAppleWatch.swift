//  ConnectAppleWatch.swift — KamBing
//  Screen 1A: Path Apple Watch — HiFi dark, animasi pulse rings, glassmorphism chips.

import SwiftUI

struct ConnectAppleWatch: View {
    @EnvironmentObject var appState: AppState
    @State private var isSynced    = false
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.bgNightTop, .bgNight, Color(red:0.06,green:0.04,blue:0.20)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // MARK: Animated Watch Icon dengan pulse rings
                AnimatedWatchIcon(isAnimating: isAnimating, isSynced: isSynced)
                .padding(.bottom, 44)

                // MARK: Labels
                Text(isSynced ? "Watch connected!" : "Connect Apple Watch")
                    .font(.title2).fontWeight(.bold).foregroundStyle(.white)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: isSynced)
                    .padding(.bottom, 8)

                Text("We'll read your biometric data in real-time")
                    .font(.subheadline).foregroundStyle(.white.opacity(0.50))
                    .padding(.bottom, 36)

                // Data chips — TextView showing what data is collected
                VStack(spacing: 8) {
                    WatchDataChip(icon: "heart.fill",    label: "Heart rate",   color: Color(red:0.9,green:0.3,blue:0.4))
                    WatchDataChip(icon: "waveform.path", label: "HRV",          color: .circadianTeal)
                    WatchDataChip(icon: "moon.zzz.fill", label: "Sleep stages", color: Color(red:0.55,green:0.4,blue:0.95))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 44)

                // MARK: Primary Button — Sync Now
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isSynced = true
                        appState.circadianLevel = 0.45
                        appState.currentHRV     = 52
                        appState.sleepHours     = 7.2
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isSynced { Image(systemName: "checkmark").fontWeight(.semibold) }
                        Text(isSynced ? "Data synced" : "Sync now")
                    }
                    .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: isSynced
                            ? [Color.green.opacity(0.8), Color.green.opacity(0.55)]
                            : [Color.accentColor, Color.accentColor.opacity(0.72)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: (isSynced ? Color.green : Color.accentColor).opacity(0.35), radius: 10, y: 5)
                    .animation(.spring(response: 0.4), value: isSynced)
                }
                .padding(.horizontal, 24).padding(.bottom, 14)
                .disabled(isSynced)

                // Continue link — hanya aktif setelah sync
                NavigationLink {
                    YourTrip().environmentObject(appState)
                } label: {
                    HStack(spacing: 4) {
                        Text("Continue to trip setup")
                        Image(systemName: "arrow.right").font(.footnote)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(isSynced ? 0.80 : 0.30))
                }
                .disabled(!isSynced)
                .animation(.easeInOut, value: isSynced)

                Spacer()
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { isAnimating = true }
    }
}

struct AnimatedWatchIcon: View {
    var isAnimating: Bool
    var isSynced: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                let size: CGFloat = CGFloat(100 + i * 36)
                let delay: Double = Double(i) * 0.38
                let tScale: CGFloat = CGFloat(1.5 + Double(i) * 0.3)
                
                Circle()
                    .stroke(Color.circadianTeal.opacity(isAnimating ? 0 : 0.25), lineWidth: 1.5)
                    .frame(width: size)
                    .scaleEffect(isAnimating ? tScale : 1.0)
                    .animation(.easeOut(duration: 1.8).repeatForever(autoreverses: false).delay(delay), value: isAnimating)
            }
            ZStack {
                Circle()
                    .fill(isSynced ? Color.green.opacity(0.22) : Color.circadianTeal.opacity(0.14))
                    .frame(width: 96)
                    .animation(.spring(response: 0.4), value: isSynced)
                Image(systemName: isSynced ? "checkmark.circle.fill" : "applewatch")
                    .font(.system(size: 44, weight: .thin))
                    .symbolRenderingMode(isSynced ? .palette : .hierarchical)
                    .foregroundStyle(isSynced ? Color.green : Color.circadianTeal, Color.white)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
    }
}

private struct WatchDataChip: View {
    let icon: String; let label: String; let color: Color
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).font(.caption).foregroundStyle(color).frame(width: 18)
            Text(label).font(.subheadline).foregroundStyle(.white.opacity(0.78))
            Spacer()
            Image(systemName: "checkmark").font(.caption2).foregroundStyle(color.opacity(0.7))
        }
        .padding(.horizontal, 18).padding(.vertical, 11)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack { ConnectAppleWatch().environmentObject(AppState()) }
}
