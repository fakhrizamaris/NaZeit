# Circadian Algorithm Engine

Dokumen ini memuat rumus dan logika sirkadian *end-to-end* untuk aplikasi Nazeit, mulai dari penetapan *baseline* tubuh hingga fase *recovery* di negara tujuan.

---

## 1. Baseline & Core Definitions

Sebelum algoritma berjalan, sistem harus mengunci 3 data fundamental dari pengguna.

### A. Perhitungan Titik Nadir (CBTmin)
CBTmin (*Core Body Temperature minimum*) adalah titik referensi utama untuk semua instruksi cahaya dan tidur.
- **Mode Apple Watch:** Diambil dari titik waktu di mana metrik `Wrist Temperature` menunjukkan suhu paling rendah selama fase *Deep Sleep*.
- **Mode Manual Setup:** `CBTmin = Usual Wake Time - 2.5 Jam`.

### B. Rumus Rasio HRV (Pemantauan Real-time)
Digunakan untuk menentukan kecepatan adaptasi dan status kesembuhan.
- **Formula:** `HRV Ratio = Current HRV / 7-Day Baseline HRV Average`
- **Kondisi Sukses:** IF `HRV Ratio >= 90%` pada fase *Recovery* → Tampilkan UI "Fully Adapted".

---

## 2. Fase Pre-Flight (Loading Phase)

Tujuan: Mencicil pergeseran jam biologis sebelum pengguna terbang.

### A. Penetapan Batas Aman (The Safety Threshold)
Algoritma membatasi maksimum pergeseran per hari agar *user* tidak pusing sebelum berangkat.
- **Maksimum Shift Normal:** 1 jam (60 menit) per hari.
- **Maksimum Shift (Insomnia/Lansia/HRV Drop):** 0.5 jam (30 menit) per hari.

### B. Rumus Target Geser Harian (Daily Shift Target)
$$Shift_{daily} = \min \left( \frac{Gap_{total}}{N_{days}}, MaxShift \right)$$

- `Gap Total = Waktu CBTmin Aktual - Waktu CBTmin Target Lokal`.
- *(Di mana N adalah jumlah hari persiapan, maksimal 3 hari).*

- **Total Tabungan Adaptasi:** `Total Loading Shift = Shift_daily * N_days`.

---

## 3. Fase In-Flight (Pesawat)

Tujuan: Menyiapkan jangkar waktu (*Sleep Anchor*) yang disesuaikan dengan **Waktu Kedatangan Lokal (Arrival Time)**.

- **IF Arrival Time = 06:00 hingga 16:00 (Pagi/Siang):**
  - Instruksi: "Tidur Sekarang, Bangun 4 jam sebelum mendarat."
  - *Trigger:* Bangunkan *user* $\pm$ 4 jam sebelum mendarat (Cari fase *Light Sleep* jika memakai Apple Watch) → Instruksi "Minum Kafein & Tetap Terjaga".
- **IF Arrival Time = 18:00 hingga 05:00 (Malam):**
  - Instruksi: "Tetap terjaga di awal penerbangan, usahakan tidur di akhir penerbangan."

---

## 4. Real-time Monitoring & Skenario "Fully Adapted" (Selesai)

Aplikasi harus tahu kapan fase Recovery dihentikan dan user dinyatakan sembuh dari jet lag.

- **Jalur Apple Watch (Data-Driven):**
  Pantau rasio HRV terus-menerus. 
  IF `Current HRV / Baseline HRV >= 90%` selama 2 siklus tidur berturut-turut → Tampilkan UI "Fully Adapted".

- **Jalur Manual Setup (Time-Based Fallback):**
  Sistem menghitung `Estimasi Hari Sembuh` (jumlah hari minimum untuk menutup `Remaining Gap`) berdasarkan Rumus Kecepatan Adaptasi (0.95 atau 1.53).
  **Formula:** `Estimasi Hari Sembuh = ceil(Remaining Gap / Adaptation Rate)`.
  IF `Jumlah Hari di Tujuan >= Estimasi Hari Sembuh` → Tampilkan UI "Fully Adapted".

---

## 5. Rumus Edge Case (Gentle Mode / Mode Konservatif)

Jika user menjawab "Ya" pada `HealthScreeningModal` (memiliki gangguan tidur atau lansia), sistem mengaktifkan `isGentleMode = true`.

1. **Modifikasi Loading Phase (Batas Aman):**
   - User Normal: Maksimal Shift 1 jam/hari.
   - User Gentle Mode: Maksimal Shift hanya **0.5 jam/hari** (30 menit).

2. **Modifikasi Jeda Kafein (Caffeine Cut-off):**
   - User Normal: Alert "Stop Kopi" pada Target Tidur Lokal - 8 Jam.
   - User Gentle Mode: Alert "Stop Kopi" pada Target Tidur Lokal - **12 Jam**.

3. **Modifikasi Ambang Batas Darurat (Safety Override):**
   - **Jalur Apple Watch:**
     - Normal: Picu peringatan istirahat jika HRV drop >= 15%.
     - Gentle Mode: Picu peringatan istirahat jika HRV drop >= 10% (lebih sensitif).
   - **Jalur Manual Setup:**
     - Karena tidak ada data HRV, sediakan tombol manual "Saya terlalu lelah" di Dashboard. Jika ditekan, kurangi beban adaptasi hari itu menjadi 0 (biarkan user tidur bebas).

Berdasarkan nilai `Remaining Gap` dan arah penerbangan akhir (*setelah dicek oleh Aturan 12 Jam*).

- **Aturan 12 Jam (Normalisasi Arah):**
  Jika `|Time Zone Gap| > 12 jam`, gunakan `Adjusted Gap = 24 - |Time Zone Gap|` lalu balik arah pergeseran (eastward <-> westward) agar sistem memilih jalur adaptasi paling pendek.

### A. Penerbangan ke Timur (Eastward)
- **Tujuan:** Phase Advance (Memajukan jam biologis).
- **Kecepatan Adaptasi Tubuh:** 0.95 jam per hari.
- **Estimasi Hari Sembuh:** `Hari = ceil(Remaining Gap / 0.95)`
- **Logika Intervensi Cahaya (Light Rules):**
  - IF Waktu = CBTmin hingga (CBTmin + 4 jam) → TRIGGER: "SEEK LIGHT"
  - IF Waktu = (CBTmin - 3 jam) hingga CBTmin → TRIGGER: "AVOID LIGHT"

### B. Penerbangan Ke Barat (Westward)
- **Tujuan:** Phase Delay (Memundurkan jam biologis).
- **Kecepatan Adaptasi Tubuh:** 1.53 jam per hari.
- **Estimasi Hari Sembuh:** `Hari = ceil(Remaining Gap / 1.53)`
- **Logika Intervensi Cahaya (Light Rules):**
  - IF Waktu = (CBTmin - 4 jam) hingga CBTmin → TRIGGER: "SEEK LIGHT"
  - IF Waktu = CBTmin hingga (CBTmin + 3 jam) → TRIGGER: "AVOID LIGHT"

---

## 6. Rumus Edge Case (Modifikasi Insomnia)

Jika pada *Screening* awal pengguna terdeteksi memiliki gangguan tidur (Insomnia), sistem melakukan *override* (penyesuaian darurat):

1. **Modifikasi Jeda Kafein (Caffeine Cut-off):**
   - User Normal: `Target Tidur Lokal - 8 Jam` → Alert "Stop Kopi".
   - User Insomnia: `Target Tidur Lokal - 12 Jam`. *(Waktu eliminasi adenosin lebih lama).*

2. **Modifikasi Ambang Batas Darurat (Safety Override HRV):**
   - User Normal: Pemicu "Ambil Power Nap" jika `HRV Ratio drop >= 15%`.
   - User Insomnia: Pemicu "Ambil Power Nap" jika `HRV Ratio drop >= 10%`.

3. **Modifikasi Margin of Error CBTmin:**
   - Karena pola tidur *fragmented* (terputus-putus), durasi instruksi *Seek/Avoid Light* dilebarkan sebanyak **+30 menit** di awal dan akhir jadwal sebagai *buffer* keamanan.

**Prioritas Rule (jika overlap Gentle Mode + Insomnia):**
- Gunakan rule yang paling konservatif (paling ketat) untuk parameter yang sama.
- Contoh: Caffeine cut-off tetap `Target Tidur Lokal - 12 Jam`, dan ambang HRV drop gunakan 10%.