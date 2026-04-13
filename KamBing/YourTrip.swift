//
//  YourTrip.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 10/04/26.
//

import SwiftUI

// MARK: - Screen 2: Your Trip
// Tujuan screen ini: user memasukkan data perjalanan (asal, tujuan, tanggal).
// Data ini digunakan app untuk menghitung time zone shift dan menyusun
// jadwal instruksi adaptasi circadian yang dipersonalisasi.

struct YourTrip: View {

    // MARK: - State Variables
    // Setiap @State merepresentasikan satu data input dari user.
    // @State bukan @Binding karena Screen 2 adalah owner dari data ini —
    // nanti akan di-pass ke ViewModel / environment saat user tap "Start Adapting".

    @State private var fromCity: String = ""
    // String kosong sebagai default agar TextField langsung bisa diketik
    // tanpa perlu clear dulu (HIG: jangan pre-fill input yang tidak kita ketahui).

    @State private var toCity: String = ""

    @State private var departureDate: Date = Date()
    // Date() = hari ini sebagai default yang masuk akal —
    // sebagian besar user input trip yang akan datang, bukan yang sudah lewat.

    @State private var showDatePicker: Bool = false
    // Toggle ini mengontrol visibilitas inline Date Picker.
    // Pattern ini (tap field → expand picker di bawahnya) adalah
    // konvensi iOS native yang dikenal user (HIG: gunakan familiar patterns).

    // MARK: - Computed Properties
    // timeZoneShift dihitung dari toCity — di implementasi nyata ini query ke
    // time zone database. Sekarang di-hardcode untuk demonstrasi.
    private var timeZoneShift: String {
        guard !toCity.isEmpty else { return "" }
        // Contoh: JKT → LAX = +15 jam shift
        return "+15 hr shift detected"
    }

    // Formatter untuk menampilkan tanggal di label field
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        // .medium = "Apr 10, 2026" — ringkas tapi tidak ambigu.
        // Tidak pakai .short ("4/10/26") karena bisa confusing untuk format DD/MM vs MM/DD.
        return f
    }

    var body: some View {

        // ScrollView dipilih sebagai root container karena screen ini mengandung
        // Date Picker yang bisa expand — konten bisa melebihi tinggi layar.
        // HIG: selalu antisipasi konten dinamis dengan scrollable container.
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Label — Screen Heading
                // Text sebagai heading utama, bukan NavigationTitle, karena
                // kita ingin kontrol penuh atas posisi dan styling-nya
                // sesuai desain mid-fi (tidak terpotong di navigation bar area).
                Text("Your trip")
                    .font(.largeTitle)
                    // .largeTitle (34pt) = konvensi HIG untuk heading halaman utama.
                    // Memberi hierarchy yang jelas: ini adalah judul screen, bukan section.
                    .fontWeight(.bold)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)

                // MARK: Section "From"
                // VStack per field: label di atas, TextField di bawah.
                // Pattern ini sesuai HIG Text Field guidelines:
                // label harus selalu visible (tidak sebagai placeholder saja)
                // agar user tidak lupa konteks saat sudah mulai mengetik.
                VStack(alignment: .leading, spacing: 6) {

                    // Label field — Text statis non-interaktif (bukan SwiftUI Label)
                    Text("From")
                        .font(.footnote)
                        // .footnote (13pt) untuk field label — lebih kecil dari input text
                        // agar hierarki jelas: label < input value.
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    // MARK: TextField — Input Kota Asal
                    // TextField dipilih bukan Picker karena:
                    // 1. Kota asal jumlahnya tak terbatas — Picker tidak praktis
                    // 2. User sudah tahu nama kota/bandara mereka, lebih cepat ketik
                    // 3. HIG: gunakan TextField untuk input teks bebas yang user ketahui pasti
                    TextField("e.g. Jakarta (JKT)", text: $fromCity)
                        .font(.body)
                        // .body (17pt) adalah ukuran teks standar untuk input — HIG menetapkan
                        // ini sebagai minimum agar mudah dibaca saat mengetik.
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        // .systemBackground otomatis putih di light mode, hitam di dark mode.
                        // Tidak hardcode warna agar sesuai HIG Dark Mode guidelines.
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 0.5)
                            // stroke tipis 0.5pt memberikan batas field yang subtle —
                            // tidak terlalu mencolok tapi tetap jelas sebagai input area.
                            // HIG: gunakan border ringan, bukan heavy outlined boxes.
                        )
                        .padding(.horizontal, 24)
                        .autocorrectionDisabled()
                        // Autocorrect dimatikan karena kode bandara (JKT, LAX) akan
                        // selalu di-autocorrect salah — merusak UX. HIG: disable koreksi
                        // untuk input teknis/kode.
                        .textInputAutocapitalization(.words)
                        // .words agar nama kota auto-capitalize huruf pertama tiap kata —
                        // mengurangi satu langkah bagi user.
                }
                .padding(.bottom, 16)

                // MARK: Section "To"
                // Struktur identik dengan "From" — konsistensi visual adalah prinsip utama HIG.
                // User yang sudah paham pola field "From" langsung mengerti "To" tanpa perlu belajar lagi.
                VStack(alignment: .leading, spacing: 6) {
                    Text("To")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    TextField("e.g. Los Angeles (LAX)", text: $toCity)
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                }
                .padding(.bottom, 16)

                // MARK: Section "Departure Date" — Date Picker (Pickers)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Departure date")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)

                    // Tap area untuk expand/collapse DatePicker
                    // Button dipakai bukan tap gesture agar accessible (VoiceOver bisa detect)
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showDatePicker.toggle()
                            // withAnimation agar expand/collapse picker smooth —
                            // HIG: semua perubahan UI yang signifikan perlu animasi transisi.
                        }
                        
                    } label: {
                        HStack {
                            Text(dateFormatter.string(from: departureDate))
                                .font(.body)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                // Chevron mengkomunikasikan dengan jelas bahwa field ini bisa
                                // di-expand — sesuai HIG disclosure indicator pattern.
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray5), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                    }

                    // MARK: Date Picker — Inline Picker (Pickers)
                    // DatePicker dipilih bukan TextField karena:
                    // 1. Format tanggal berbeda-beda per region (DD/MM vs MM/DD) —
                    //    DatePicker menghilangkan risiko salah format sama sekali
                    // 2. HIG secara eksplisit merekomendasikan Date Picker untuk input tanggal
                    // 3. Tanggal ini adalah basis kalkulasi time zone shift — kesalahan input
                    //    akan menyebabkan seluruh jadwal adaptasi salah
                    // displayedComponents: .date — hanya tampilkan hari/bulan/tahun,
                    // bukan waktu, karena yang relevan untuk flight adalah tanggalnya.
                    if showDatePicker {
                        DatePicker(
                            "",
                            selection: $departureDate,
                            in: Date()...,
                            // in: Date()... membatasi pilihan mulai hari ini ke depan.
                            // User tidak bisa input tanggal masa lalu — mencegah
                            // input yang tidak valid secara logika (HIG: validasi di level UI).
                            displayedComponents: .date
                        )
                        .datePickerStyle(.wheel)
                        // .wheel = scroll picker bergaya iOS native (drum roll).
                        // Dipilih bukan .graphical (kalender) karena:
                        // 1. Lebih compact — tidak memakan banyak vertical space
                        // 2. Familiar untuk user iOS (ini adalah default picker style)
                        // 3. Sesuai dengan visual mid-fi prototype yang menunjukkan
                        //    wheel-style picker (September | 17 | 2021)
                        .labelsHidden()
                        // .labelsHidden() menyembunyikan label default "Date Picker" dari Apple
                        // karena kita sudah punya label custom "Departure date" di atas.
                        // Menampilkan dua label = redundant, melanggar HIG minimalism principle.
                        .padding(.horizontal, 24)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        // Transisi opacity + slide dari atas memberi kesan picker "membuka" ke bawah.
                        // Lebih natural daripada sekadar pop in/out.
                    }
                }
                .padding(.bottom, 16)

                // MARK: Time Zone Shift Chip — Label / TextView informatif
                // Chip ini muncul setelah user mengisi destinasi, menampilkan
                // perhitungan shift otomatis. Ini adalah key differentiator app kita —
                // user langsung tahu betapa besarnya pergeseran yang akan mereka hadapi.
                if !timeZoneShift.isEmpty {
                    Text(timeZoneShift)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                        // Warna oranye mengkomunikasikan "perhatian" tanpa terasa menakutkan
                        // seperti merah. HIG: gunakan warna untuk menyampaikan makna, bukan dekorasi.
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                        // Capsule shape = pill shape, konvensi umum iOS untuk chip/badge informatif.
                        // Berbeda dari RoundedRectangle button — user tahu ini informasi, bukan tombol.
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }

                // MARK: Button — Primary CTA "Start Adapting"
                // Satu primary Button di bagian bawah screen, full-width.
                // HIG: primary action harus paling prominent dan ditempatkan
                // di posisi yang mudah dijangkau ibu jari (bawah layar).
                NavigationLink {
                    // Destination: screen instruksi pertama (Sleep Now / in-flight)
                    // Di implementasi nyata, pass data trip via ViewModel atau environment.
//                    Screen3SleepNow()
                } label: {
                    Text("Start adapting")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        // maxWidth: .infinity = full-width button.
                        // HIG: primary action button sebaiknya full-width agar mudah di-tap
                        // dan tidak ada ambiguitas "button mana yang utama."
                        .padding(.vertical, 16)
                        .background(
                            (fromCity.isEmpty || toCity.isEmpty)
                                ? Color(.systemGray4)
                                : Color.accentColor,
                            // Button disabled secara visual (abu-abu) jika belum semua field terisi.
                            // HIG: berikan feedback visual bahwa action belum bisa dilakukan —
                            // lebih baik daripada membiarkan user tap dan muncul error.
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                }
                .disabled(fromCity.isEmpty || toCity.isEmpty)
                // .disabled di level NavigationLink agar Push navigation tidak terjadi
                // sebelum data lengkap — validasi di level interaksi, bukan hanya visual.
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                // Padding bawah 40 memberi breathing room di atas home indicator.
            }
        }
        .background(Color(.systemGroupedBackground))
        // .systemGroupedBackground = abu-abu sangat muda, standar iOS untuk form/input screen.
        // Membuat kartu input (putih) terlihat mengambang di atas background —
        // visual hierarchy yang dikenal user iOS. Sesuai HIG grouped table view pattern.
        .navigationTitle("Your trip")
        // navigationTitle tetap ada untuk back button label yang benar saat navigasi ke screen 3.
        // HIG: navigation title digunakan sebagai label back button di screen berikutnya.
        .navigationBarTitleDisplayMode(.inline)
        // .inline agar judul tidak terlalu besar di navigation bar — kita sudah punya
        // large title custom di dalam ScrollView, jadi nav bar cukup .inline.
    }
}

// MARK: - Placeholder Screen 3
// Dummy destination untuk NavigationLink — akan digantikan implementasi nyata.
//struct Screen3SleepNow: View {
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("💤")
//                .font(.system(size: 64))
//            Text("Sleep Now")
//                .font(.title2)
//                .fontWeight(.semibold)
//            Text("4 hrs to destination")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//            Text("Based on your HRV")
//                .font(.caption)
//                .foregroundStyle(.tertiary)
//        }
//        .navigationTitle("In-flight")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}

#Preview {
    NavigationStack {
        YourTrip()
    }
}
