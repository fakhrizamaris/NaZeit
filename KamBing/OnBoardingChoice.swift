//
//  OnBoardingChoice.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 14/04/26.
//

//  OnboardingChoice.swift — KamBing
//  Root screen + satu-satunya NavigationStack di seluruh app.

import SwiftUI

struct OnboardingChoice: View {
    @EnvironmentObject var appState: AppState
    @State private var showLogo  = false
    @State private var showCards = false
    @State private var showFoot  = false
    @State private var glowOn    = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient — dark navy premium
                LinearGradient(colors: [.bgOnboarding,
                                        Color(red:0.07,green:0.05,blue:0.20),
                                        Color(red:0.10,green:0.05,blue:0.25)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                // Ambient glow — memberi depth tanpa noise
                Circle()
                    .fill(Color.accentColor.opacity(glowOn ? 0.07 : 0.03))
                    .frame(width: 420)
                    .blur(radius: 90)
                    .offset(y: -60)
                    .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: glowOn)

                VStack(spacing: 0) {
                    Spacer()

                    // MARK: Hero section
                    VStack(spacing: 14) {
                        // App icon — SF Symbol palette rendering (iOS 16+)
                        ZStack {
                            Circle()
                                .fill(Color.circadianTeal.opacity(0.15))
                                .frame(width: 84, height: 84)
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 38, weight: .light))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.circadianTeal, Color.bgMorning)
                                .symbolEffect(.pulse.byLayer, options: .repeat(.continuous))
                        }
                        .padding(.bottom, 4)

                        // Wordmark — Text bukan Image karena pure text logo
                        Text("CIRCADIAN")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .tracking(6)
                            .foregroundStyle(.white)

                        Text("Stay functional across time zones")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.50))
                    }
                    .opacity(showLogo ? 1 : 0)
                    .offset(y: showLogo ? 0 : 24)

                    Spacer()

                    // MARK: Choice prompt — Label statis
                    Text("How should we read your health data?")
                        .font(.callout).fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.80))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 18)
                        .opacity(showCards ? 1 : 0)

                    // MARK: Dual Choice Cards
                    // Side-by-side NavigationLink — push ke ConnectAppleWatch atau ManualSetup
                    HStack(spacing: 14) {
                        NavigationLink {
                            ConnectAppleWatch().environmentObject(appState)
                        } label: {
                            ChoiceCard(icon: "applewatch",
                                       tint: .circadianTeal,
                                       badge: "Recommended",
                                       title: "Apple Watch",
                                       subtitle: "Auto-tracks HRV, sleep & heart rate in real-time")
                        }
                        .simultaneousGesture(TapGesture().onEnded { appState.inputMethod = .watch })

                        NavigationLink {
                            ManualSetup().environmentObject(appState)
                        } label: {
                            ChoiceCard(icon: "hand.tap.fill",
                                       tint: Color(red:0.7,green:0.5,blue:1.0),
                                       badge: nil,
                                       title: "Manual",
                                       subtitle: "Enter your sleep schedule and health info yourself")
                        }
                        .simultaneousGesture(TapGesture().onEnded { appState.inputMethod = .manual })
                    }
                    .padding(.horizontal, 24)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 28)

                    // MARK: Privacy footer — Label informatif (HIG: transparansi data)
                    HStack(spacing: 5) {
                        Image(systemName: "lock.fill").font(.caption2)
                        Text("Health data stays on device · never shared").font(.caption2)
                    }
                    .foregroundStyle(.white.opacity(0.30))
                    .padding(.top, 28)
                    .padding(.bottom, 50)
                    .opacity(showFoot ? 1 : 0)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.1)) { showLogo = true }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.40)) { showCards = true }
                withAnimation(.easeOut(duration: 0.5).delay(0.70)) { showFoot = true }
                glowOn = true
            }
        }
    }
}

// MARK: - ChoiceCard — glassmorphism card
private struct ChoiceCard: View {
    let icon: String
    let tint: Color
    let badge: String?
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon pill
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(tint.opacity(0.18))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(tint)
            }

            // Badge (optional)
            if let b = badge {
                Text(b)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.4)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(tint.opacity(0.15))
                    .clipShape(Capsule())
            }

            // Title
            Text(title)
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(.white)

            // Subtitle
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.50))
                .multilineTextAlignment(.leading)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(tint.opacity(0.25), lineWidth: 1))
    }
}

#Preview {
    OnboardingChoice().environmentObject(AppState())
}
