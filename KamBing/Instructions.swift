//
//  Instructions.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//

//  Instructions.swift — KamBing
//  Screen 4: Get Sunlight (warm morning gradient)
//  Screen 5: Avoid Bright Light (dark evening gradient)
//  Background warna berubah sesuai waktu — mengkomunikasikan konteks visual.

import SwiftUI

// MARK: - Screen 4: Get Sunlight
struct Screen4GetSunlight: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Warm golden gradient — mengkomunikasikan "pagi / cahaya matahari"
            // tanpa satu kata pun (HIG: visual mempercepat pemahaman konteks).
            LinearGradient(colors: [Color(red:0.99,green:0.82,blue:0.35),
                                    Color(red:0.97,green:0.65,blue:0.18),
                                    Color(red:0.90,green:0.52,blue:0.10)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            // Sun rays decoration
            SunRaysDecoration()

            VStack(spacing: 0) {

                // Phase chip + state bar
                // CircadianStateBar di sini onDark = false karena background terang
                HStack(alignment: .center, spacing: 10) {
                    Label("Day 1 · 07:40 AM", systemImage: "sun.horizon.fill")
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundStyle(Color(red:0.55,green:0.35,blue:0.0).opacity(0.85))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(.black.opacity(0.08)).clipShape(Capsule())
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Circadian state").font(.system(size: 9)).foregroundStyle(.black.opacity(0.40))
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 20)

                Spacer()

                // Main Instruction Card — glassmorphism di atas warm background
                VStack(spacing: 14) {
                    Text("☀️")
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)
                        .shadow(color: Color.bgMorning.opacity(0.6), radius: 20)

                    Text("Get sunlight")
                        .font(.title).fontWeight(.bold)
                        .foregroundStyle(Color(red:0.35,green:0.20,blue:0.0))

                    Text("Go outside for 20 min")
                        .font(.subheadline).foregroundStyle(Color(red:0.45,green:0.28,blue:0.0).opacity(0.75))

                    VStack(spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "clock.badge.exclamationmark").font(.caption2)
                            Text("Best before 7:00 AM")
                                .font(.caption).fontWeight(.medium)
                        }
                        .foregroundStyle(Color(red:0.60,green:0.30,blue:0.0))
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(.black.opacity(0.06)).clipShape(Capsule())

                        Text("Resets your body clock · Based on your circadian phase")
                            .font(.caption).foregroundStyle(Color(red:0.45,green:0.28,blue:0.0).opacity(0.65))
                            .multilineTextAlignment(.center)
                    }
                }
                // Card background — lightly tinted untuk kontras di warm background
                .padding(28).frame(maxWidth: .infinity)
                .background(.white.opacity(0.35), in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.5), lineWidth: 1))
                .shadow(color: .black.opacity(0.10), radius: 20, y: 8)
                .padding(.horizontal, 24)

                Spacer()

                // Why chip — warna gelap untuk kontras di background terang
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.4)) { showWhy.toggle() }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "info.circle").font(.caption2)
                            Text(showWhy ? "Hide" : "Why sunlight?").font(.caption).fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down").font(.caption2)
                        }
                        .foregroundStyle(Color(red:0.35,green:0.20,blue:0.0).opacity(0.65))
                    }
                    if showWhy {
                        Text("Morning light suppresses melatonin and signals your brain it's daytime in the new time zone — the fastest way to shift your circadian clock forward.")
                            .font(.caption).foregroundStyle(Color(red:0.40,green:0.25,blue:0.0).opacity(0.70))
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                NavDots(total: 3, current: 1).padding(.bottom, 20)

                // Up next chip
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption)
                    Text("Up next: Eat at 12:00").font(.caption).fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption2)
                }
                .foregroundStyle(Color(red:0.40,green:0.25,blue:0.0).opacity(0.65))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.black.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24).padding(.bottom, 12)

                NavigationLink {
                    Screen5AvoidBrightLight().environmentObject(appState)
                } label: {
                    HStack(spacing: 8) {
                        Text("Done — mark as complete")
                        Image(systemName: "checkmark").fontWeight(.semibold)
                    }
                    .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [Color(red:0.75,green:0.40,blue:0.0),
                                                         Color(red:0.60,green:0.28,blue:0.0)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.20), radius: 10, y: 5)
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .onAppear { withAnimation { appeared = true } }
    }
}

// MARK: - Screen 5: Avoid Bright Light (evening — titik percabangan paling kritis)
struct Screen5AvoidBrightLight: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Dark purple-evening gradient — malam hari, jam 8 PM
            LinearGradient(colors: [Color(red:0.14,green:0.06,blue:0.25),
                                    Color(red:0.08,green:0.04,blue:0.20),
                                    Color(red:0.05,green:0.03,blue:0.18)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            // Moon decoration
            MoonDecoration()

            VStack(spacing: 0) {

                HStack(alignment: .center, spacing: 10) {
                    Label("Day 1 · 08:40 PM", systemImage: "moon.fill")
                        .font(.caption2).fontWeight(.semibold).foregroundStyle(.white.opacity(0.65))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(.white.opacity(0.10)).clipShape(Capsule())
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Circadian state").font(.system(size: 9)).foregroundStyle(.white.opacity(0.40))
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 20)

                Spacer()

                VStack(spacing: 14) {
                    Text("🌑")
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)

                    Text("Avoid bright light")
                        .font(.title).fontWeight(.bold).foregroundStyle(.white)

                    Text("Dim screens until 22:00")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.65))

                    VStack(spacing: 5) {
                        Text("Prevents your clock from shifting back")
                            .font(.caption).foregroundStyle(.white.opacity(0.55))
                        Text("Based on your circadian phase")
                            .font(.caption).foregroundStyle(.white.opacity(0.40))
                    }
                }
                .instructionCard()
                .padding(.horizontal, 24)

                Spacer()

                WhyChip(isShown: $showWhy, explanation:
                    "Light after 8 PM in your new time zone tells your brain it's still daytime, delaying melatonin and pushing your sleep window later — the opposite of what we need.")
                    .padding(.bottom, 16)

                NavDots(total: 3, current: 2).padding(.bottom, 20)

                // Up next chip
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption)
                    Text("Up next: Sleep at 22:30").font(.caption).fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.50))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.white.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24).padding(.bottom, 12)

                // MARK: Dual CTA — titik percabangan utama (followed vs deviated)
                VStack(spacing: 10) {
                    NavigationLink {
                        Screen6YourAdaptation().environmentObject(appState)
                    } label: {
                        PrimaryBtn(title: "Done — lights dimmed ✓")
                    }

                    // Secondary: trigger adaptive flow → ScreenNewA
                    NavigationLink {
                        ScreenNewA_WatchDetects().environmentObject(appState)
                    } label: {
                        Text("I can't avoid light right now")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.45))
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation { appeared = true } }
    }
}

// MARK: - Decorations

private struct SunRaysDecoration: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(LinearGradient(colors: [Color.white.opacity(0.12), .clear],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 2, height: geo.size.height * 0.4)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.12)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

private struct MoonDecoration: View {
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(Color(red:0.85,green:0.82,blue:0.95).opacity(0.06))
                .frame(width: 200).blur(radius: 30)
                .position(x: geo.size.width * 0.82, y: geo.size.height * 0.12)
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

#Preview("Screen 4") { NavigationStack { Screen4GetSunlight().environmentObject(AppState()) } }
#Preview("Screen 5") { NavigationStack { Screen5AvoidBrightLight().environmentObject(AppState()) } }
