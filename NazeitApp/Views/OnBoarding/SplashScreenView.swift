//
//  SplashScreenView.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 17/04/26.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var animateBackground = false
    @State private var animateLogo = false
    @State private var animateText = false
    
    var body: some View {
        ZStack {
            BackgroundLayerView(animateBackground: animateBackground)
            
            VStack(spacing: 32) {
                LogoComponentView(animateLogo: animateLogo)
                TypographyComponentView(animateText: animateText)
            }
        }
        .onAppear {
            triggerAnimations()
        }
    }
    
    private func triggerAnimations() {
        withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
            animateBackground = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.3)) {
            animateLogo = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.6)) {
                animateText = true
            }
        }
    }
}

// MARK: - Components

struct BackgroundLayerView: View {
    var animateBackground: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: .bgOnboarding),
                    Color(uiColor: .systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(Color(uiColor: .nazeitTeal).opacity(animateBackground ? 0.2 : 0.05))
                .frame(width: 400)
                .blur(radius: 100)
                .offset(x: animateBackground ? 40 : -40, y: animateBackground ? -180 : -140)
            
            Circle()
                .fill(Color(uiColor: .nazeitTeal).opacity(animateBackground ? 0.15 : 0.0))
                .frame(width: 300)
                .blur(radius: 120)
                .offset(x: animateBackground ? -50 : 50, y: animateBackground ? 200 : 250)
        }
    }
}

struct LogoComponentView: View {
    var animateLogo: Bool
    
    var body: some View {
        ZStack {
            Image("NazeitLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .scaleEffect(animateLogo ? 1 : 0.4)
                .opacity(animateLogo ? 1 : 0)
        }
    }
}

struct TypographyComponentView: View {
    var animateText: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("NAZEIT")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .tracking(10)
                .foregroundStyle(Color(uiColor: .label))
                .offset(y: animateText ? 0 : 20)
                .opacity(animateText ? 1 : 0)
            
            Text("Preparing your adaptation guide")
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)
                .offset(y: animateText ? 0 : 15)
                .opacity(animateText ? 1 : 0)
        }
    }
}

#Preview {
    SplashScreenView()
}
