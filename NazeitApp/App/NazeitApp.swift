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
    @State private var hasAcceptedDisclaimer = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashActive {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    OnboardingChoice()
                        .environmentObject(appState)
                        .sheet(isPresented: .constant(!hasAcceptedDisclaimer)) {
                            HealthScreeningModal(isAccepted: $hasAcceptedDisclaimer)
                                .interactiveDismissDisabled()
                        }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation { isSplashActive = false }
                }
            }
        }
    }
}
