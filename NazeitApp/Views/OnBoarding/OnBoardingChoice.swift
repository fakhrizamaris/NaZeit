//
//  OnBoardingChoice.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 14/04/26.
//

import SwiftUI

struct OnboardingChoice: View {
    @EnvironmentObject var appState: AppState
    @State private var showContent = false
    @State private var glowAnimated = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .bgOnboarding)
                    .ignoresSafeArea()
                
                Circle ()
                    .fill(Color(uiColor: .circadianTeal)
                        .opacity(glowAnimated ? 0.12 : 0.05))
                    .frame(width: 450)
                    .blur(radius: 100)
                    .offset(y: -150)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: glowAnimated)
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 🧠 [Fase 1: Hero & Value Proposition]
                    // Sesuai Insight #1: Panduan harus sederhana dan memberikan konteks segera.
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color(uiColor: .circadianTeal).opacity(0.15))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "timer")
                                .font(.system(size: 44, weight: .light))
                                .foregroundStyle(Color(uiColor: .circadianTeal))
                                .symbolEffect(.pulse)
                        }
                        
                        VStack(spacing: 12) {
                            Text("NAZEIT")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .tracking(10)
                                .foregroundStyle(.white)
                            
                            // 🧠 [Typography: Hierarchy]
                            // Pesan utama harus menjawab Essential Question: Bagaimana beradaptasi?
                            Text("Master your biological time.")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                            
                            Text("Sederhanakan adaptasi zona waktu dengan instruksi berbasis sirkadian secara real-time.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.horizontal, 40)
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)
                    
                    Spacer()
                    
                    // 🧠 [Fase 2: Choice Cards]
                    // Memberikan dua opsi jelas berdasarkan ketersediaan wearable device.
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Mulai dengan metode data:")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 16) {
                            NavigationLink {
                                ConnectAppleWatch().environmentObject(appState)
                            } label: {
                                ChoiceCard(
                                    icon: "applewatch",
                                    title: "Wearable",
                                    subtitle: "Otomatis & Presisi",
                                    tint: Color(uiColor: .circadianTeal)
                                )
                            }
                            .simultaneousGesture(TapGesture().onEnded { appState.inputMethod = .watch })
                            
                            NavigationLink {
                                ManualSetup().environmentObject(appState)
                            } label: {
                                ChoiceCard(
                                    icon: "hand.tap.fill",
                                    title: "Manual",
                                    subtitle: "Input Jadwal",
                                    tint: Color(uiColor: .adaptOrange)
                                )
                            }
                            .simultaneousGesture(TapGesture().onEnded { appState.inputMethod = .manual })
                        }
                        .padding(.horizontal, 24)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 50)
                    
                    // 🧠 [Fase 3: Footer Privacy]
                    // Membangun kepercayaan bahwa data biologis aman di device.
                    HStack(spacing: 6) {
                        Image(systemName: "shield.checkered")
                        Text("Data kesehatan diproses secara privat di perangkat Anda.")
                    }
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
                    .padding(.top, 40)
                    .padding(.bottom, 20)
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
}

// Komponen Card Reusable
private struct ChoiceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(tint.opacity(0.3), lineWidth: 1))
    }
}


#Preview {
    OnboardingChoice().environmentObject(AppState())
}
