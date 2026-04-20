//
//  InFlightDeviated.swift
//  KamBing
//

import SwiftUI

enum InFlightDeviationType {
    case stayedAwake
    case fellAsleep
}

struct ScreenNewC_InFlightDeviated: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false
    
    // Allows toggling for preview/testing, in a real app this would be passed during navigation.
    var deviationType: InFlightDeviationType = .stayedAwake
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64
    
    var body: some View {
        ZStack {
            StarsBackground()
            
            VStack(spacing: 0) {
                
                // MARK: Phase chip + Adjusted badge
                HStack(spacing: 10) {
                    Label("In-Flight", systemImage: "airplane")
                        .font(.caption).fontWeight(.bold).foregroundStyle(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemBackground)).clipShape(Capsule())
                    Spacer()
                    Label("Plan adjusted", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption).fontWeight(.bold).foregroundStyle(Color.mint)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.mint.opacity(0.15)).clipShape(Capsule())
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 24)
                        
                        Text(deviationType == .stayedAwake ? "Still awake? No problem." : "Accidentally slept? It's okay.")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.bottom, 16)
                        
                        // MARK: Adjusted instruction card
                        VStack(spacing: 14) {
                            Image(systemName: deviationType == .stayedAwake ? "moon.stars.fill" : "sun.max.fill")
                                .font(.system(size: heroIconSize))
                                .foregroundStyle(deviationType == .stayedAwake ? Color.indigo : Color.orange)
                                .scaleEffect(appeared ? 1.0 : 0.6)
                                .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)
                            
                            Text(deviationType == .stayedAwake ? "Dim lights now" : "Get active & seek light")
                                .font(.system(.title, design: .rounded).weight(.bold))
                                .foregroundStyle(Color(uiColor: .label))
                            
                            Text(deviationType == .stayedAwake ? "Prepare body for sleep soon" : "Halt further sleep pressure")
                                .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                            
                            VStack(spacing: 5) {
                                HStack(spacing: 5) {
                                    Image(systemName: "arrow.triangle.2.circlepath").font(.caption)
                                    Text(deviationType == .stayedAwake ? "Sleep window: 23:00 – 00:00" : "Stay awake until 22:00").font(.subheadline).fontWeight(.bold)
                                }
                                .foregroundStyle(Color.mint)
                                .padding(.horizontal, 12).padding(.vertical, 5)
                                .background(Color.mint.opacity(0.12)).clipShape(Capsule())
                                
                                Text("Based on circadian delay")
                                    .font(.caption).foregroundStyle(Color(uiColor: .tertiaryLabel))
                            }
                        }
                        .instructionCard(isAdjusted: true)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 32)
                        
                        WhyChip(isShown: $showWhy, explanation: deviationType == .stayedAwake ?
                                "Since you're not sleeping, dimming lights still helps melatonin production begin. Your sleep window is shifted to give your body more time to prepare." :
                                    "Since you slept earlier than planned, your biological clock might try to shift backward. Getting active and seeking light now halts that process and keeps you anchored."
                        )
                        .padding(.bottom, 24)
                    }
                }
                
                NavigationLink {
                    Screen4GetSunlight().environmentObject(appState)
                } label: {
                    PrimaryBtn(title: "Got it")
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation { appeared = true } }
    }
}

#Preview("Stayed Awake") { NavigationStack { ScreenNewC_InFlightDeviated(deviationType: .stayedAwake).environmentObject(AppState()) } }

#Preview("Fell Asleep") { NavigationStack { ScreenNewC_InFlightDeviated(deviationType: .fellAsleep).environmentObject(AppState()) } }
