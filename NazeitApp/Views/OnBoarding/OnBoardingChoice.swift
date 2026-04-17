//
//  OnBoardingChoice.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 14/04/26.
//

import SwiftUI

struct OnboardingChoice: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showContent = false
    @State private var glowAnimated = false

    private var usesVerticalCards: Bool { horizontalSizeClass == .compact }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(uiColor: .bgOnboarding),
                        Color(uiColor: .systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Circle ()
                    .fill(Color(uiColor: .circadianTeal)
                        .opacity(glowAnimated ? 0.18 : 0.08))
                    .frame(width: 450)
                    .blur(radius: 100)
                    .offset(y: -150)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: glowAnimated)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Step context membuat user langsung paham ini alur berurutan.
                        Text("Langkah 1 dari 3")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(uiColor: .secondarySystemBackground), in: Capsule())
                            .padding(.top, 12)
                            .padding(.bottom, 26)
                    
                        // Hero & value proposition
                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(Color(uiColor: .circadianTeal).opacity(0.14))
                                    .frame(width: 96, height: 96)

                                Image(systemName: "timer")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundStyle(Color(uiColor: .circadianTeal))
                                    .symbolEffect(.pulse)
                            }

                            VStack(spacing: 10) {
                                Text("NAZEIT")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .tracking(8)
                                    .foregroundStyle(Color(uiColor: .label))

                                Text("Master your biological time")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(uiColor: .label))

                                Text("Pilih sumber data Anda. Setelah itu kami susun instruksi adaptasi zona waktu secara bertahap.")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .padding(.horizontal, 28)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 24)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Pilih metode data")
                                .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.horizontal, 24)

                            Group {
                                if usesVerticalCards {
                                    VStack(spacing: 12) {
                                        watchChoice
                                        manualChoice
                                    }
                                } else {
                                    HStack(spacing: 16) {
                                        watchChoice
                                        manualChoice
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 30)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)

                        HStack(spacing: 6) {
                            Image(systemName: "shield.checkered")
                            Text("Data kesehatan diproses privat di perangkat Anda.")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .padding(.top, 28)
                        .padding(.bottom, 18)
                    }
                    .padding(.horizontal, 6)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                    showContent = true
                    glowAnimated = true
                }
            }
        }
    }

    private var watchChoice: some View {
        NavigationLink {
            ConnectAppleWatch().environmentObject(appState)
        } label: {
            ChoiceCard(
                icon: "applewatch",
                title: "Wearable",
                subtitle: "Otomatis & paling akurat",
                detail: "Sinkronkan Apple Watch dan lanjut ke setup trip.",
                tint: Color(uiColor: .circadianTeal),
                badge: "Direkomendasikan"
            )
        }
        .simultaneousGesture(TapGesture().onEnded { appState.inputMethod = .watch })
    }

    private var manualChoice: some View {
        NavigationLink {
            ManualSetup().environmentObject(appState)
        } label: {
            ChoiceCard(
                icon: "hand.tap.fill",
                title: "Manual",
                subtitle: "Tanpa wearable",
                detail: "Isi jam tidur biasa Anda secara manual.",
                tint: Color(uiColor: .adaptOrange),
                badge: "Alternatif"
            )
        }
        .simultaneousGesture(TapGesture().onEnded { appState.inputMethod = .manual })
    }
}

// Komponen Card Reusable
private struct ChoiceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let detail: String
    let tint: Color
    let badge: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(badge, systemImage: "sparkles")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(tint.opacity(0.12), in: Capsule())
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
            }

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .label))
                Text(subtitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .topLeading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(tint.opacity(0.35), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 5)
    }
}


#Preview {
    OnboardingChoice().environmentObject(AppState())
}
