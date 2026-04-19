//
//  Instructions.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//



import SwiftUI

// MARK: - Screen 4: Get Sunlight
struct Screen4GetSunlight: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    var body: some View {
        ZStack {
            // Warm golden gradient — mengkomunikasikan "pagi / cahaya matahari"

            // Sun rays decoration
            SunRaysDecoration()

            VStack(spacing: 0) {

                // Phase chip + state bar
                // CircadianStateBar di sini onDark = false karena background terang
                //  [Materi Disorientation Relief]: Menyajikan waktu asal dan tujuan secara berdampingan (Dual Timeline) mengurangi beban kognitif pengguna yang bingung referensi "jam berapa".
                HStack(alignment: .center, spacing: 10) {
                    DualTimeView(localTime: "07:40", isDaytime: true)
                    
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Circadian state").font(.caption2).foregroundStyle(Color(uiColor: .secondaryLabel))
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 20)

                Spacer()

                // Main Instruction Card — glassmorphism di atas warm background
                VStack(spacing: 14) {
                    Text("☀️")
                        .font(.system(size: heroIconSize))
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)
                        .shadow(color: Color.bgMorning.opacity(0.6), radius: 20)

                    Text("Get sunlight")
                        .font(.title).fontWeight(.bold)
                        .foregroundStyle(Color(uiColor: .nazeitTeal))

                    Text("Go outside for 20 min")
                        .font(.subheadline).foregroundStyle(Color.teal)

                    VStack(spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "clock.badge.exclamationmark").font(.caption2)
                            Text("Best before 7:00 AM")
                                .font(.caption).fontWeight(.medium)
                        }
                        .foregroundStyle(Color.mint)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color(uiColor: .secondarySystemBackground)).clipShape(Capsule())

                        Text("Resets your body clock · Based on your circadian phase")
                            .font(.caption).foregroundStyle(Color.teal.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                // Card background — lightly tinted untuk kontras
                .padding(28).frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.05), radius: 20, y: 8)
                .padding(.horizontal, 24)

                Spacer()

                // Why chip — warna gelap untuk kontras di background terang
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.4)) { showWhy.toggle() }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "info.circle").font(.caption2)
                            Text(showWhy ? "Hide" : "Why sunlight?").font(.caption).fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down").font(.caption2)
                        }
                        .foregroundStyle(Color.teal)
                    }
                    if showWhy {
                        Text("Morning light suppresses melatonin and signals your brain it's daytime in the new time zone — the fastest way to shift your circadian clock forward.")
                            .font(.caption).foregroundStyle(Color.cyan.opacity(0.8))
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                NavDots(total: 3, current: 1).padding(.bottom, 20)

                // Up next chip
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption)
                    Text("Up next: Eat at 12:00").font(.caption).fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption2)
                }
                .foregroundStyle(Color.teal)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24).padding(.bottom, 12)

                NavigationLink {
                    Screen5AvoidBrightLight().environmentObject(appState)
                } label: {
                    HStack(spacing: 8) {
                        Text("Done — mark as complete")
                        Image(systemName: "checkmark").fontWeight(.semibold)
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

// MARK: - Screen 5: Avoid Bright Light (evening — titik percabangan paling kritis)
struct Screen5AvoidBrightLight: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false
    
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    var body: some View {
        ZStack {
            // Dark purple-evening gradient — malam hari, jam 8 PM
//            LinearGradient(colors: [Color(red:0.14,green:0.06,blue:0.25),
//                                    Color(red:0.08,green:0.04,blue:0.20),
//                                    Color(red:0.05,green:0.03,blue:0.18)],
//                           startPoint: .topLeading, endPoint: .bottomTrailing)
//                .ignoresSafeArea()

            // Moon decoration
            MoonDecoration()

            VStack(spacing: 0) {

                HStack(alignment: .center, spacing: 10) {
                    DualTimeView(localTime: "20:40", isDaytime: false)
                    
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Circadian state").font(.caption2).foregroundStyle(.black.opacity(0.40))
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 20)

                Spacer()

                VStack(spacing: 14) {
                    Text("🌑")
                        .font(.system(size: heroIconSize))
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)

                    Text("Avoid bright light")
                        .font(.title).fontWeight(.bold).foregroundStyle(Color(uiColor: .label))

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

                Spacer()

                WhyChip(isShown: $showWhy, explanation:
                    "Light after 8 PM in your new time zone tells your brain it's still daytime, delaying melatonin and pushing your sleep window later — the opposite of what we need.")
                    .padding(.bottom, 16)

                NavDots(total: 3, current: 2).padding(.bottom, 20)

                // Up next chip
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption)
                    Text("Up next: Sleep at 22:30").font(.caption).fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption2)
                }
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Color(uiColor: .secondarySystemBackground)).clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24).padding(.bottom, 12)

                // MARK: Dual CTA — titik percabangan utama (followed vs deviated)
                VStack(spacing: 10) {
                    NavigationLink {
                        Screen6YourAdaptation().environmentObject(appState)
                    } label: {
                        PrimaryBtn(title: "Done — lights dimmed ✓")
                    }

                    // Secondary: trigger adaptive flow → ScreenNewA
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

// MARK: - Decorations

private struct SunRaysDecoration: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(LinearGradient(colors: [Color(uiColor: .label).opacity(0.12), .clear],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 2, height: geo.size.height * 0.4)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.12)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

// MARK: - Dual Timeline Component
struct DualTimeView: View {
    @EnvironmentObject var appState: AppState
    let localTime: String
    let isDaytime: Bool
    
    //  [Materi Color Harmony (Analogous)]: Indigo merepresentasikan Malam/Asal, sedangkan Cyan/Teal (dan warna hangat) merepresentasikan Siang/Tujuan.
    var body: some View {
        HStack(spacing: 8) {
            // Origin Time zone
            VStack(alignment: .center, spacing: 2) {
                Text(appState.fromTimeZone.abbreviation() ?? "ORIGIN").font(.system(size: 8, weight: .bold))
                Text("19:40").font(.caption.weight(.heavy)) // Dummy converted time
            }
            .foregroundStyle(isDaytime ? .indigo : .teal)
            
            Image(systemName: "arrow.right").font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(uiColor: .quaternaryLabel))
            
            // Destination Time zone
            VStack(alignment: .center, spacing: 2) {
                Text(appState.toTimeZone.abbreviation() ?? "LOCAL").font(.system(size: 8, weight: .bold))
                Text(localTime).font(.caption.weight(.heavy))
            }
            .foregroundStyle(isDaytime ? Color(uiColor: .nazeitTeal) : Color(uiColor: .label)) // Tetap Teal untuk siang
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(Capsule())
    }
}

private struct MoonDecoration: View {
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(Color(red:0.85,green:0.82,blue:0.95).opacity(0.06))
                .frame(width: 200).blur(radius: 30)
                .position(x: geo.size.width * 0.82, y: geo.size.height * 0.12)
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

#Preview("Screen 4") { NavigationStack { Screen4GetSunlight().environmentObject(AppState()) } }
#Preview("Screen 5") { NavigationStack { Screen5AvoidBrightLight().environmentObject(AppState()) } }
