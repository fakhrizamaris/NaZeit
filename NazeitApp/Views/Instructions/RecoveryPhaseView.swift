//
//  RecoveryPhaseView.swift
//  NazeitApp
//

import SwiftUI

struct RecoveryPhaseView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDayIndex: Int = 0 
    @State private var navigatetoDashboard: Bool = false
    
    let offsets = [1, 2, 3] // Days AFTER arrival
    let sleepTargets = [
        "22:30 PM - 06:30 AM", 
        "22:00 PM - 06:00 AM", 
        "22:00 PM - 06:00 AM"
    ]
    let shifts = ["Arrival Day", "Recovery Day 2", "Fully Adapted"]
    
    private var baseColor: Color { Color(uiColor: .nazeitTeal) }

    private func dateString(for offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: appState.arrivalDate) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(uiColor: .secondarySystemBackground), Color(uiColor: .systemBackground)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(baseColor.opacity(0.12))
                .frame(maxWidth: 400)
                .blur(radius: 120)
                .offset(x: -80, y: -200)

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 6) {
                            Text("Post-flight Recovery")
                                .font(.system(.title2, design: .rounded).weight(.bold))
                                .foregroundStyle(Color(uiColor: .label))
                            
                            Text("You have arrived at your destination. Follow this protocol to log your circadian shift.")
                                .font(.subheadline)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 8)
                        
                        DayProgressTracker(offsets: offsets, dateProvider: dateString, selectedIndex: selectedDayIndex, activeColor: baseColor, dayLabelPrefix: "Day +")
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 24) {
                            HeroSleepTargetView(
                                title: "Tonight's Sleep Window",
                                timeRange: sleepTargets[selectedDayIndex],
                                shiftLabel: shifts[selectedDayIndex],
                                color: baseColor
                            )
                            .padding(.horizontal, 24)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Daily Protocol")
                                    .font(.system(.title3, design: .rounded).weight(.bold))
                                    .foregroundStyle(Color(uiColor: .label))
                                    .padding(.horizontal, 32)
                                
                                VStack(spacing: 12) {
                                    ProtocolCard(
                                        icon: "figure.walk", iconTint: .cyan,
                                        title: "Light Exercise", detail: "Do a light 20-min exercise under the sun at 3:00 PM."
                                    )
                                    
                                    ProtocolCard(
                                        icon: "fork.knife", iconTint: baseColor,
                                        title: "Strategic Meals", detail: "Eat heavy meals during daylight hours only."
                                    )
                                    
                                    ProtocolCard(
                                        icon: "moon.fill", iconTint: .mint,
                                        title: "Sleep Strictness", detail: "Go to bed exactly at \(sleepTargets[selectedDayIndex].prefix(5)) local time."
                                    )
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .id(selectedDayIndex)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        
                        Spacer(minLength: 24)
                    }
                }
                
                // MARK: Bottom Navigation
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if selectedDayIndex > 0 { selectedDayIndex -= 1 }
                        } 
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.headline)
                            .foregroundStyle(selectedDayIndex > 0 ? baseColor : Color(uiColor: .tertiaryLabel))
                            .frame(width: 56, height: 56)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                            .shadow(color: Color.black.opacity(selectedDayIndex > 0 ? 0.05 : 0), radius: 8, y: 4)
                    }
                    .disabled(selectedDayIndex == 0)
                    
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if selectedDayIndex < offsets.count - 1 { 
                                selectedDayIndex += 1 
                            } else {
                                navigatetoDashboard = true
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(selectedDayIndex == offsets.count - 1 ? "Start Recovery" : "Next Day")
                            if selectedDayIndex < offsets.count - 1 {
                                Image(systemName: "arrow.right")
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(selectedDayIndex == offsets.count - 1 ? .white : Color(uiColor: .label))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(selectedDayIndex == offsets.count - 1 ? baseColor : Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 100, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .background(
                    LinearGradient(
                        stops: [
                            .init(color: Color(uiColor: .systemBackground).opacity(0), location: 0),
                            .init(color: Color(uiColor: .systemBackground), location: 0.2)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $navigatetoDashboard) {
            Screen6YourAdaptation()
                .environmentObject(appState)
                .onAppear { appState.travelPhase = .postflight }
        }
    }
}

#Preview {
    NavigationStack {
        RecoveryPhaseView().environmentObject(AppState())
    }
}
