//
//  InFlightDeviated.swift
//  KamBing
//

import SwiftUI

struct ScreenNewC_InFlightDeviated: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    var body: some View {
        ZStack {
            StarsBackground()

            VStack(spacing: 0) {

                // MARK: Phase chip + Adjusted badge
                HStack(spacing: 10) {
                    Label("In-Flight", systemImage: "airplane")
                        .font(.caption).fontWeight(.bold).foregroundStyle(Color(uiColor: .secondaryLabel))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemBackground)).clipShape(Capsule())
                    Spacer()
                    Label("Plan adjusted", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption).fontWeight(.bold).foregroundStyle(Color.mint)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.mint.opacity(0.15)).clipShape(Capsule())
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 24)

                        Text("Still awake? No problem.")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                            .padding(.bottom, 16)

                        // MARK: Adjusted instruction card
                VStack(spacing: 14) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: heroIconSize))
                        .foregroundStyle(Color.indigo)
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)

                    Text("Dim lights now")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))

                    Text("Prepare body for sleep soon")
                        .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))

                    VStack(spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.triangle.2.circlepath").font(.caption)
                            Text("Sleep window: 23:00 – 00:00").font(.subheadline).fontWeight(.bold)
                        }
                        .foregroundStyle(Color.mint)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color.mint.opacity(0.12)).clipShape(Capsule())

                        Text("Based on circadian delay")
                            .font(.caption).foregroundStyle(Color(uiColor: .tertiaryLabel))
                    }
                }
                .instructionCard(isAdjusted: true)
                .padding(.horizontal, 24)

                Spacer(minLength: 32)

                WhyChip(isShown: $showWhy, explanation:
                    "Since you're not sleeping, dimming lights still helps melatonin production begin. Your sleep window is shifted to give your body more time to prepare.")
                    .padding(.bottom, 24)
            }
        }

        NavigationLink {
                    Screen4GetSunlight().environmentObject(appState)
                } label: {
                    PrimaryBtn(title: "Got it")
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation { appeared = true } }
    }
}

#Preview { NavigationStack { ScreenNewC_InFlightDeviated().environmentObject(AppState()) } }
