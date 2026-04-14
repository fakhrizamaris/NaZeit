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
        level < 0.35 ? .red.opacity(0.85) : level < 0.65 ? .adaptOrange : .circadianTeal
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
                        colors: [Color.red.opacity(0.8), Color.adaptOrange, Color.circadianTeal],
                        startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(compact ? 4 : 5, (compact ? 52 : 64) * animated), height: compact ? 4 : 5)
            }

            Text(stateLabel)
                .font(compact ? .system(size: 10, weight: .medium) : .caption2)
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

    var body: some View {
        ZStack {
            // Dark navy — warna malam, mendukung instruksi "tidur"
            // Warna background mengkomunikasikan konteks tanpa kata-kata (HIG).
            LinearGradient(colors: [.bgNightTop, .bgNight, Color(red:0.06,green:0.04,blue:0.22)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            // Stars decoration — subtle dots untuk nuansa langit malam
            StarsBackground()

            VStack(spacing: 0) {

                // MARK: Phase chip + Circadian state bar
                HStack(alignment: .center, spacing: 10) {
                    Label("In-flight", systemImage: "airplane")
                        .font(.caption2).fontWeight(.semibold).foregroundStyle(.white.opacity(0.70))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(.white.opacity(0.10)).clipShape(Capsule())

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Circadian state").font(.system(size: 9)).foregroundStyle(.white.opacity(0.45))
                        CircadianStateBar(level: appState.circadianLevel, compact: true)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 20)

                Spacer()

                // MARK: Main Instruction Card — glassmorphism
                VStack(spacing: 14) {
                    // Emoji icon besar — ImageView equivalent
                    // Size 64 membuat instruksi terbaca bahkan sebelum membaca teks.
                    Text("💤")
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1.0 : 0.7)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: appeared)

                    Text("Sleep now")
                        .font(.title).fontWeight(.bold).foregroundStyle(.white)

                    Text("\(appState.inputMethod == .watch ? "4" : "4") hrs to destination")
                        .font(.subheadline).foregroundStyle(.white.opacity(0.65))

                    // Data attribution — koneksi ke real-time state
                    HStack(spacing: 4) {
                        Image(systemName: "applewatch").font(.caption2)
                        Text(appState.inputMethod == .watch
                             ? "Based on your HRV · \(appState.currentHRV)ms"
                             : "Based on your sleep schedule")
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(.white.opacity(0.08)).clipShape(Capsule())
                }
                .instructionCard()
                .padding(.horizontal, 24)

                Spacer()

                // MARK: Why chip — progressive disclosure (HIG)
                // Detail ilmiah tersembunyi agar tidak overwhelm user kelelahan.
                // Tap untuk expand — hanya jika user ingin tahu lebih.
                WhyChip(isShown: $showWhy, explanation:
                    "Your HRV is low (\(appState.currentHRV)ms), indicating your body is rest-ready. Sleeping now advances your circadian clock toward the destination time zone by up to 3 hours.")
                    .padding(.bottom, 16)

                // Navigation dots — progress indicator (manual, bukan PageControl,
                // karena navigasi kita Push bukan swipe lateral)
                NavDots(total: 3, current: 0)
                    .padding(.bottom, 20)

                // MARK: Dual CTA — branching point
                // Primary: followed → flow normal
                // Secondary: deviated → adaptive flow (ScreenNewC)
                VStack(spacing: 10) {
                    NavigationLink {
                        Screen4GetSunlight().environmentObject(appState)
                    } label: {
                        PrimaryBtn(title: "Got it — I'll sleep now")
                    }

                    NavigationLink {
                        ScreenNewC_InFlightDeviated().environmentObject(appState)
                    } label: {
                        Text("Can't sleep right now")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.50))
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
                    Image(systemName: "info.circle").font(.caption2)
                    Text(isShown ? "Hide explanation" : "Why this instruction?")
                        .font(.caption).fontWeight(.medium)
                    Image(systemName: isShown ? "chevron.up" : "chevron.down").font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.55))
            }
            if isShown {
                Text(explanation)
                    .font(.caption).foregroundStyle(.white.opacity(0.55))
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
                    .fill(i == current ? Color.white : Color.white.opacity(0.25))
                    .frame(width: i == current ? 7 : 5, height: i == current ? 7 : 5)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}

// StarsBackground — decorative dots untuk nuansa langit malam
private struct StarsBackground: View {
    let stars: [(CGFloat, CGFloat, CGFloat)] = (0..<40).map { _ in
        (CGFloat.random(in: 0...1), CGFloat.random(in: 0...0.6), CGFloat.random(in: 1...3))
    }
    var body: some View {
        GeometryReader { geo in
            ForEach(stars.indices, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(Double.random(in: 0.1...0.4)))
                    .frame(width: stars[i].2, height: stars[i].2)
                    .position(x: stars[i].0 * geo.size.width,
                              y: stars[i].1 * geo.size.height)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview {
    NavigationStack { Screen3SleepNow().environmentObject(AppState()) }
}
