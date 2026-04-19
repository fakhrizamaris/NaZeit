//
//  WatchDetects.swift
//  KamBing
//

import SwiftUI

struct ScreenNewA_WatchDetects: View {
    @EnvironmentObject var appState: AppState
    @State private var dotCount      = 0
    @State private var isRecalculating = true
    @State private var appeared      = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var watchIconSize: CGFloat = 44

    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.mint.opacity(0.12))
                        .frame(width: 96)
                    Image(systemName: appState.inputMethod == .watch ? "applewatch" : "bed.double.fill")
                        .font(.system(size: watchIconSize, weight: .thin))
                        .foregroundStyle(Color.mint)
                        .symbolEffect(.pulse)
                }

                VStack(spacing: 12) {
                    Text(appState.inputMethod == .watch
                         ? "Sleep detected at 01:30 AM"
                         : "Late sleep detected")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))
                        .multilineTextAlignment(.center)
                    Text(appState.inputMethod == .watch
                         ? "That's later than your recommended window (22:30)"
                         : "You slept later than your planned schedule (22:30)")
                        .font(.body).foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 36)

                if isRecalculating {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline).foregroundStyle(Color.mint)
                            .rotationEffect(.degrees(isRecalculating ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false),
                                       value: isRecalculating)
                        Text("Recalculating your plan" + String(repeating: ".", count: dotCount))
                            .font(.subheadline).foregroundStyle(Color.mint)
                      
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { t in
                            dotCount = (dotCount + 1) % 4
                            if dotCount == 0 {
                                t.invalidate()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation(.spring(response: 0.5)) { isRecalculating = false }
                                }
                            }
                        }
                    }
                }

                Spacer()

                if !isRecalculating {
                    VStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.teal)
                            Text("New plan ready").font(.caption).fontWeight(.medium).foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                        .font(.caption2)

                        NavigationLink {
                            ScreenNewB_RecalculatedInstruction().environmentObject(appState)
                        } label: {
                            PrimaryBtn(title: "See updated plan →")
                        }
                    }
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if !isRecalculating { Spacer(minLength: 32) } else { Color.clear.frame(height: 120) }
            }
        }
        .navigationTitle("Plan updated")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview { NavigationStack { ScreenNewA_WatchDetects().environmentObject(AppState()) } }
