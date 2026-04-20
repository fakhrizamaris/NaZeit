//
//  GetSunlight.swift
//  NazeitApp
//

import SwiftUI

struct Screen4GetSunlight: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                HStack(alignment: .center, spacing: 10) {
                    DualTimeView(localTime: "07:40", isDaytime: true)
                    
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("CIRCADIAN STATE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .tracking(0.5)
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 32)
                        
                        VStack(spacing: 14) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: heroIconSize))
                                .foregroundStyle(Color.orange)
                                .scaleEffect(appeared ? 1.0 : 0.6)
                                .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)
                                .shadow(color: Color.bgMorning.opacity(0.6), radius: 20)
                            
                            Text("Get sunlight")
                                .font(.system(.title, design: .rounded).weight(.bold))
                                .foregroundStyle(Color(uiColor: .label))
                            
                            Text("Go outside for 20 min")
                                .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                            
                            VStack(spacing: 5) {
                                HStack(spacing: 5) {
                                    Image(systemName: "clock.badge.exclamationmark").font(.caption)
                                    Text("Best before 7:00 AM")
                                        .font(.subheadline).fontWeight(.bold)
                                }
                                .foregroundStyle(Color.mint)
                                .padding(.horizontal, 12).padding(.vertical, 5)
                                .background(Color(uiColor: .secondarySystemBackground)).clipShape(Capsule())
                                
                                Text("Resets your body clock · Based on your circadian phase")
                                    .font(.caption).foregroundStyle(Color(uiColor: .tertiaryLabel))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(28).frame(maxWidth: .infinity)
                        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.05), radius: 20, y: 8)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                        
                        VStack(spacing: 8) {
                            Button {
                                withAnimation(.spring(response: 0.4)) { showWhy.toggle() }
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: "info.circle").font(.caption2)
                                    Text(showWhy ? "Hide" : "Why sunlight?").font(.caption).fontWeight(.medium)
                                    Image(systemName: showWhy ? "chevron.up" : "chevron.down").font(.caption2)
                                }
                                .foregroundStyle(Color.teal)
                            }
                            if showWhy {
                                Text("Morning light suppresses melatonin and signals your brain it's daytime in the new time zone — the fastest way to shift your circadian clock forward.")
                                    .font(.caption).foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.center).padding(.horizontal, 32)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.bottom, 16)
                        
                        NavDots(total: 3, current: 1).padding(.bottom, 20)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath").font(.caption)
                            Text("Up next: Eat at 12:00").font(.caption).fontWeight(.medium)
                            Spacer()
                        }
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(Color(uiColor: .secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24).padding(.bottom, 12)
                    }
                }
                
                NavigationLink {
                    Screen5AvoidBrightLight().environmentObject(appState)
                } label: {
                    HStack(spacing: 8) {
                        Text("Done — mark as complete")
                        Image(systemName: "checkmark").fontWeight(.semibold)
                    }
                    .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .onAppear { withAnimation { appeared = true } }
    }
}

#Preview { NavigationStack { Screen4GetSunlight().environmentObject(AppState()) } }
