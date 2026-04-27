//
//  NazeitApp.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 17/04/26.
//

import SwiftUI

@main
struct NazeitApp: App {
    @StateObject var appState = AppState()
    
    @State private var isSplashActive = true
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashActive {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    if appState.hasSavedTrip {
                        NavigationStack {
                            if appState.isFullyAdapted {
                                FullyAdaptedView()
                                    .environmentObject(appState)
                            } else if appState.travelPhase == .preflight {
                                LoadingPhaseView()
                                    .environmentObject(appState)
                            } else if appState.travelPhase == .inflight {
                                SleepNowView()
                                    .environmentObject(appState)
                            } else if appState.travelPhase == .postflight {
                                RecoveryPhaseView()
                                    .environmentObject(appState)
                            }
                        }
                    } else {
                        // 💡 [Junior Developer Note]: Bypass OnboardingChoice karena opsi Apple Watch disembunyikan.
                        NavigationStack {
                            ManualSetup()
                                .environmentObject(appState)
                                .sheet(isPresented: disclaimerSheetBinding) {
                                    HealthScreeningModal(isAccepted: $hasAcceptedDisclaimer)
                                        .environmentObject(appState)
                                        .interactiveDismissDisabled()
                                }
                        }
                    }
                }
            }
            .onAppear {
                // Restore persisted state
                appState.loadFromDisk()
                
                // Request notification permission
                Task {
                    await NotificationService.shared.requestAuthorization()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { isSplashActive = false }
                }
            }
        }
    }

    private var disclaimerSheetBinding: Binding<Bool> {
        Binding(
            get: { !hasAcceptedDisclaimer },
            set: { showing in
                if !showing {
                    hasAcceptedDisclaimer = true
                }
            }
        )
    }
}
