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
    
    // State untuk mengontrol alur tampilan
    @State private var isSplashActive = true
    @State private var hasAcceptedDisclaimer = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashActive {
                    // Tampilkan Splash Screen pertama kali
                    SplashScreenView()
                        .transition(.opacity) // Efek transisi halus
                } else {
                    // Setelah Splash, masuk ke Onboarding yang dibungkus Disclaimer
                    OnboardingChoice()
                        .environmentObject(appState)
                        // Memunculkan pop-up screening secara otomatis saat masuk
                        .sheet(isPresented: .constant(!hasAcceptedDisclaimer)) {
                            HealthScreeningModal(isAccepted: $hasAcceptedDisclaimer)
                                .interactiveDismissDisabled() // User tidak bisa menutup sembarangan
                        }
                }
            }
            .onAppear {
                // Menunggu 2 detik di Splash Screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { isSplashActive = false }
                }
            }
        }
    }
}
