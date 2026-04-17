//
//  SplashScreenView.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 17/04/26.
//
import SwiftUI

struct SplashScreenView: View {
    @State private var startAnimation = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: .bgOnboarding),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(uiColor: .circadianTeal).opacity(startAnimation ? 0.18 : 0.08))
                .frame(width: 380)
                .blur(radius: 90)
                .offset(y: -160)
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(uiColor: .circadianTeal).opacity(0.14))
                        .frame(width: 108, height: 108)

                    Image(systemName: "timer")
                        .font(.system(size: 48, weight: .ultraLight))
                        .foregroundStyle(Color(uiColor: .nazeitTeal))
                        .symbolEffect(.pulse, value: startAnimation)
                }

                Text("NAZEIT")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .tracking(10)
                    .foregroundStyle(Color(uiColor: .label))
                    .offset(y: startAnimation ? 0 : 16)
                    .opacity(startAnimation ? 1 : 0)

                Text("Menyiapkan panduan adaptasi Anda")
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .opacity(startAnimation ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                startAnimation = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
