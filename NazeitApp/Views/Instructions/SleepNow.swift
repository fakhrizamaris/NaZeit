//  SleepNow.swift — KamBing
//  Screen 3: In-flight Sleep Now. Dark navy gradient, glassmorphism card.
//  Juga berisi CircadianStateBar (reusable di Screen 4, 5, adaptive).

import SwiftUI

// MARK: - Reusable CircadianStateBar
// Dipisah ke view sendiri agar Screen 3, 4, 5 dan adaptive screens
// semuanya menggunakan komponen yang identik — konsistensi (HIG).
struct CircadianStateBar: View {
    let level: Double           // 0.0 = misaligned, 1.0 = aligned
    var compact: Bool = false   // compact mode untuk header chip

    @State private var animated: Double = 0

    private var stateLabel: String {
        level < 0.35 ? "Misaligned" : level < 0.65 ? "Adjusting" : "Aligned"
    }
    private var stateColor: Color {
        level < 0.35 ? .red.opacity(0.85) : level < 0.65 ? .mint : .circadianTeal
    }

    var body: some View {
        HStack(spacing: compact ? 6 : 8) {
            // Track + fill dengan gradient red→orange→green
            // Gradient selalu penuh, tapi di-mask sesuai level — menunjukkan
            // posisi user di spektrum alignment circadian.
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5).opacity(0.6))
                    .frame(width: compact ? 52 : 64, height: compact ? 4 : 5)
                Capsule()
                    .fill(LinearGradient(
                        colors: [Color.red.opacity(0.8), Color.mint, Color.circadianTeal],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(compact ? 4 : 5, (compact ? 52 : 64) * animated), height: compact ? 4 : 5)
            }

            Text(stateLabel)
                .font(compact ? .caption2.weight(.medium) : .caption2)
                .fontWeight(.medium)
                .foregroundStyle(stateColor)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) { animated = level }
        }
        .onChange(of: level) { _, new in
            withAnimation(.spring(response: 0.6)) { animated = new }
        }
    }
}

// MARK: - Screen 3: Sleep Now (In-flight)
struct Screen3SleepNow: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy = false
    @State private var appeared = false
    
    // [HIG] ScaledMetric mengizinkan ukuran raksasa (64) tetap responsif terhadap zoom level iOS
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    var body: some View {
        ZStack {
            //  [Materi Dynamic Appearance]: Menggunakan .systemBackground agar aplikasi beradaptasi mutlak pada preferensi asali Dark/Light Mode pengguna, mengikuti pedoman HIG Accessibility.
            Color(uiColor: .systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Phase chip + Circadian state bar
                //  [Materi Navigation Context (HIG)]: Header minimalis yang menyajikan orientasi status saat ini.
                // Menggunakan huruf kapital dan spasi ekstra (tracking) pada micro-data untuk keterbacaan tingkat lanjut.
                HStack(alignment: .center) {
                    Label("In-Flight", systemImage: "airplane.circle.fill")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(Color(uiColor: .nazeitTeal))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color(uiColor: .nazeitTeal).opacity(0.12))
                        .clipShape(Capsule())

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("CIRCADIAN STATE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .tracking(1.0)
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 20)

                Spacer()

                // MARK: Main Instruction — Extreme Minimalism
                VStack(spacing: 20) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: heroIconSize))
                        .foregroundStyle(Color.indigo)
                        .scaleEffect(appeared ? 1.0 : 0.7)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appeared)

                    //  [Materi Typography Hierarchy]: Menggunakan .largeTitle untuk instruksi inti yang menyesuaikan warna label dinamis
                    Text("Sleep Now")
                        .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                        .foregroundStyle(Color(uiColor: .label))

                    Text("4 hrs to destination")
                        .font(.headline).foregroundStyle(Color(uiColor: .secondaryLabel))

                    HStack(spacing: 6) {
                        Image(systemName: appState.inputMethod == .watch ? "applewatch" : "bed.double.fill")
                            .font(.caption2).foregroundStyle(Color(uiColor: .nazeitTeal))
                        Text(appState.inputMethod == .watch
                             ? "Based on HRV · \(appState.currentHRV)ms"
                             : "Based on sleep schedule")
                            .font(.caption)
                    }
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color(uiColor: .nazeitTeal).opacity(0.1)).clipShape(Capsule())
                }
                .padding(.vertical, 40)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .secondarySystemFill), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
                .padding(.horizontal, 24)

                Spacer()

                // MARK: Why chip — progressive disclosure (HIG)
                WhyChip(isShown: $showWhy, explanation: appState.inputMethod == .watch ?
                    "Your HRV is optimal (\(appState.currentHRV)ms), indicating your body is rest-ready. Sleeping now advances your circadian clock toward the destination time zone by up to 3 hours." :
                    "Based on your usual schedule, your body's melatonin cycle is beginning. Sleeping now helps shift your circadian clock toward the destination time zone by up to 3 hours.")
                    .padding(.bottom, 16)

                // Navigation dots — progress indicator (manual, bukan PageControl,
                // karena navigasi kita Push bukan swipe lateral)
                NavDots(total: 3, current: 0)
                    .padding(.bottom, 20)

                // MARK: Dual CTA — branching point
                // Primary: followed → flow normal
                // Secondary: deviated                // MARK: Dual CTA
                VStack(spacing: 12) {
                    NavigationLink {
                        Screen4GetSunlight().environmentObject(appState)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Done — I woke up")
                            Image(systemName: "checkmark").fontWeight(.semibold)
                        }
                        .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                    }

                    NavigationLink {
                        ScreenNewC_InFlightDeviated().environmentObject(appState)
                    } label: {
                        Text("Can't sleep right now")
                            .font(.subheadline).foregroundStyle(Color(uiColor: .nazeitTeal).opacity(0.8))
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

// MARK: - Shared helper views

// WhyChip — expandable explanation chip, dipakai di Screen 3, 4, 5, adaptive
struct WhyChip: View {
    @Binding var isShown: Bool
    let explanation: String

    var body: some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isShown.toggle() }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "info.circle").font(.caption2).foregroundStyle(Color(uiColor: .nazeitTeal))
                    Text(isShown ? "Hide explanation" : "Why this instruction?")
                        .font(.caption).fontWeight(.medium)
                    Image(systemName: isShown ? "chevron.up" : "chevron.down").font(.caption2)
                }
                .foregroundStyle(Color(uiColor: .nazeitTeal))
            }
            if isShown {
                Text(explanation)
                    .font(.caption).foregroundStyle(Color(uiColor: .tertiaryLabel))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// NavDots — dots indicator posisi dalam flow instruksi
struct NavDots: View {
    let total: Int; let current: Int
    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color(uiColor: .label) : Color(uiColor: .label).opacity(0.25))
                    .frame(width: i == current ? 7 : 5, height: i == current ? 7 : 5)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}


#Preview {
    NavigationStack { Screen3SleepNow().environmentObject(AppState()) }
}
