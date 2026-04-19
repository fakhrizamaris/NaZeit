//
//  ProgressSuccess.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//

//  ProgressSuccess.swift — KamBing
//  Screen 6: Your Adaptation — animated gradient ring, metric cards.
//  Screen 7: Fully Adapted — celebration dengan spring animation.

import SwiftUI

// MARK: - Screen 6: Your Adaptation
struct Screen6YourAdaptation: View {
    @EnvironmentObject var appState: AppState
    @State private var ringProgress: Double = 0
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header — Label
                Text("Your adaptation")
                    .font(.title2).fontWeight(.bold)
                    .padding(.top, 24).padding(.bottom, 8)

                Text("Based on your \(appState.inputMethod == .watch ? "Apple Watch data" : "sleep schedule")")
                    .font(.caption).foregroundStyle(.secondary)
                    .padding(.bottom, 32)

                // MARK: Progress Ring
                // Ring berbentuk lingkaran mewakili siklus 24 jam circadian — bukan bar linear.
                // .trim dari 0 → progress dianimasikan saat onAppear.
                // .rotationEffect(-90°) karena SwiftUI default mulai dari jam 3, bukan jam 12.
                ZStack {
                    // Track ring
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 14)
                        .frame(width: 160, height: 160)

                    // Gradient progress ring — gradasi warna mengikuti tingkat adaptasi
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(AngularGradient(
                            gradient: Gradient(colors: [
                                Color.indigo.opacity(0.7),
                                Color.cyan,
                                Color.circadianTeal
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        // .round lineCap membuat ujung arc membulat — premium detail.
                        // AngularGradient memberi gradient melingkar yang lebih ekspresif
                        // dari LinearGradient untuk ring shape.

                    // Center text
                    VStack(spacing: 2) {
                        Text("\(Int(appState.adaptationPercent * 100))%")
                            .font(.system(.largeTitle, design: .rounded).weight(.bold))
                            .foregroundStyle(.primary)
                        Text("adapted")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 32)

                // MARK: Metric Cards — data biometrik dari Watch / manual
                HStack(spacing: 12) {
                    MetricCard(value: String(format: "%.1f", appState.sleepHours) + "h",
                               label: "sleep",
                               icon: "moon.zzz.fill",
                               iconColor: Color.indigo,
                               trend: nil)
                    MetricCard(value: "\(appState.currentHRV)ms",
                               label: "HRV",
                               icon: "waveform.path",
                               iconColor: .circadianTeal,
                               trend: "↑")
                }
                .padding(.horizontal, 24).padding(.bottom, 20)

                // MARK: Motivational Label + progress bar
                VStack(spacing: 8) {
                    Text("Keep going — \(appState.daysRemaining) days left")
                        .font(.subheadline).foregroundStyle(.secondary)

                    // Linear progress bar sebagai secondary indicator
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemGray5)).frame(height: 4)
                            Capsule()
                                .fill(LinearGradient(colors: [Color.cyan, .circadianTeal],
                                                      startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * ringProgress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 32)

                Spacer()

                NavigationLink {
                    Screen7FullyAdapted().environmentObject(appState)
                } label: {
                    HStack(spacing: 8) {
                        Text("See today's next instruction")
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
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.7).delay(0.1)) { appeared = true }
            withAnimation(.easeOut(duration: 1.4).delay(0.3)) { ringProgress = appState.adaptationPercent }
        }
    }
}

// MARK: - MetricCard — komponen reusable kartu metrik
struct MetricCard: View {
    let value: String
    let label: String
    let icon: String
    let iconColor: Color
    let trend: String?

    private var trendColor: Color {
        Color(uiColor: .nazeitTeal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon pill
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon).font(.caption).foregroundStyle(iconColor)
            }
            // Value + trend
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value).font(.title3).fontWeight(.bold)
                if let t = trend {
                    Text(t).font(.caption).fontWeight(.bold).foregroundStyle(trendColor)
                }
            }
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Screen 7: Fully Adapted — celebration screen
struct Screen7FullyAdapted: View {
    @EnvironmentObject var appState: AppState
    @State private var showCheck  = false
    @State private var showText   = false
    @State private var ringScale: CGFloat = 0.4
    @State private var particlesOn = false

    var body: some View {
        ZStack {
            // Deep green gradient — warna sukses, berbeda dari semua screen sebelumnya.
            // User secara intuitif membaca warna hijau = berhasil (HIG: warna bermakna).

            // Particle burst decoration
            if particlesOn { SuccessParticles() }

            VStack(spacing: 0) {
                Spacer()

                // MARK: Success checkmark animation
                ZStack {
                    // Outer glow ring
                    Circle()
                        .fill(Color.circadianTeal.opacity(0.15))
                        .frame(width: 140)
                        .scaleEffect(ringScale)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: ringScale)

                    // Inner circle
                    Circle()
                        .fill(Color.circadianTeal.opacity(0.25))
                        .frame(width: 104)
                        .scaleEffect(showCheck ? 1.0 : 0.2)
                        .animation(.spring(response: 0.5, dampingFraction: 0.65), value: showCheck)

                    // Checkmark — SF Symbol dengan bounce animation
                    Image(systemName: "checkmark")
                        .font(.system(.largeTitle).weight(.semibold))
                        .foregroundStyle(Color.circadianTeal)
                        .scaleEffect(showCheck ? 1.0 : 0.0)
                        .opacity(showCheck ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0).delay(0.15), value: showCheck)
                }
                .padding(.bottom, 32)

                // MARK: Labels
                VStack(spacing: 8) {
                    Text("Fully adapted!")
                        .font(.title).fontWeight(.bold).foregroundStyle(.black)
                        .opacity(showText ? 1 : 0).offset(y: showText ? 0 : 12)
                        .animation(.spring(response: 0.5).delay(0.25), value: showText)

                    Text("Body clock is in sync with local time zone")
                        .font(.subheadline).foregroundStyle(.black.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1 : 0).offset(y: showText ? 0 : 8)
                        .animation(.spring(response: 0.5).delay(0.35), value: showText)

                    // Summary stats chip
                    HStack(spacing: 14) {
                        Label("3 days", systemImage: "calendar").font(.caption2)
                        Divider().frame(height: 12)
                        Label("\(appState.inputMethod == .watch ? "Watch" : "Manual") tracking", systemImage: "checkmark.circle").font(.caption2)
                    }
                    .foregroundStyle(.black.opacity(0.55))
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(.black.opacity(0.10)).clipShape(Capsule())
                    .opacity(showText ? 1 : 0).offset(y: showText ? 0 : 6)
                    .animation(.spring(response: 0.5).delay(0.45), value: showText)
                }
                .padding(.horizontal, 32)

                Spacer()

                // MARK: CTA — Plan next trip
                // Button bukan NavigationLink karena ini adalah terminal screen.
                // Di implementasi nyata: reset NavigationStack path ke root.
                Button { } label: {
                    HStack(spacing: 8) {
                        Text("Plan next trip")
                        Image(systemName: "arrow.right").fontWeight(.semibold)
                    }
                    .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                }
                .padding(.horizontal, 24)
                .opacity(showText ? 1 : 0)
                .animation(.easeOut.delay(0.6), value: showText)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        // Back button dihidden — journey selesai, tidak ada yang perlu di-undo.
        // HIG: jangan tampilkan navigasi yang tidak relevan dengan konteks.
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            withAnimation { showCheck = true; ringScale = 1.0 }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) { showText = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { particlesOn = true }
        }
    }
}

// MARK: - SuccessParticles — burst decoration on success screen
private struct SuccessParticles: View {
    let particles: [(CGFloat, CGFloat, CGFloat, Double)] = (0..<20).map { _ in
        (CGFloat.random(in: 0...1),
         CGFloat.random(in: 0.1...0.6),
         CGFloat.random(in: 3...8),
         Double.random(in: 0.1...0.5))
    }
    var body: some View {
        GeometryReader { geo in
            ForEach(particles.indices, id: \.self) { i in
                Circle()
                    .fill(Color.circadianTeal.opacity(particles[i].3))
                    .frame(width: particles[i].2, height: particles[i].2)
                    .position(x: particles[i].0 * geo.size.width,
                              y: particles[i].1 * geo.size.height)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

#Preview("Screen 6") { NavigationStack { Screen6YourAdaptation().environmentObject(AppState()) } }
#Preview("Screen 7") { NavigationStack { Screen7FullyAdapted().environmentObject(AppState()) } }
