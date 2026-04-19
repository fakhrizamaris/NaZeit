//
//  RecalculatedInstruction.swift
//  KamBing
//

import SwiftUI

struct ScreenNewB_RecalculatedInstruction: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    let originalTime = "7 AM"
    let adjustedTime = "9 AM"

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                HStack(alignment: .center, spacing: 10) {
                    Label("Day 1 · 09:00 AM", systemImage: "sun.horizon.fill")
                        .font(.caption).fontWeight(.bold)
                        .foregroundStyle(Color.mint.opacity(0.85))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color(uiColor: .secondarySystemBackground)).clipShape(Capsule())
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("CIRCADIAN STATE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .tracking(0.5)
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 8)

                // MARK: Plan updated banner
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath").font(.caption)
                    Text("Plan updated based on last night").font(.caption).fontWeight(.medium)
                    Spacer()
                    Text("was \(originalTime)").font(.caption2).foregroundStyle(Color.mint.opacity(0.75))
                }
                .foregroundStyle(Color.mint)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color.mint.opacity(0.12))
                .overlay(Rectangle().frame(height: 0.5).foregroundStyle(Color.mint.opacity(0.3)),
                         alignment: .bottom)
                .padding(.horizontal, 24).padding(.bottom, 14)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 24)

                VStack(spacing: 14) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: heroIconSize))
                        .foregroundStyle(Color.orange)
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)
                        .shadow(color: Color.bgMorning.opacity(0.6), radius: 20)

                    Text("Get sunlight at \(adjustedTime)")
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))

                    Text("Go outside for 20 min")
                        .font(.subheadline).foregroundStyle(Color(uiColor: .secondaryLabel))

                    VStack(spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.triangle.2.circlepath").font(.caption2)
                            Text("Adjusted · was \(originalTime)").font(.caption).fontWeight(.bold)
                        }
                        .foregroundStyle(Color.mint)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color.mint.opacity(0.10)).clipShape(Capsule())

                        Text(appState.inputMethod == .watch
                             ? "Based on your actual sleep · HRV"
                             : "Based on your sleep schedule")
                            .font(.caption).foregroundStyle(Color(uiColor: .tertiaryLabel))
                    }
                }
                .padding(28).frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.mint.opacity(0.45), lineWidth: 1.5))
                .shadow(color: Color.mint.opacity(0.15), radius: 20, y: 8)
                .padding(.horizontal, 24)

                Spacer(minLength: 32)

                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.4)) { showWhy.toggle() }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "info.circle").font(.caption2)
                            Text(showWhy ? "Hide" : "Why adjusted?").font(.caption).fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down").font(.caption2)
                        }
                        .foregroundStyle(Color.teal)
                    }
                    if showWhy {
                        Text("Because you slept later, your circadian phase shifted. Sunlight at 9 AM (instead of 7 AM) still resets your clock — just 2 hours later than the optimal window.")
                            .font(.caption).foregroundStyle(Color(uiColor: .secondaryLabel))
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption)
                    Text("Up next: Eat at 13:00 (was 12:00)").font(.caption).fontWeight(.medium)
                    Spacer()
                }
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24).padding(.bottom, 12)
            }
        }

                NavigationLink {
                    Screen6YourAdaptation().environmentObject(appState)
                } label: {
                    HStack(spacing: 8) {
                        Text("Got it — I'll do this now")
                        Image(systemName: "arrow.right").fontWeight(.semibold)
                    }
                    .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .onAppear { withAnimation { appeared = true } }
    }
}

#Preview { NavigationStack { ScreenNewB_RecalculatedInstruction().environmentObject(AppState()) } }
