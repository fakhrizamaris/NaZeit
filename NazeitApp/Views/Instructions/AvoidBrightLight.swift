//
//  AvoidBrightLight.swift
//  KamBing
//

import SwiftUI

struct Screen5AvoidBrightLight: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    var body: some View {
        ZStack {
            MoonDecoration()

            VStack(spacing: 0) {

                HStack(alignment: .center, spacing: 10) {
                    DualTimeView(localTime: "20:40", isDaytime: false)
                    
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Circadian state").font(.caption2).foregroundStyle(Color(uiColor: .secondaryLabel))
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 32)

                        VStack(spacing: 14) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: heroIconSize))
                        .foregroundStyle(Color.indigo)
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)

                    Text("Avoid bright light")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))

                    Text("Dim screens until 22:00")
                        .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))

                    VStack(spacing: 5) {
                        Text("Prevents your clock from shifting back")
                            .font(.caption).foregroundStyle(Color(uiColor: .secondaryLabel))
                        Text("Based on your circadian phase")
                            .font(.caption).foregroundStyle(Color(uiColor: .tertiaryLabel))
                    }
                }
                .instructionCard()
                .padding(.horizontal, 24)

                Spacer(minLength: 40)

                WhyChip(isShown: $showWhy, explanation:
                    "Light after 8 PM in your new time zone tells your brain it's still daytime, delaying melatonin and pushing your sleep window later — the opposite of what we need.")
                    .padding(.bottom, 16)

                NavDots(total: 3, current: 2).padding(.bottom, 20)

                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption)
                    Text("Up next: Sleep at 22:30").font(.caption).fontWeight(.medium)
                    Spacer()
                }
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24).padding(.bottom, 12)
            }
        }

        // MARK: Dual CTA
        VStack(spacing: 10) {
                    NavigationLink {
                        Screen6YourAdaptation().environmentObject(appState)
                    } label: {
                        PrimaryBtn(title: "Done — lights dimmed ✓")
                    }

                    NavigationLink {
                        ScreenNewA_WatchDetects().environmentObject(appState)
                    } label: {
                        Text("I can't avoid light right now")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation { appeared = true } }
    }
}

#Preview { NavigationStack { Screen5AvoidBrightLight().environmentObject(AppState()) } }
