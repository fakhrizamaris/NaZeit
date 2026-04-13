//
//  Instructions.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//

import SwiftUI

// MARK: - Screen 4: Get Sunlight (Post-arrival, Day 1 Morning)
// Tujuan screen ini: instruksi pertama setelah landing.
// Paparan cahaya matahari pagi adalah signal terkuat untuk mereset circadian clock.
// Waktu dan durasi instruksi ini dikalkulasi dari data Apple Watch + jam tiba.
// Struktur view IDENTIK dengan Screen 3 — konsistensi pattern adalah prinsip HIG utama.

struct Screen4GetSunlight: View {

    @State private var showWhy: Bool = false

    // Simulasi data dari adaptive engine
    // Di implementasi nyata: @EnvironmentObject CircadianViewModel
    let circadianLevel: Double = 0.45   // medium — sedang dalam proses adaptasi
    let recommendedTime: String = "7:00 AM"
    let durationMinutes: Int = 20
    let upNextInstruction: String = "Eat at 12:00"

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Phase + Date + Circadian State Bar
                // Tiga metadata sekaligus: fase, tanggal, dan state.
                // Dibundel dalam satu HStack agar tidak memakan terlalu banyak vertical space.
                HStack(alignment: .center, spacing: 8) {

                    // Phase chip
                    Text("Day 1 · 07:40 AM")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())

                    Spacer()

                    // Reusable CircadianStateBar (defined in Screen3_SleepNow.swift)
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Circadian state")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        CircadianStateBar(level: circadianLevel)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                Spacer()

                // MARK: Main Instruction Card
                // Format identik Screen 3 — user tidak perlu re-learn cara membaca instruksi.
                // Hanya ikon, judul, dan detail yang berubah. Layout tetap sama.
                // HIG: konsistensi mengurangi cognitive load (user sudah tahu pola ini).
                VStack(spacing: 12) {

                    Text("☀️")
                        .font(.system(size: 56))

                    Text("Get sunlight")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("Go outside for \(durationMinutes) min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Tiga baris info: durasi, alasan, dan jam optimal
                    VStack(spacing: 4) {
                        Text("Best before \(recommendedTime)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            // Oranye untuk urgency time-sensitive — bukan merah (tidak bahaya),
                            // bukan abu (tidak biasa). HIG: warna menyampaikan makna.
                        Text("Resets your body clock")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("Based on your circadian phase")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 24)

                Spacer()

                // MARK: "Why?" Chip — Progressive Disclosure
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showWhy.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(showWhy ? "Hide explanation" : "Why sunlight?")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if showWhy {
                        Text("Morning light suppresses melatonin and signals your brain that it's daytime in the new time zone. This is the fastest way to shift your circadian clock forward.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                // MARK: Navigation Dots
                HStack(spacing: 8) {
                    Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                    Circle().fill(Color.accentColor).frame(width: 6, height: 6)
                    // Dot kedua aktif — user ada di instruksi ke-2 dari 3
                    Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                }
                .padding(.bottom, 20)

                // MARK: Up Next Preview + CTA
                // "Up next" chip memberikan preview instruksi berikutnya.
                // HIG: beri user visibility ke depan agar mereka merasa in control.
                // Ini juga memperkuat "entire travel journey" di app statement.
                VStack(spacing: 10) {

                    // Up next chip — label informatif, bukan button
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("Up next: \(upNextInstruction)")
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

                    // Primary CTA — lanjut ke screen 5
                    NavigationLink {
                        Screen5AvoidBrightLight()
                    } label: {
                        Text("Done — mark as complete")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Screen 5: Avoid Bright Light (Post-arrival, Day 1 Evening)
// Tujuan screen ini: instruksi malam hari — paparan cahaya terang sebelum tidur
// akan menunda produksi melatonin dan memperlambat adaptasi circadian.
// Ini adalah titik percabangan paling kritis — jika user ignore, adaptive flow terpicu.

struct Screen5AvoidBrightLight: View {

    @State private var showWhy: Bool = false

    let circadianLevel: Double = 0.55   // medium-high — mendekati malam, seharusnya turun
    let dimUntilTime: String = "22:00"
    let sleepTarget: String = "22:30"

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Phase + Circadian State Bar
                HStack(alignment: .center, spacing: 8) {
                    Text("Day 1 · 08:40 PM")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Circadian state")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        CircadianStateBar(level: circadianLevel)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                Spacer()

                // MARK: Main Instruction Card
                // Ikon bulan gelap (🌑) menggantikan matahari — perubahan ikon yang
                // intuitif mengkomunikasikan transisi siang → malam tanpa kata-kata.
                // HIG: gunakan visual yang memanfaatkan pengetahuan user yang sudah ada.
                VStack(spacing: 12) {

                    Text("🌑")
                        .font(.system(size: 56))

                    Text("Avoid bright light")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text("Dim screens until \(dimUntilTime)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 4) {
                        Text("Prevents clock from shifting back")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("Based on your circadian phase")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 24)

                Spacer()

                // MARK: "Why?" Chip
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showWhy.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(showWhy ? "Hide explanation" : "Why avoid light?")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if showWhy {
                        Text("Light exposure after 8 PM in your new time zone tells your brain it's still daytime, delaying melatonin production and pushing your sleep window later — the opposite of what we want.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 16)

                // MARK: Navigation Dots
                HStack(spacing: 8) {
                    Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                    Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                    Circle().fill(Color.accentColor).frame(width: 6, height: 6)
                    // Dot ketiga aktif — instruksi terakhir hari ini
                }
                .padding(.bottom, 20)

                // MARK: Up Next + Dual CTA (branching point)
                // Dua tombol — ini adalah titik percabangan terpenting di seluruh app:
                // "Done" = flow normal ke progress tracker
                // "Can't do this" = trigger adaptive flow (Screen A → B)
                VStack(spacing: 10) {

                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("Up next: Sleep at \(sleepTarget)")
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

                    // Primary: instruksi diikuti
                    NavigationLink {
                        Screen6YourAdaptation()
                    } label: {
                        Text("Done — lights dimmed")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)

                    // Secondary: instruksi tidak diikuti → adaptive flow
                    // NavigationLink bukan Button karena kita push ke screen adaptive,
                    // bukan sekadar mengubah state lokal.
                    NavigationLink {
                        ScreenNewA_WatchDetects()
                        // Adaptive screen: Watch detects misalignment → recalculate
                    } label: {
                        Text("I can't avoid light right now")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Screen 4") {
    NavigationStack { Screen4GetSunlight() }
}

#Preview("Screen 5") {
    NavigationStack { Screen5AvoidBrightLight() }
}
