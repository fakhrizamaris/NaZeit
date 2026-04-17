//
//  ScreensAdaptive.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//


import SwiftUI

// MARK: - Screen NEW C: In-Flight Deviation
// Dipicu dari "Can't sleep right now" di Screen 3.
struct ScreenNewC_InFlightDeviated: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false

    var body: some View {
        ZStack {
//            // Tetap dark navy — masih in-flight, hanya instruksi berubah
//            LinearGradient(colors: [.bgNightTop, .bgNight, Color(red:0.10,green:0.05,blue:0.22)],
//                           startPoint: .topLeading, endPoint: .bottomTrailing)
//                .ignoresSafeArea()

            StarsBackground()

            VStack(spacing: 0) {

                // MARK: Phase chip + Adjusted badge
                // Label (SwiftUI) dipakai di badge — ini satu-satunya tempat
                // Label tepat digunakan (SF Symbol + teks selalu tampil bersama, HIG).
                HStack(spacing: 10) {
                    Label("In-flight", systemImage: "airplane")
                        .font(.caption2).fontWeight(.semibold).foregroundStyle(.black.opacity(0.65))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(.black.opacity(0.10)).clipShape(Capsule())
                    Spacer()
                    Label("Plan adjusted", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption2).fontWeight(.semibold).foregroundStyle(Color.adaptOrange)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.adaptOrange.opacity(0.15)).clipShape(Capsule())
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 8)

                // MARK: Gentle acknowledgment — bukan scolding
                // HIG: pesan error/deviation harus konstruktif, bukan menyalahkan.
                Text("Still awake? No problem.")
                    .font(.subheadline).foregroundStyle(.black.opacity(0.55))
                    .padding(.bottom, 16)

                Spacer()

                // MARK: Adjusted instruction card — orange border signature
                VStack(spacing: 14) {
                    Text("🌑")
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)

                    Text("Dim lights now")
                        .font(.title).fontWeight(.bold).foregroundStyle(.black)

                    Text("Prepare body for sleep soon")
                        .font(.subheadline).foregroundStyle(.black.opacity(0.65))

                    // Adjusted detail — orange indicator
                    VStack(spacing: 5) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.triangle.2.circlepath").font(.caption2)
                            Text("Sleep window: 23:00 – 00:00").font(.caption).fontWeight(.medium)
                        }
                        .foregroundStyle(Color.adaptOrange)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color.adaptOrange.opacity(0.12)).clipShape(Capsule())

                        Text("Based on circadian delay")
                            .font(.caption).foregroundStyle(.black.opacity(0.40))
                    }
                }
                .instructionCard(isAdjusted: true)
                .padding(.horizontal, 24)

                Spacer()

                // Why adjusted chip
                WhyChip(isShown: $showWhy, explanation:
                    "Since you're not sleeping, dimming lights still helps melatonin production begin. Your sleep window is shifted to give your body more time to prepare.")
                    .padding(.bottom, 24)

                NavigationLink {
                    Screen4GetSunlight().environmentObject(appState)
                } label: {
                    PrimaryBtn(title: "Got it", color: Color.adaptOrange)
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { withAnimation { appeared = true } }
    }
}


// MARK: - Screen NEW A: Watch Detects Misalignment
// Transisi screen — singkat, informatif.
// Animasi loading dots → button muncul setelah recalculation selesai.
struct ScreenNewA_WatchDetects: View {
    @EnvironmentObject var appState: AppState
    @State private var dotCount      = 0
    @State private var isRecalculating = true
    @State private var appeared      = false

    var body: some View {
        ZStack {
//            LinearGradient(colors: [Color(red:0.10,green:0.05,blue:0.20),
//                                    Color(red:0.06,green:0.03,blue:0.16)],
//                           startPoint: .top, endPoint: .bottom)
//                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // MARK: Apple Watch icon — ImageView
                // .pulse animation sama dengan Screen 1 — konsistensi makna:
                // "watch sedang aktif membaca data." (HIG: animasi bermakna konsisten)
                ZStack {
                    Circle()
                        .fill(Color.adaptOrange.opacity(0.12))
                        .frame(width: 96)
                    Image(systemName: "applewatch")
                        .font(.system(size: 44, weight: .thin))
                        .foregroundStyle(Color.adaptOrange)
                        .symbolEffect(.pulse)
                }

                // MARK: Detection info — faktual, tidak menghakimi
                VStack(spacing: 10) {
                    Text("Sleep detected at 01:30 AM")
                        .font(.headline).fontWeight(.semibold).foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                    Text("That's later than your recommended window (22:30)")
                        .font(.subheadline).foregroundStyle(.black.opacity(0.55))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 36)

                // MARK: Recalculating indicator dengan animated dots
                // Timer digunakan untuk mensimulasikan proses recalculation.
                // Di implementasi nyata: tunggu response dari circadian engine.
                if isRecalculating {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline).foregroundStyle(Color.adaptOrange)
                            .rotationEffect(.degrees(isRecalculating ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false),
                                       value: isRecalculating)
                        Text("Recalculating your plan" + String(repeating: ".", count: dotCount))
                            .font(.subheadline).foregroundStyle(Color.adaptOrange)
                            .frame(width: 240, alignment: .leading)
                            // Fixed width mencegah layout shift saat dots bertambah.
                    }
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

                // MARK: CTA — muncul setelah recalculation selesai
                // Tidak auto-navigate karena HIG: user harus in control setiap perpindahan.
                if !isRecalculating {
                    VStack(spacing: 12) {
                        // Small confirmation summary
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.teal)
                            Text("New plan ready").font(.caption).fontWeight(.medium).foregroundStyle(.black.opacity(0.70))
                        }
                        .font(.caption2)

                        NavigationLink {
                            ScreenNewB_RecalculatedInstruction().environmentObject(appState)
                        } label: {
                            PrimaryBtn(title: "See updated plan →", color: Color.adaptOrange)
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


// MARK: - Screen NEW B: Recalculated Instruction
// Format IDENTIK dengan Screen 4 — hanya ada:
// 1. Banner "Plan updated" oranye di atas
// 2. Badge "⟳ Adjusted · was 7 AM" di dalam kartu
// 3. Orange border pada kartu
// Konsistensi format = user langsung tahu ini instruksi, tidak perlu re-learn.
struct ScreenNewB_RecalculatedInstruction: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhy  = false
    @State private var appeared = false

    let originalTime = "7 AM"
    let adjustedTime = "9 AM"

    var body: some View {
        ZStack {
//            LinearGradient(colors: [Color(red:0.99,green:0.82,blue:0.35),
//                                    Color(red:0.97,green:0.65,blue:0.18),
//                                    Color(red:0.90,green:0.52,blue:0.10)],
//                           startPoint: .topLeading, endPoint: .bottomTrailing)
//                .ignoresSafeArea()

            SunRaysDecoration()

            VStack(spacing: 0) {

                // Phase chip + State bar
                HStack(alignment: .center, spacing: 10) {
                    Label("Day 1 · 09:00 AM", systemImage: "sun.horizon.fill")
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundStyle(Color(red:0.55,green:0.35,blue:0.0).opacity(0.85))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(.black.opacity(0.08)).clipShape(Capsule())
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Circadian state").font(.system(size: 9)).foregroundStyle(.black.opacity(0.40))
                        CircadianStateBar(level: 0.30, compact: true)
                        // Level lebih rendah dari Screen 4 normal karena tidur telat.
                    }
                }
                .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 8)

                // MARK: Plan updated banner — KUNCI VISUAL ADAPTIVE FLOW
                // Banner ini adalah diferensiator utama: user tahu instruksi ini
                // dibuatkan khusus untuk situasinya, bukan jadwal generik.
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath").font(.caption)
                    Text("Plan updated based on last night").font(.caption).fontWeight(.medium)
                    Spacer()
                    Text("was \(originalTime)").font(.caption2).foregroundStyle(Color.adaptOrange.opacity(0.75))
                }
                .foregroundStyle(Color.adaptOrange)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Color.adaptOrange.opacity(0.12))
                .overlay(Rectangle().frame(height: 0.5).foregroundStyle(Color.adaptOrange.opacity(0.3)),
                         alignment: .bottom)
                .padding(.horizontal, 24).padding(.bottom, 14)

                Spacer()

                // Adjusted instruction card — same format as Screen 4 + orange border
                VStack(spacing: 14) {
                    Text("☀️")
                        .font(.system(size: 64))
                        .scaleEffect(appeared ? 1.0 : 0.6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55).delay(0.1), value: appeared)
                        .shadow(color: Color.bgMorning.opacity(0.6), radius: 20)

                    Text("Get sunlight at \(adjustedTime)")
                        .font(.title).fontWeight(.bold)
                        .foregroundStyle(Color(red:0.35,green:0.20,blue:0.0))

                    Text("Go outside for 20 min")
                        .font(.subheadline).foregroundStyle(Color(red:0.45,green:0.28,blue:0.0).opacity(0.75))

                    VStack(spacing: 6) {
                        // Adjusted badge
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.triangle.2.circlepath").font(.caption2)
                            Text("Adjusted · was \(originalTime)").font(.caption).fontWeight(.medium)
                        }
                        .foregroundStyle(Color.adaptOrange)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Color.adaptOrange.opacity(0.10)).clipShape(Capsule())

                        Text("Based on your actual sleep · HRV")
                            .font(.caption).foregroundStyle(Color(red:0.45,green:0.28,blue:0.0).opacity(0.60))
                    }
                }
                .padding(28).frame(maxWidth: .infinity)
                .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.adaptOrange.opacity(0.45), lineWidth: 1.5))
                .shadow(color: Color.adaptOrange.opacity(0.15), radius: 20, y: 8)
                .padding(.horizontal, 24)

                Spacer()

                // Why adjusted chip
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.4)) { showWhy.toggle() }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "info.circle").font(.caption2)
                            Text(showWhy ? "Hide" : "Why adjusted?").font(.caption).fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down").font(.caption2)
                        }
                        .foregroundStyle(Color(red:0.35,green:0.20,blue:0.0).opacity(0.65))
                    }
                    if showWhy {
                        Text("Because you slept later, your circadian phase shifted. Sunlight at 9 AM (instead of 7 AM) still resets your clock — just 2 hours later than the optimal window.")
                            .font(.caption).foregroundStyle(Color(red:0.40,green:0.25,blue:0.0).opacity(0.65))
                            .multilineTextAlignment(.center).padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                // Up next — waktu juga ikut bergeser (seluruh jadwal di-recalculate)
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption)
                    Text("Up next: Eat at 13:00 (was 12:00)").font(.caption).fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption2)
                }
                .foregroundStyle(Color(red:0.40,green:0.25,blue:0.0).opacity(0.60))
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(.black.opacity(0.06)).clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24).padding(.bottom, 12)

                // CTA — kembali ke main flow (Screen 6)
                NavigationLink {
                    Screen6YourAdaptation().environmentObject(appState)
                } label: {
                    HStack(spacing: 8) {
                        Text("Got it — I'll do this now")
                        Image(systemName: "arrow.right").fontWeight(.semibold)
                    }
                    .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [Color(red:0.75,green:0.40,blue:0.0),
                                                         Color(red:0.60,green:0.28,blue:0.0)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.20), radius: 10, y: 5)
                }
                .padding(.horizontal, 24).padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .onAppear { withAnimation { appeared = true } }
    }
}

// SunRaysDecoration dipakai di Screen 4 dan Screen NEW B (keduanya morning context)
private struct SunRaysDecoration: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(LinearGradient(colors: [.black.opacity(0.10), .clear],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 2, height: geo.size.height * 0.35)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.12)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

private struct StarsBackground: View {
    let stars: [(CGFloat, CGFloat, CGFloat)] = (0..<40).map { _ in
        (CGFloat.random(in: 0...1), CGFloat.random(in: 0...0.6), CGFloat.random(in: 1...3))
    }
    var body: some View {
        GeometryReader { geo in
            ForEach(stars.indices, id: \.self) { i in
                Circle()
                    .fill(.black.opacity(Double.random(in: 0.08...0.35)))
                    .frame(width: stars[i].2)
                    .position(x: stars[i].0 * geo.size.width,
                              y: stars[i].1 * geo.size.height)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

#Preview("NEW C") { NavigationStack { ScreenNewC_InFlightDeviated().environmentObject(AppState()) } }
#Preview("NEW A") { NavigationStack { ScreenNewA_WatchDetects().environmentObject(AppState()) } }
#Preview("NEW B") { NavigationStack { ScreenNewB_RecalculatedInstruction().environmentObject(AppState()) } }
