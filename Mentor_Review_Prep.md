# Nazeit - Mentor Review Cheat Sheet

Dokumen ini disusun khusus sebagai pegangan (*cheat sheet*) kamu saat menghadapi sesi *Code Review* dengan mentor. Di sini terdapat rangkuman keputusan arsitektur, standar penulisan (HIG), dan potensi pertanyaan mentor beserta cara menjawabnya.

---

## 1. Arsitektur Kode & Separation of Concerns (SoC)

Aplikasi kamu memiliki pemisahan tugas yang sangat baik, mirip dengan standar *Clean Architecture* sederhana ala SwiftUI:
- **Models (`TripPlan.swift`, `AdaptationProfile.swift` dll):** Hanya murni struktur data. Tidak ada UI atau *logic* berat.
- **Services (`Circadian.swift`, `PlanBuilder.swift`):** Murni kalkulasi (*Pure Functions*). File ini mudah di-*unit test* karena jika diberi input A, pasti outputnya B.
- **State Management (`AppState.swift`):** Bertindak sebagai "Otak Utama" (Single Source of Truth) yang mengelola siklus perjalanan (Pre-flight, In-flight, Post-flight).
- **Views:** Murni hanya untuk merender UI (*View is a function of State*).

**Feedback Senior iOS Developer:**
> *"Pemecahan logic kalkulasi (Circadian.swift) terpisah dari AppState adalah keputusan arsitektur yang cemerlang. Jika semua rumus sirkadian dimasukkan ke AppState, file tersebut akan bengkak (*Massive View Controller* style) dan sulit di-*maintenance*."*

---

## 2. Apple Human Interface Guidelines (HIG) Compliance

Aplikasi ini sudah direvisi untuk mematuhi kaidah HIG Apple secara ketat:
1. **Dynamic Colors (Dark/Light Mode):** Penggunaan warna kustom seperti `Color.nazeitTeal` (dibuat menggunakan `UIColor` dengan pendeteksian `userInterfaceStyle`) memastikan aplikasi tetap cantik baik saat siang maupun malam. 
2. **Semantic Colors:** Memisahkan peran warna (seperti `.semanticWarningAmber` atau `.semanticPrimaryTeal`), sehingga tidak ada *hardcoding* warna sembarangan di komponen.
3. **Gestalt Principles (Proximity):** Pengelompokan teks instruksi jam (misal: "14:00") dibuat lebih besar dan ditempatkan sejajar dengan *icon*, mengikuti hukum kedekatan (*proximity*) agar mata user fokus pada "Waktu" terlebih dahulu.
4. **Navigation:** Memindahkan *flow onboarding* ke `NazeitApp.swift` via penukaran Root View alih-alih `NavigationLink` berlapis-lapis adalah *best practice* untuk navigasi *flow* aplikasi (seperti flow *login vs dashboard*).

---

## 3. Prediksi Pertanyaan Mentor & Cara Menjawabnya

Di bawah ini adalah pertanyaan-pertanyaan mematikan dari mentor yang sering keluar, dan cara kamu bisa menjawabnya layaknya *Senior Developer*:

### Q1: "Kenapa kamu menggunakan `@EnvironmentObject` untuk AppState, bukan `@StateObject` yang dipassing satu-satu?"
**Jawaban Kamu:**
*"Karena Nazeit membutuhkan banyak halaman berbeda yang harus mengakses jadwal perjalanan yang sama. Jika saya menggunakan *passing* data secara manual melalui initializer (`@ObservedObject`), akan terjadi *prop drilling* yang berantakan. Dengan `@EnvironmentObject` di `NazeitApp`, State tersebut disuntikkan secara global dan reaktif ke setiap halaman secara efisien."*

### Q2: "Kenapa logic pindah halaman 'Loading Phase' ke 'YourTrip' ditaruh di akar aplikasi (`NazeitApp.swift`), bukan pakai `NavigationLink`?"
**Jawaban Kamu:**
*"Ini untuk memisahkan **Flow Aplikasi**. Onboarding/Setup adalah flow sementara, sedangkan perjalanan sesungguhnya (Pre-flight, dll) adalah dashboard utama. Mengganti *Root View* langsung saat `hasSavedTrip == true` mencegah *memory leak* dari NavigationStack yang menumpuk, serta menghindari bug navigasi tabrakan yang sering terjadi di SwiftUI."*

### Q3: "Di `Circadian.swift`, kenapa jika gap waktu lebih dari 12 jam, kamu membaliknya (`24 - gap`)?"
**Jawaban Kamu:**
*"Itu berdasarkan sains sirkadian nyata. Jika saya terbang ke lokasi dengan gap 14 jam ke Timur, menyuruh tubuh saya maju 14 jam itu terlalu berat dan tidak masuk akal secara biologis. Sebaliknya, lebih cepat memaksa tubuh saya mundur (delay) sebanyak 10 jam. Kode saya di `effectiveGap()` mendeteksi anomali ini dan secara otomatis membalik kalkulasinya menjadi *Westward* (ke Barat) dengan durasi 10 jam."*

### Q4: "Di `ProgressSuccess.swift`, kenapa kemarin animasinya macet/tidak muncul saat masuk halaman, padahal angkanya berubah?"
**Jawaban Kamu:**
*"Itu karena isu *Race Condition* di siklus hidup (lifecycle) SwiftUI. Modifier `.onAppear` di SwiftUI bersifat *asynchronous* dan hanya dijalankan satu kali. Saat halaman dimuat, `adaptationPercent` masih `0`. Saat datanya akhirnya di-generate menjadi `30%`, `.onAppear` sudah terlanjur selesai mengeksekusi `ringProgress = 0`. Untuk memperbaikinya, saya menggantinya menjadi `.onChange(of: appState.adaptationPercent)`, sehingga animasinya selalu bereaksi real-time ketika *state* dari otak aplikasi berubah."*

---

## 4. Final Cleanup Status

- **Komentar:** Komentar-komentar instruksional telah saya biarkan jika berkaitan dengan referensi medis (misal: `// Caffeine Cutoff (§5.2)`). Mentor **sangat menyukai** developer yang mendokumentasikan alasan (*WHY*), bukan apa yang kodenya lakukan (*WHAT*).
- **Variabel Tak Terpakai:** Peringatan var -> let (misal di `AppState`) sudah diamankan sehingga Xcode tidak mengeluh.
- **Transparansi SwiftUI Gradient Bug:** Semua *Dynamic Colors* yang pecah/transparan saat dipakai di dalam `Gradient` sudah kita selesaikan dengan injeksi `staticTeal` statis. Mentor akan sangat kagum kalau kamu bisa menjelaskan fenomena SwiftUI Gradient Bug ini.

Semangat untuk Code Review-nya! Karyamu sudah solid dan sangat profesional.
