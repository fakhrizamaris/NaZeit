//
//  NazeitApp.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 17/04/26.
//


import SwiftUI

@main
struct KamBingApp: App {
    @StateObject private var appState = AppState()
    var body: some Scene {
        WindowGroup {
            OnboardingChoice()
                .environmentObject(appState)
        }
    }
}
