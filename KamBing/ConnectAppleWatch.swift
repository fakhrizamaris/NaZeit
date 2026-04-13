import SwiftUI

// MARK: - Screen 1: Connect Apple Watch
// Tujuan screen ini: onboarding pertama — user mensync Apple Watch
// agar app mendapat data HRV, heart rate, dan sleep pattern secara real-time.
// Semua instruksi adaptasi circadian bergantung pada data ini.

struct ConnectAppleWatch: View {

    // @State dipakai karena isSynced adalah UI state lokal screen ini.
    // Tidak perlu dikirim ke screen lain, cukup trigger perubahan tampilan Button.
    @State private var isSynced: Bool = false

    var body: some View {

        // NavigationStack menggantikan NavigationView (deprecated iOS 16+).
        // Dipakai karena flow kita adalah Push — screen 1 → screen 2 → dst.
        // NavigationStack menyimpan navigation path secara eksplisit dan lebih predictable.
        NavigationStack {

            // VStack dipilih bukan HStack atau ZStack karena semua elemen
            // tersusun secara vertikal dari atas ke bawah, sesuai layout mid-fi.
            VStack(spacing: 0) {

                Spacer()
                    // Spacer() tanpa nilai di atas mendorong konten ke tengah secara dinamis.
                    // Tidak hardcode padding atas agar layout tetap benar di semua ukuran iPhone.

                // MARK: App Logo / Nama App
                // Text digunakan bukan Label karena Logo adalah teks murni tanpa icon sistem.
                // Di HIG, Label (SwiftUI) = kombinasi teks + SF Symbol.
                // Untuk teks tunggal standalone, Text lebih tepat.
                Text("CIRCADIAN")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    // .rounded dipilih karena memberikan kesan friendly dan modern,
                    // sesuai tone app yang bersifat personal health companion.
                    .foregroundStyle(.secondary)
                    // .secondary bukan hardcode warna — otomatis adapt ke light/dark mode.
                    // Sesuai HIG: branding tidak boleh lebih dominan dari konten utama.
                    .tracking(4)
                    // Letter spacing lebar untuk efek wordmark premium, umum di health apps.
                    .padding(.bottom, 48)

                // MARK: ImageView — Ilustrasi Apple Watch
                // Image() = ImageView di UIKit. Dipakai untuk menampilkan ikon Apple Watch
                // karena HIG menyatakan visual imagery mempercepat pemahaman konteks
                // tanpa perlu user membaca — kritis saat traveler sedang kelelahan.
                Image(systemName: "applewatch")
                    // SF Symbol dipakai bukan custom asset karena:
                    // 1. Konsisten dengan Apple ecosystem (HIG: prefer system symbols)
                    // 2. Otomatis scale dengan Dynamic Type
                    // 3. Mendukung light/dark mode tanpa extra asset
                    .font(.system(size: 72, weight: .thin))
                    // weight: .thin memberi kesan elegan dan tidak overwhelming.
                    // Size 72 cukup prominent tanpa mendominasi layar.
                    .foregroundStyle(.primary)
                    .symbolEffect(.pulse)
                    // .pulse memberikan animasi berulang halus yang mengkomunikasikan
                    // bahwa app sedang "menunggu koneksi" — feedback visual tanpa teks tambahan.
                    // Sesuai HIG: gunakan animasi yang bermakna, bukan dekoratif.
                    .padding(.bottom, 32)

                // MARK: Label — Judul Utama
                // Text dipakai sebagai pengganti UILabel karena di SwiftUI,
                // Text adalah komponen teks statis non-interaktif.
                // Sesuai HIG: Label/Text untuk informasi yang tidak perlu diedit user.
                Text("Connect Apple Watch")
                    .font(.title2)
                    // .title2 (22pt) dipilih bukan .title (28pt) agar tidak terlalu dominan.
                    // Hierarki tipografi: judul < nama app. Sesuai HIG Typography guidelines.
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 8)

                // MARK: TextView — Deskripsi Pendukung (multi-line)
                // Text multi-line ini berperan sebagai TextView di UIKit.
                // Dipakai untuk konten yang bisa berkembang (3 data points) dan perlu
                // dibaca sekilas — bukan untuk diinteraksikan.
                Text("Syncing HRV · Heart rate · Sleep patterns")
                    .font(.subheadline)
                    // .subheadline (15pt) menjaga hierarki visual di bawah judul.
                    .foregroundStyle(.secondary)
                    // .secondary memberi visual weight lebih rendah dari judul — user tahu
                    // ini supporting info, bukan instruksi utama.
                    .multilineTextAlignment(.center)
                    // .center sesuai dengan layout mid-fi di mana semua elemen centered.
                    .padding(.horizontal, 32)
                    // Padding horizontal mencegah teks terlalu melebar ke pinggir layar.
                    // HIG merekomendasikan minimum 16pt margin dari tepi — kita pakai 32 untuk
                    // kenyamanan baca.
                    .padding(.bottom, 48)

                // MARK: Button — Primary CTA "Sync Now"
                // Button adalah satu-satunya primary action di screen ini.
                // HIG mewajibkan satu primary action yang jelas per screen untuk menghindari
                // cognitive overload — traveler jet lag tidak perlu berpikir "mana yang harus saya tekan."
                Button {
                    // Action: trigger sync Apple Watch.
                    // Di implementasi nyata, ini memanggil HealthKit authorization.
                    isSynced = true
                } label: {
                    Text(isSynced ? "Connected ✓" : "Sync now")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        // maxWidth: .infinity membuat button melebar mengisi lebar container,
                        // sesuai HIG yang merekomendasikan full-width button untuk primary action
                        // agar mudah di-tap (target area besar).
                        .padding(.vertical, 16)
                        .background(
                            isSynced ? Color.green : Color.accentColor,
                            in: RoundedRectangle(cornerRadius: 14)
                            // cornerRadius 14 sesuai dengan konvensi Apple button (bukan pill shape).
                            // HIG: gunakan cornerRadius yang proporsional dengan tinggi button.
                        )
                }
                .padding(.horizontal, 24)
                // Padding 24 mengikuti HIG yang menyarankan button tidak menempel ke tepi layar.
                .padding(.bottom, 16)

                // MARK: NavigationLink — Push ke Screen 2
                // NavigationLink embedded di bawah button sebagai skip option.
                // Push transition dipakai karena flow adalah sequential/hierarkis
                // (HIG: gunakan Push untuk navigasi forward dalam hierarki yang jelas).
                NavigationLink {
                    YourTrip()
                } label: {
                    Text("Continue →")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .disabled(!isSynced)
                // .disabled mencegah user skip tanpa sync — sesuai prinsip HIG bahwa
                // setiap langkah onboarding yang kritis tidak boleh bisa di-bypass sembarangan.

                Spacer()
            }
            .navigationTitle("")
            // navigationTitle kosong di screen onboarding karena navigation bar
            // di screen pertama biasanya tidak perlu judul (HIG: kurangi chrome yang tidak perlu).
            .navigationBarHidden(true)
            // Hidden di screen 1 karena ini adalah root screen — tidak ada "back" yang perlu ditampilkan.
        }
    }
}

#Preview {
    ConnectAppleWatch()
}
