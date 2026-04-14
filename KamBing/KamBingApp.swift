//
//  KamBingApp.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 10/04/26.
//

//  KamBingApp.swift — KamBing
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
