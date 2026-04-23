# Studi Case to Reduce JetLag

## RecoveryPhase

### 1. Penerbangan ke Timur (Eastward)

-  Tujuan: Phase Advance (Memajukan jam biologis).
-  Kecepatan Adaptasi Tubuh: Hanya 0,95 jam per hari (sangat lambat).
-  Estimasi Hari Sembuh (Recovery Time): Hari = Gap / 0.95

- Logika Intervensi Cahaya (Light Rules):
    - IF Waktu = CBTmin hingga (CBTmin + 4 jam) → TRIGGER: "SEEK LIGHT"
    - IF Waktu = (CBTmin - 3 jam) hingga CBTmin → TRIGGER: "AVOID LIGHT"

### 2. Penerbangan Ke Barat (Westward)

- Tujuan: Phase Delay (Memundurkan jam biologis).
- Kecepatan Adaptasi Tubuh: Sekitar 1,53 jam per hari (lebih cepat).
- Estimasi Hari Sembuh (Recovery Time): Hari = Gap / 1.53
- Logika Intervensi Cahaya (Light Rules):
  -  IF Waktu = (CBTmin - 4 jam) hingga CBTmin → TRIGGER: "Seek Light"
  -  IF Waktu = CBTmin hingga (CBTmin + 3 jam) → TRIGGER: "Avoid
LIGHT"


### Baseline

1. Hitung Baseline: Tarik data tidur → Tentukan CBTmin lokal.

2. Hitung Gap: Gap = (CBTmin aktual - CBTmin target).

3. Cek Kondisi User:
    - IF User == Insomnia → Aktifkan Insomnia Modifier (Threshold HRV 10%, Kafein cut-off 12 jam).
    - ELSE → Gunakan Threshold Normal.

4. Cek Arah Penerbangan:
    - IF Destination == Eastward → Set hari recovery (Gap/0.95) & Jalankan Rule
Cahaya Eastward.
    - IF Destination == Westward → Set hari recovery (Gap/1.53) & Jalankan Rule
Cahaya Westward.

5. Real-time Monitoring: Pantau rasio HRV terus-menerus. Jika H RVratio ≥ 90%,
tampilkan UI "Fully Adapted" (Selesai).


### Rumus Edge Case

1. Modifikasi Jeda Kafein (Caffeine Cut-off):
    - User Normal: Target Tidur Lokal - 8 Jam → Alert "Stop Kopi".
    - User Insomnia: Diperpanjang menjadi Target Tidur Lokal - 12 Jam. Penderita insomnia butuh waktu jauh lebih lama untuk membuang bloker adenosin dari kafein.

2. Modifikasi Ambang Batas Darurat (Safety Override HRV):
    - User Normal: Aplikasi memicu "Ambil Power Nap" jika HRV drop ≥ 15%.
    - User Insomnia: Tubuh mereka sudah rentan. Aplikasi memicu "Ambil Power Nap" jika HRV drop hanya ≥ 10%. (Algoritma lebih cepat menyuruh mereka istirahat ketimbang
memaksakan penyesuaian jam).

3. Modifikasi Margin of Error CBTmin:
    - Karena orang insomnia tidurnya terputus-putus (fragmented), perhitungan rata-rata wake time dari Apple Watch bisa sedikit meleset.
    - Solusi Logika: Lebarkan durasi instruksi Seek/Avoid Light sebanyak +30 menit sebagai
buffer (cadangan keamanan) agar tidak meleset dari kurva sirkadian asli mereka.

## LoadingPhase
1. Penetapan Batas Aman (The Safety Threshold):
Algoritma harus membatasi seberapa banyak pergeseran maksimum per hari agar user tidak
pusing sebelum terbang.
    - Maksimum Shift Normal: 1 jam (60 menit) per hari.
    - Maksimum Shift (Insomnia/Lansia): 0.5 jam (30 menit) per hari (Terkoneksi dengan
Edge Case sebelumnya).

2. Rumus "Daily Shift Target" (Target Geser Harian)
Aplikasi harus menghitung berapa menit user harus menggeser jam tidurnya per hari selama N
hari sebelum keberangkatan (biasanya N = 3 hari, sesuai diagram kalian).
Formula:

$$Shift_{daily} = \min \left( \frac{Gap_{total}}{N_{days}}, MaxShift \right)$$
