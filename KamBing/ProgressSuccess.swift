//
//  ProgressSuccess.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//

import SwiftUI

// MARK: - Screen 6: Your Adaptation (Progress Tracker)
// Tujuan screen ini: menampilkan progress adaptasi circadian user secara visual.
// Kata "functional" di app statement kita diwujudkan di sini — user bisa melihat
// angka nyata bahwa tubuhnya sedang beradaptasi, bukan hanya percaya kata-kata.
// Ini juga menjadi motivasi untuk terus mengikuti instruksi.

struct Screen6YourAdaptation: View {

    // Di implementasi nyata: @EnvironmentObject CircadianViewModel
    let adaptationPercent: Double = 0.65    // 65% adapted
    let sleepHours: Double = 7.2
    let hrv: Int = 52                       // HRV naik = adaptasi berjalan baik
    let daysRemaining: Int = 2

    // @State untuk animasi progress ring saat screen pertama muncul
    @State private var animatedProgress: Double = 0.0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Screen Header — Label
                Text("Your adaptation")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.top, 24)
                    .padding(.bottom, 32)

                // MARK: Progress Ring — Custom Shape
                // Ring (circular progress) dipilih bukan linear bar karena:
                // 1. Mewakili siklus — circadian adalah konsep siklus (24 jam)
                // 2. Lebih engaging secara visual untuk metric tunggal yang penting
                // 3. HIG: gunakan visual yang sesuai dengan konsep yang direpresentasikan
                ZStack {
                    // Background ring (track)
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        // lineWidth 12 memberikan ring yang tebal dan mudah dibaca.
                        // HIG: elemen interaktif/informatif harus cukup besar untuk dilihat.
                        .frame(width: 140, height: 140)

                    // Progress ring (fill)
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        // .trim(from:to:) memotong lingkaran sesuai persentase progress.
                        // Ini adalah cara native SwiftUI untuk membuat progress arc.
                        .stroke(
                            Color.accentColor,
                            style: StrokeStyle(
                                lineWidth: 12,
                                lineCap: .round
                                // .round membuat ujung arc membulat — lebih polish,
                                // konsisten dengan iOS design language.
                            )
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        // Rotasi -90° agar progress dimulai dari posisi jam 12 (atas),
                        // bukan jam 3 (kanan). Ini adalah konvensi universal progress ring.

                    // Label di tengah ring — dua Text bersusun
                    VStack(spacing: 2) {
                        Text("\(Int(adaptationPercent * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            // Angka besar sebagai focal point — user langsung tahu statusnya
                            // tanpa perlu menganalisa visual ring.
                        Text("adapted")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 32)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.2)) {
                        animatedProgress = adaptationPercent
                    }
                    // Animasi ring saat screen muncul memberikan feedback yang memuaskan —
                    // user "melihat" progress tumbuh. HIG: gunakan animasi untuk menyampaikan
                    // perubahan state, bukan hanya estetika.
                }

                // MARK: Stats Row — Metric Cards
                // Dua kartu metrik menampilkan data biometrik dari Apple Watch.
                // Ini membuktikan bahwa instruksi "based on real-time circadian state"
                // benar-benar terjadi — ada data nyata di balik rekomendasi.
                HStack(spacing: 12) {

                    MetricCard(
                        value: String(format: "%.1f", sleepHours) + "h",
                        label: "sleep",
                        trend: nil
                    )

                    MetricCard(
                        value: "\(hrv)ms",
                        label: "HRV",
                        trend: "↑"
                        // Tanda panah naik menunjukkan HRV membaik — adaptasi berjalan.
                        // User tidak perlu tahu angka HRV normal; tanda ↑ sudah cukup.
                        // HIG: tunjukkan tren, bukan hanya nilai absolut.
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // MARK: Motivational Label
                Text("Keep going — \(daysRemaining) days left")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 32)

                Spacer()

                // MARK: Navigation Dot (single dot — progress screen bukan instructional)
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
                    .padding(.bottom, 20)

                // MARK: CTA — Lihat instruksi berikutnya
                NavigationLink {
                    Screen7FullyAdapted()
                    // Untuk demo: langsung ke screen 7.
                    // Di implementasi nyata: kembali ke instruksi aktif berikutnya.
                } label: {
                    Text("See today's next instruction")
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

// MARK: - Reusable MetricCard Component
// Komponen kartu metrik — dipisah ke view sendiri karena:
// 1. Digunakan di Screen 6 (dua kartu sejajar)
// 2. Berpotensi digunakan di screen future (history, weekly summary)
// 3. Memisahkan presentasi dari data — sesuai prinsip MVVM
struct MetricCard: View {
    let value: String
    let label: String
    let trend: String?  // Optional — tidak semua metrik punya trend indicator

    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    // .firstTextBaseline alignment agar angka dan tren sejajar baseline-nya,
                    // bukan center — lebih rapi secara tipografi.

                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                        // Hijau untuk tren positif — konvensi universal yang dipahami tanpa penjelasan.
                }
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}


// MARK: - Screen 7: Fully Adapted (Success State)
// Tujuan screen ini: konfirmasi akhir bahwa jam tubuh user sudah tersinkron
// dengan zona waktu tujuan. Ini adalah "reward" setelah user mengikuti instruksi.
// HIG: berikan feedback positif yang jelas saat user berhasil menyelesaikan goal.

struct Screen7FullyAdapted: View {

    // @State untuk animasi checkmark muncul
    @State private var showCheckmark: Bool = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // MARK: Success Visual — Checkmark dalam lingkaran
                // Lingkaran + centang adalah simbol universal "selesai/berhasil"
                // yang digunakan di seluruh iOS (contoh: Download complete, Workout ended).
                // HIG: gunakan simbol yang sudah dipahami user dari konteks lain.
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 100, height: 100)
                        // Lingkaran hijau muda sebagai background — tidak terlalu mencolok
                        // tapi tetap mengkomunikasikan warna "sukses."

                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.green)
                        .scaleEffect(showCheckmark ? 1.0 : 0.3)
                        // scaleEffect dari 0.3 → 1.0 memberikan animasi "pop" yang
                        // menyenangkan saat screen muncul. HIG: animasi success boleh
                        // lebih expressive dari animasi transisi biasa.
                        .opacity(showCheckmark ? 1.0 : 0.0)
                }
                .onAppear {
                    withAnimation(.spring(duration: 0.5, bounce: 0.4)) {
                        showCheckmark = true
                        // .spring dengan bounce menciptakan efek "bounce" saat checkmark muncul
                        // — lebih celebratory daripada easeOut biasa.
                        // bounce: 0.4 adalah nilai yang cukup terasa tanpa berlebihan.
                    }
                }
                .padding(.bottom, 28)

                // MARK: Labels — Judul dan deskripsi sukses
                Text("Fully adapted!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 8)

                Text("Body clock is in sync")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("with local time zone")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 48)

                Spacer()

                // MARK: CTA — Plan next trip
                // Button utama: kembali ke root screen untuk trip berikutnya.
                // NavigationLink dengan value kosong untuk pop ke root — di implementasi nyata
                // ini bisa menggunakan @Environment(\.dismiss) secara berulang atau
                // NavigationStack path reset.
                Button {
                    // Di implementasi nyata: reset navigation stack ke root
                    // navigationPath.removeLast(navigationPath.count)
                } label: {
                    Text("Plan next trip →")
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
        .navigationBarBackButtonHidden(true)
        // Back button disembunyikan di screen sukses — user sudah menyelesaikan journey.
        // Tidak ada yang perlu di-undo. HIG: sembunyikan navigasi yang tidak relevan
        // dengan konteks saat ini agar user tidak bingung.
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Screen 6") {
    NavigationStack { Screen6YourAdaptation() }
}

#Preview("Screen 7") {
    NavigationStack { Screen7FullyAdapted() }
}
