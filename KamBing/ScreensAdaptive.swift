//
//  ScreensAdaptive.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//

import SwiftUI

// MARK: - Screen NEW C: In-Flight Deviation
// Dipicu ketika user menekan "Can't sleep right now" di Screen 3.
// Prinsip: app tidak menyerah dan tidak menegur — langsung kasih instruksi alternatif
// yang masih bisa menyelamatkan sebagian adaptasi circadian.
// Tone: "No problem, here's what you CAN do instead."

struct ScreenNewC_InFlightDeviated: View {

    @State private var showWhy: Bool = false

    // Data dari adaptive engine — waktu arrival digeser karena user tidak tidur
    let adjustedSleepWindow: String = "23:00 – 00:00"

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Phase + Recalculated Badge
                // Badge "⟳ Plan adjusted" adalah elemen paling penting secara konsep —
                // ini yang membuktikan app kita ADAPTIF, bukan hanya reminder statis.
                HStack(alignment: .center, spacing: 8) {

                    Text("In-flight")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())

                    Spacer()

                    // Recalculated badge — menggunakan Label (SwiftUI) yang sesungguhnya:
                    // kombinasi SF Symbol + teks. Ini adalah satu-satunya tempat di app
                    // di mana SwiftUI Label (bukan Text) paling tepat digunakan.
                    Label("Plan adjusted", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                        // Label = SF Symbol + Text dalam satu komponen.
                        // HIG: gunakan Label ketika icon dan teks selalu muncul bersama
                        // dan memiliki makna yang saling melengkapi.
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: Gentle Acknowledgment — bukan scolding
                // Satu baris teks yang mengakui situasi user tanpa menghakimi.
                // HIG: error/deviation messages harus konstruktif, bukan menyalahkan user.
                Text("Still awake? No problem.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)

                Spacer()

                // MARK: Adjusted Instruction Card
                // Format identik dengan Screen 3 — user langsung tahu ini instruksi.
                // Yang berbeda: ikon berubah dari 💤 ke 🌑, dan ada keterangan "adjusted."
                VStack(spacing: 12) {

                    Text("🌑")
                        .font(.system(size: 56))

                    Text("Dim lights now")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("Prepare body for sleep soon")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 4) {
                        // Adjusted window label — menunjukkan perubahan plan secara eksplisit
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("Sleep window: \(adjustedSleepWindow)")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        Text("Based on circadian delay")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    // Border oranye tipis membedakan kartu "adjusted" dari kartu instruksi normal.
                    // User yang perhatian akan menyadari perbedaan ini.
                )
                .padding(.horizontal, 24)

                Spacer()

                // MARK: "Why adjusted?" Chip
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) { showWhy.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Text(showWhy ? "Hide explanation" : "Why adjusted?")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if showWhy {
                        Text("Since you're not sleeping, dimming lights will still reduce light exposure and help melatonin production begin. Your sleep window has been shifted to give your body more time to prepare.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                // MARK: Single CTA — kembali ke flow normal
                NavigationLink {
                    Screen4GetSunlight()
                    // Setelah instruksi adjusted diikuti, lanjut ke Screen 4 seperti biasa.
                    // Navigation stack tetap linear — tidak ada dead end.
                } label: {
                    Text("Got it")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Screen NEW A: Watch Detects Misalignment
// Dipicu secara otomatis oleh Apple Watch ketika sleep data menunjukkan
// user tidur di luar jendela yang direkomendasikan (misal: tidur jam 01:30,
// padahal rekomendasi jam 22:30).
// Ini adalah layar "transisi" — singkat, informatif, langsung ke instruksi baru.

struct ScreenNewA_WatchDetects: View {

    // Animasi loading dots untuk "Recalculating..."
    @State private var dotCount: Int = 0
    @State private var isRecalculating: Bool = true

    // Data deteksi dari Apple Watch
    let detectedSleepTime: String = "01:30 AM"
    let recommendedSleepTime: String = "22:30"

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                // MARK: Watch Icon — ImageView
                // Menampilkan ikon Apple Watch untuk mengkomunikasikan bahwa
                // data ini BERASAL dari watch, bukan dari input manual user.
                // Kritis untuk membangun kepercayaan: "app tahu karena watch-mu memberi tahu."
                Image(systemName: "applewatch")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(.primary)
                    .symbolEffect(.pulse)
                    // .pulse — sama dengan Screen 1, tapi di sini artinya "sedang membaca data."
                    // Konsistensi penggunaan animasi = konsistensi makna. HIG: animasi harus
                    // memiliki makna yang konsisten di seluruh app.

                // MARK: Detection Info — Labels
                VStack(spacing: 8) {
                    Text("Sleep detected at \(detectedSleepTime)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text("That's later than recommended (\(recommendedSleepTime))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        // Faktual, bukan menghakimi. HIG: system messages harus deskriptif,
                        // bukan accusatory.
                }
                .padding(.horizontal, 32)

                // MARK: Recalculating Indicator
                // TextView dinamis yang menunjukkan proses recalculation sedang berjalan.
                // Ini penting untuk transparency — user tahu app sedang bekerja untuk mereka.
                if isRecalculating {
                    HStack(spacing: 4) {
                        Text("Recalculating your plan")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                        Text(String(repeating: ".", count: dotCount))
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                            .frame(width: 20, alignment: .leading)
                            // Fixed width agar teks tidak bergerak saat dot bertambah.
                    }
                    .onAppear {
                        // Animasi dots: 0 → 1 → 2 → 3 → 0, repeat
                        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                            dotCount = (dotCount + 1) % 4
                            // Setelah 2 detik, stop animasi dan navigasi ke Screen B
                            if dotCount == 0 {
                                timer.invalidate()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isRecalculating = false
                                }
                            }
                        }
                    }
                }

                Spacer()

                // MARK: CTA — Lihat instruksi yang sudah di-adjust
                // Button muncul setelah animasi recalculating selesai.
                // Tidak langsung auto-navigate karena:
                // HIG: jangan pernah melakukan navigasi otomatis tanpa user gesture —
                // user harus selalu merasa in control dari setiap perpindahan screen.
                if !isRecalculating {
                    NavigationLink {
                        ScreenNewB_RecalculatedInstruction()
                    } label: {
                        Text("See updated plan")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    .transition(.opacity)
                    // .transition(.opacity) agar button muncul dengan fade — tidak pop tiba-tiba.
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Plan updated")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Screen NEW B: Recalculated Instruction
// Instruksi yang sudah disesuaikan setelah app mendeteksi misalignment.
// Format IDENTIK dengan Screen 4 — hanya ada tambahan badge "⟳ Adjusted"
// dan konten instruksi yang telah digeser waktunya.
// Konsistensi format = user tidak bingung, langsung tahu ini instruksi yang harus diikuti.

struct ScreenNewB_RecalculatedInstruction: View {

    @State private var showWhy: Bool = false

    // Instruksi yang sudah di-adjust (geser dari 7 AM ke 9 AM karena tidur telat)
    let originalTime: String = "7 AM"
    let adjustedTime: String = "9 AM"
    let circadianLevel: Double = 0.30   // Lebih rendah dari normal karena tidur telat

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Phase + Recalculated Badge (sama dengan Screen NEW C)
                HStack(alignment: .center, spacing: 8) {

                    Text("Day 1 · 09:00 AM")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())

                    Spacer()

                    // State bar — lebih rendah karena adaptasi terganggu
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Circadian state")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        CircadianStateBar(level: circadianLevel)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // MARK: "Plan updated" banner — KUNCI VISUAL ADAPTIVE FLOW
                // Banner full-width ini adalah differentiator utama.
                // User yang melihat banner ini langsung tahu: "instruksi ini
                // dibuatkan khusus untuk situasiku, bukan jadwal generik."
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("Plan updated based on last night")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                    Spacer()
                    Text("was \(originalTime)")
                        .font(.caption2)
                        .foregroundStyle(Color.orange.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.08))
                // Background oranye sangat muda — visible tapi tidak overwhelming.
                // Strikethrough tidak dipakai karena mengacaukan readability di mobile.
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                Spacer()

                // MARK: Adjusted Instruction Card
                // Konten sama dengan Screen 4 tapi waktu sudah digeser.
                // Border oranye tipis membedakan dari instruksi normal.
                VStack(spacing: 12) {

                    Text("☀️")
                        .font(.system(size: 56))

                    Text("Get sunlight at \(adjustedTime)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("Go outside for 20 min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 4) {
                        // Badge adjusted — menunjukkan perubahan eksplisit
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("Adjusted · was \(originalTime)")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        Text("Based on your actual sleep · HRV")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    // Border oranye = visual marker bahwa ini instruksi yang sudah di-recalculate.
                    // Konsisten dengan Screen NEW C — user yang sudah lihat C akan langsung
                    // recognize pola ini sebagai "adjusted instruction."
                )
                .padding(.horizontal, 24)

                Spacer()

                // MARK: "Why adjusted?" Chip
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) { showWhy.toggle() }
                    } label: {
                        HStack(spacing: 4) {
                            Text(showWhy ? "Hide explanation" : "Why adjusted?")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if showWhy {
                        Text("Because you slept later than recommended, your circadian phase shifted. Getting sunlight at 9 AM (instead of 7 AM) still helps reset your clock, just 2 hours later than the optimal window.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                // MARK: Up Next — tetap ada meskipun instruksi adjusted
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text("Up next: Eat at 13:00 (was 12:00)")
                        // Waktu makan juga ikut bergeser — menunjukkan recalculation
                        // bukan hanya satu instruksi, tapi seluruh jadwal.
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

                // MARK: CTA — lanjut ke progress tracker
                NavigationLink {
                    Screen6YourAdaptation()
                    // Kembali ke progress tracker — flow menyatu kembali ke main flow.
                    // Adaptive branch selesai, user kembali ke journey normal.
                } label: {
                    Text("Got it — I'll do this now")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Screen NEW C") {
    NavigationStack { ScreenNewC_InFlightDeviated() }
}

#Preview("Screen NEW A") {
    NavigationStack { ScreenNewA_WatchDetects() }
}

#Preview("Screen NEW B") {
    NavigationStack { ScreenNewB_RecalculatedInstruction() }
}
