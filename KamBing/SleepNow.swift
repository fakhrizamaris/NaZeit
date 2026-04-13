//
//  SleepNow.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//

import SwiftUI

// MARK: - Screen 3: Sleep Now (In-flight)
// Tujuan screen ini: instruksi tunggal saat user sedang di pesawat.
// Prinsip desain: 1 screen = 1 instruksi. Traveler yang kelelahan tidak boleh
// dihadapkan pada pilihan — cukup satu tindakan yang jelas.
// Data HRV rendah dari Apple Watch memicu instruksi "Sleep Now" ini.

struct Screen3SleepNow: View {

    // @State untuk toggle "Why?" explanation chip
    @State private var showWhy: Bool = false

    // @State untuk simulasi user dismiss/ignore instruksi
    // Di implementasi nyata ini dikirim ke ViewModel untuk trigger adaptive flow
    @State private var isDismissed: Bool = false

    // Simulasi data real-time dari Apple Watch
    // Di implementasi nyata: @EnvironmentObject WatchDataModel
    let circadianLevel: Double = 0.25   // 25% = low — memicu instruksi tidur
    let hoursToDestination: Int = 4
    let currentHRV: Int = 40            // ms — di bawah threshold normal

    var body: some View {
        ZStack {
            // ZStack dipakai sebagai root karena screen ini memiliki
            // background layer (warna gelap malam) dan konten layer di atasnya.
            // Tidak bisa hanya VStack karena background perlu full-screen.

            Color(.systemBackground)
                .ignoresSafeArea()
            // .ignoresSafeArea() memastikan background warna memenuhi seluruh layar
            // termasuk area di balik status bar dan home indicator.
            // HIG: background konsisten dari tepi ke tepi, jangan ada gap putih.

            VStack(spacing: 0) {

                // MARK: Phase + Circadian State Bar
                // Dua informasi kontekstual di atas: fase perjalanan dan state saat ini.
                // Tanpa ini, user tidak tahu "kenapa saya dapat instruksi ini sekarang."
                HStack(alignment: .center, spacing: 12) {

                    // Phase label chip
                    Text("In-flight")
                        .font(.caption2)
                        // .caption2 (11pt) — sekecil mungkin tapi masih terbaca.
                        // Ini adalah metadata, bukan konten utama.
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                        // Capsule = pill shape, konvensi chip/badge di iOS.
                        // User tahu ini adalah label, bukan tombol.

                    Spacer()

                    // Circadian State Bar
                    // Komponen kustom ini adalah "jantung" dari app — menunjukkan
                    // seberapa selaras jam internal tubuh user dengan zona waktu tujuan.
                    // HIG: gunakan progress indicator untuk menampilkan nilai kontinu.
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Circadian state")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)

                        CircadianStateBar(level: circadianLevel)
                        // Custom view — lihat implementasi di bawah.
                        // Dipisahkan ke view tersendiri agar reusable di semua screen
                        // (screen 4, 5 juga menggunakan bar yang sama).
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)

                Spacer()

                // MARK: Main Instruction Card
                // Satu kartu besar berisi instruksi tunggal — ini adalah core UI pattern.
                // Kartu dipakai bukan full-screen text karena:
                // 1. Memberi batas visual yang jelas antara instruksi dan metadata
                // 2. User secara intuitif tahu "ini yang harus saya lakukan"
                // 3. HIG: gunakan kartu untuk membundel konten yang terkait
                VStack(spacing: 12) {

                    // Ikon instruksi besar — ImageView dalam peran sebagai visual cue
                    Text("💤")
                        .font(.system(size: 56))
                        // Size 56 cukup prominent sebagai focal point visual.
                        // Ikon ini menyampaikan instruksi bahkan sebelum user membaca teks.
                        // HIG: visual harus mempercepat pemahaman, bukan sekadar dekorasi.

                    // Label — judul instruksi utama
                    Text("Sleep now")
                        .font(.title)
                        // .title (28pt) adalah ukuran terbesar di hierarki konten —
                        // ini adalah informasi paling penting yang harus dilihat pertama.
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    // TextView — konteks pendukung
                    Text("\(hoursToDestination) hrs to destination")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Label — alasan instruksi (koneksi ke data real-time)
                    // Ini adalah kalimat paling kritis secara konsep —
                    // membuktikan bahwa instruksi ini personal, bukan generik.
                    Text("Based on your HRV · \(currentHRV)ms")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(28)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                // .secondarySystemBackground = surface sedikit lebih gelap dari background utama.
                // HIG: gunakan system colors berlapis untuk depth tanpa hardcode hex.
                .clipShape(RoundedRectangle(cornerRadius: 20))
                // cornerRadius 20 untuk kartu besar — lebih besar dari button (14)
                // mengikuti proporsi HIG: element lebih besar = radius lebih besar.
                .padding(.horizontal, 24)

                Spacer()

                // MARK: "Why?" Expandable Chip — TextView pendukung
                // User boleh tahu alasan ilmiahnya, tapi ini opsional.
                // Tidak ditaruh di kartu utama agar tidak mengganggu simplicity.
                // HIG: progressive disclosure — tampilkan detail hanya jika diminta.
                VStack(spacing: 8) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showWhy.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(showWhy ? "Hide explanation" : "Why sleep now?")
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: showWhy ? "chevron.up" : "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if showWhy {
                        // TextView — penjelasan panjang yang bisa expand
                        Text("Your HRV is low (\(currentHRV)ms), indicating your body is in a rest-ready state. Sleeping now aligns with your destination's night cycle, advancing your circadian clock by up to 3 hours.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            // .center sesuai layout mid-fi — semua teks instruksi center-aligned.
                            .padding(.horizontal, 32)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                            // Transisi opacity + slide memberi kesan "membuka" konten
                            // — lebih natural daripada pop. HIG: animasi harus bermakna.
                    }
                }
                .padding(.bottom, 16)

                // MARK: Navigation Dots — progress indicator posisi screen
                // Titik-titik ini menunjukkan user sedang di instruksi ke berapa.
                // HIG: Page Control digunakan untuk konten yang bisa di-swipe secara lateral.
                // Di sini kita pakai dots manual karena navigasi kita adalah Push, bukan swipe.
                HStack(spacing: 8) {
                    Circle().fill(Color.accentColor).frame(width: 6, height: 6)
                    Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                    Circle().fill(Color(.systemGray4)).frame(width: 6, height: 6)
                }
                .padding(.bottom, 20)

                // MARK: Action Buttons — Followed vs Dismiss (branching point)
                // Dua tombol: confirm (followed) dan dismiss (trigger adaptive flow).
                // Ini adalah titik percabangan utama — jika dismiss, app recalculate.
                VStack(spacing: 10) {

                    // Primary action: konfirmasi user akan tidur
                    NavigationLink {
                        Screen4GetSunlight()
                        // Push ke screen 4 — user mengikuti instruksi, flow normal.
                    } label: {
                        Text("Got it — I'll sleep now")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    }

                    // Secondary action: tidak bisa / tidak mau tidur
                    // Ini memicu adaptive flow — Screen NEW C (instruksi adjusted)
                    NavigationLink {
                        ScreenNewC_InFlightDeviated()
                        // Push ke screen adaptive — app recalculate instruksi.
                        // Tidak ada "kamu gagal" — hanya instruksi baru yang disesuaikan.
                    } label: {
                        Text("Can't sleep right now")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // navigationTitle kosong — screen instruksi tidak perlu judul di nav bar.
        // Judul efektif sudah ada di kartu instruksi (Sleep Now).
        // HIG: kurangi chrome yang tidak menambah informasi.
    }
}

// MARK: - Reusable CircadianStateBar Component
// View ini dipisahkan agar bisa digunakan di Screen 3, 4, 5 tanpa duplikasi kode.
// HIG: komponen UI yang konsisten di seluruh app membantu user membangun mental model.
struct CircadianStateBar: View {
    let level: Double // 0.0 – 1.0

    // Warna berubah sesuai level — merah = misaligned, hijau = aligned
    private var barColor: Color {
        switch level {
        case 0..<0.35: return .red.opacity(0.8)
        case 0.35..<0.65: return .orange.opacity(0.8)
        default: return .green.opacity(0.8)
        }
    }

    private var stateLabel: String {
        switch level {
        case 0..<0.35: return "Low"
        case 0.35..<0.65: return "Medium"
        default: return "Aligned"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            // GeometryReader tidak dipakai — pakai frame fixed width agar predictable.
            ZStack(alignment: .leading) {
                // Track (background bar)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 6)

                // Fill (progress)
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: 60 * level, height: 6)
                    // Lebar proporsional dengan level circadian.
                    // Animation tidak ditambahkan di sini — perubahan nilai akan
                    // dianimasikan oleh parent view yang memanggil withAnimation.
            }

            Text(stateLabel)
                .font(.caption2)
                .foregroundStyle(barColor)
        }
    }
}

#Preview {
    NavigationStack {
        Screen3SleepNow()
    }
}
