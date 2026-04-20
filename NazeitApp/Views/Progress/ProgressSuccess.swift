//
//  ProgressSuccess.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 13/04/26.
//

import SwiftUI

// MARK: - Screen 6: Your Adaptation
struct Screen6YourAdaptation: View {
    @EnvironmentObject var appState: AppState
    @State private var ringProgress: Double = 0
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Text("Your Adaptation")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(Color(uiColor: .label))
                    .padding(.top, 24).padding(.bottom, 8)
                
                Text("Based on your \(appState.inputMethod == .watch ? "Apple Watch data" : "Sleep Schedule")")
                    .font(.caption).foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding(.bottom, 32)
                
                // MARK: Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 14)
                        .frame(width: 160, height: 160)
                    
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(AngularGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.7),
                                Color.cyan,
                                Color.circadianTeal
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(Int(appState.adaptationPercent * 100))%")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .foregroundStyle(Color(uiColor: .label))
                        Text("Adapted")
                            .font(.caption).foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                }
                .padding(.bottom, 32)
                
                // MARK: Metric Cards
                HStack(spacing: 12) {
                    MetricCard(value: String(format: "%.1f", appState.sleepHours) + "h",
                               label: "Sleep",
                               icon: "moon.zzz.fill",
                               iconColor: Color.indigo,
                               trend: nil)
                    if appState.inputMethod == .watch {
                        MetricCard(value: "\(appState.currentHRV)ms",
                                   label: "HRV",
                                   icon: "waveform.path",
                                   iconColor: .circadianTeal,
                                   trend: "↑")
                    } else {
                        if appState.adaptationPercent >= 1.0 {
                            MetricCard(value: "In Sync",
                                       label: "Status",
                                       icon: "checkmark.circle.fill",
                                       iconColor: .circadianTeal,
                                       trend: nil)
                        } else {
                            MetricCard(value: "\(appState.daysRemaining)d",
                                       label: "Remaining",
                                       icon: "calendar.badge.clock",
                                       iconColor: .circadianTeal,
                                       trend: nil)
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 20)
                
                VStack(spacing: 8) {
                    if appState.adaptationPercent >= 1.0 {
                        Text("Adaptation successful")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                    } else {
                        Text("Keep going — \(appState.daysRemaining) days left")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemGray5)).frame(height: 4)
                            Capsule()
                                .fill(LinearGradient(colors: [Color.cyan, .circadianTeal],
                                                     startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * ringProgress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 32)
                
                Spacer()
                
                if appState.adaptationPercent >= 1.0 {
                    NavigationLink {
                        Screen7FullyAdapted().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("View Journey Result")
                            Image(systemName: "flag.checkered").fontWeight(.semibold)
                        }
                        .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.mint, Color(uiColor: .nazeitTeal)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.mint.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                } else if appState.travelPhase == .inflight {
                    NavigationLink {
                        Screen3SleepNow().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Start in-flight protocol")
                            Image(systemName: "airplane").fontWeight(.semibold)
                        }
                        .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                } else {
                    NavigationLink {
                        RecoveryPhaseView().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue recovery protocol")
                            Image(systemName: "figure.walk").fontWeight(.semibold)
                        }
                        .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.cyan, Color(uiColor: .nazeitTeal)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.cyan.opacity(0.20), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 32)
                }
            }
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.7).delay(0.1)) { appeared = true }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) { ringProgress = appState.adaptationPercent }
        }
    }
}


// MARK: - Screen 7: Fully Adapted
struct Screen7FullyAdapted: View {
    @EnvironmentObject var appState: AppState
    @State private var showCheck  = false
    @State private var showText   = false
    @State private var ringScale: CGFloat = 0.4
    @State private var particlesOn = false
    
    var body: some View {
        ZStack {
            if particlesOn { SuccessParticles() }
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.circadianTeal.opacity(0.15))
                        .frame(width: 140)
                        .scaleEffect(ringScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: ringScale)
                    
                    Circle()
                        .fill(Color.circadianTeal.opacity(0.25))
                        .frame(width: 104)
                        .scaleEffect(showCheck ? 1.0 : 0.2)
                        .animation(.spring(response: 0.5, dampingFraction: 0.65), value: showCheck)
                    
                    Image(systemName: "checkmark")
                        .font(.system(.largeTitle).weight(.semibold))
                        .foregroundStyle(Color.circadianTeal)
                        .scaleEffect(showCheck ? 1.0 : 0.0)
                        .opacity(showCheck ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0).delay(0.15), value: showCheck)
                }
                .padding(.bottom, 32)
                
                VStack(spacing: 8) {
                    Text("Fully adapted!")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))
                        .opacity(showText ? 1 : 0).offset(y: showText ? 0 : 12)
                        .animation(.spring(response: 0.5).delay(0.25), value: showText)
                    
                    Text("Body clock is in sync with local time zone")
                        .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1 : 0).offset(y: showText ? 0 : 8)
                        .animation(.spring(response: 0.5).delay(0.35), value: showText)
                    
                    HStack(spacing: 14) {
                        Label("3 days", systemImage: "calendar").font(.caption2)
                        Divider().frame(height: 12)
                        Label("\(appState.inputMethod == .watch ? "Watch" : "Manual") tracking", systemImage: "checkmark.circle").font(.caption2)
                    }
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color(uiColor: .secondarySystemBackground)).clipShape(Capsule())
                    .opacity(showText ? 1 : 0).offset(y: showText ? 0 : 6)
                    .animation(.spring(response: 0.5).delay(0.45), value: showText)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                NavigationLink {
                    YourTrip()
                        .environmentObject(appState)
                        .onAppear {
                            appState.fromCity = ""
                            appState.toCity = ""
                            appState.fromTimeZone = .current
                            appState.toTimeZone = .current
                            appState.departureDate = Date()
                            appState.arrivalDate = Date().addingTimeInterval(3600 * 15)
                            appState.adaptationPercent = 0.0
                            appState.daysRemaining = 3
                            appState.loadingPhaseDayIndex = 0
                            appState.recoveryPhaseDayIndex = 0
                        }
                } label: {
                    PrimaryBtn(title: "Plan next trip")
                }
                .padding(.horizontal, 24)
                .opacity(showText ? 1 : 0)
                .animation(.easeOut.delay(0.6), value: showText)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation { showCheck = true; ringScale = 1.0 }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) { showText = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { particlesOn = true }
        }
    }
}

#Preview("Screen 6") { NavigationStack { Screen6YourAdaptation().environmentObject(AppState()) } }
#Preview("Screen 7") { NavigationStack { Screen7FullyAdapted().environmentObject(AppState()) } }
