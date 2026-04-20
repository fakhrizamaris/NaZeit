//
//  OnBoardingChoice.swift
//  NazeitApp
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
                OnboardingChoiceBackgroundView(glowAnimated: glowAnimated)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        StepIndicatorView(step: 1, totalSteps: 3)
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                        
                        HeaderSectionView()
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Select input method")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .padding(.horizontal, 24)
                            
                            Group {
                                if usesVerticalCards {
                                    VStack(spacing: 16) {
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
                        .padding(.top, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "shield.checkered")
                                .imageScale(.large)
                            Text("Your health data is processed privately on your device.")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .padding(.top, 32)
                        .padding(.bottom, 24)
                        .opacity(showContent ? 1 : 0)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                triggerApparition()
            }
        }
    }
    
    private func triggerApparition() {
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            glowAnimated = true
        }
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.5).delay(0.1)) {
            showContent = true
        }
    }
    
    private var watchChoice: some View {
        NavigationLink {
            ConnectAppleWatch().environmentObject(appState)
        } label: {
            ChoiceCard(
                icon: "applewatch",
                title: "Apple Watch",
                subtitle: "Automatic & Highly accurate",
                detail: "Sync with Apple Watch and proceed to trip setup.",
                tint: Color.teal,
                badge: "Recommended",
                badgeIcon: "star.fill"
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
                subtitle: "Without Wearable",
                detail: "Manually enter your typical sleep schedule.",
                tint: Color.indigo,
                badge: "Alternative",
                badgeIcon: "arrow.triangle.branch"
            )
        }
        .simultaneousGesture(TapGesture().onEnded { appState.inputMethod = .manual })
    }
}

// MARK: - Components

struct OnboardingChoiceBackgroundView: View {
    var glowAnimated: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: .secondarySystemBackground),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(Color.teal.opacity(glowAnimated ? 0.23 : 0.05))
                .frame(maxWidth: 400)
                .blur(radius: 120)
                .offset(x: -60, y: -180)
            
            Circle()
                .fill(Color.indigo.opacity(glowAnimated ? 0.12 : 0.03))
                .frame(maxWidth: 350)
                .blur(radius: 100)
                .offset(x: 100, y: 150)
        }
    }
}

struct StepIndicatorView: View {
    let step: Int
    let totalSteps: Int
    
    var body: some View {
        Text("Step \(step) of \(totalSteps)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color(uiColor: .secondaryLabel))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(uiColor: .tertiarySystemFill), in: Capsule())
    }
}

struct HeaderSectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Image("NazeitLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            
            VStack(spacing: 12) {
                Text("NAZEIT")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .tracking(8)
                    .foregroundStyle(Color(uiColor: .label))
                
                Text("Master your biological time")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(uiColor: .label))
                
                Text("Choose your data source. We will tailor a step-by-step time zone adaptation guide.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding(.horizontal, 28)
            }
        }
    }
}

struct ChoiceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let detail: String
    let tint: Color
    let badge: String
    let badgeIcon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Label(badge, systemImage: badgeIcon)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(tint.opacity(0.15), in: Capsule())
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(uiColor: .tertiaryLabel))
            }
            
            Spacer(minLength: 4)
            
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(tint)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .label))
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 2)
                
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(tint.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 12, y: 4)
    }
}

#Preview {
    OnboardingChoice().environmentObject(AppState())
}
