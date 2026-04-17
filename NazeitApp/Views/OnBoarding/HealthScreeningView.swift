//
//  HealthScreeningView.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 15/04/26.
//

import SwiftUI

struct ScreeningOption: Identifiable {
    let id = UUID()
    let title: String
    let isDisorder: Bool
}
let screeningOptions: [ScreeningOption] = [
    .init(title: "Insomnia Klinis", isDisorder: true),
    .init(title: "Gangguan Tidur Lansia", isDisorder: true),
    .init(title: "Pekerja Shift Malam", isDisorder: false),
    .init(title: "Tidak ada / Pola tidur normal", isDisorder: false),
]

struct HealthScreeningView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedID: UUID? = nil
    @State private var showDisclaimer = false
    
    var body: some View {
        ZStack{
            Color.bgOnboarding.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pilih Gejala yang Anda Alami")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
            }
        }
    }
}

