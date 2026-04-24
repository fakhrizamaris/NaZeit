# Nazeit — Mentor Review Cheat Sheet

Dokumen pegangan untuk sesi *Code Review*. Pahami setiap bagian agar kamu bisa menjelaskan seluruh keputusan arsitektur, alur data, dan logika sirkadian di dalam kodemu.

---

## 1. Struktur Folder & Isi Setiap File

### 📁 `App/` — Entry Point & State Management

| File | Isi & Peran |
|---|---|
| **`NazeitApp.swift`** | Entry point (`@main`). Routing 3 jalur: Splash → (hasSavedTrip ? Phase-based view : Onboarding). Memanggil `loadFromDisk()` untuk restore state, request notifikasi, dan menampilkan `HealthScreeningModal` sebagai disclaimer |
| **`AppState.swift`** | *Single Source of Truth* (SSoT). Semua `@Published var` yang di-observe oleh seluruh view. Berisi: user profile (bedtime, wakeTime, adaptationProfile), trip config (cities, timezone, dates), plan output (`tripPlan`), phase tracking, persistence (save/load ke UserDefaults), dan `completedInflightSteps` guard untuk mencegah double-credit |

**Yang harus kamu pahami di `AppState`:**
- `generatePlan()` → Memanggil `PlanBuilder.build()` dari input user
- `transitionPhase(to:)` → Menghitung kredit adaptasi saat berpindah fase
- `completeInflightStep(_:credit:)` → Guard yang mencegah skor naik ganda saat user tekan back + Done ulang
- `scheduleSave()` → Debounce 0.5 detik agar 10 perubahan = 1 write ke disk
- `isFullyAdapted` → Gabungan 3 kondisi: persentase ≥ 1.0, HRV, atau waktu tercukupi

---

### 📁 `Models/` — Data Structures

| File | Isi & Peran |
|---|---|
| **`AdaptationProfile.swift`** | 4 enum penting: `AdaptationProfile` (normal/gentle/insomnia + parameter adaptatif), `FlightDirection` (eastward 0.95h/day, westward 1.53h/day), `TravelPhase` (preflight/inflight/postflight), `InputMethod` (watch/manual), `ArrivalWindow` (daytime 06-16, nighttime 18-05) |
| **`TripPlan.swift`** | Struktur data jadwal: `Instruction` (satu instruksi: tipe, waktu, judul, detail, reasoning), `SleepWindow` (bedtime + wakeTime), `DailyProtocol` (satu hari: index, fase, sleep window, instruksi[]), `TripPlan` (keseluruhan: loading[] + inflight + recovery[]) |

**Yang harus kamu pahami:**
- `FlightDirection.adaptationRatePerDay` → Angka dari jurnal Waterhouse et al.
- `ArrivalWindow.init(arrivalHour:)` → Menentukan apakah instruksi in-flight akan ke GetSunlight atau AvoidBrightLight
- `TripPlan` menyimpan `recalcCount` untuk tracking berapa kali user menyimpang

---

### 📁 `Services/` — Business Logic (Pure Functions)

| File | Isi & Peran |
|---|---|
| **`Circadian.swift`** | Mesin kalkulasi sirkadian. Semua `static func` agar testable tanpa instantiation. Berisi: `cbtMin()` (titik terendah suhu tubuh), `effectiveGap()` (12-Hour Rule), `dailyShift()`, `recoveryDays()`, `lightWindows()`, `caffeineCutoff()`, `arrivalWindow()`, `inflightWakeTime()` |
| **`PlanBuilder.swift`** | Generator jadwal lengkap. `build()` → `buildLoading()` + `buildInflight()` + `buildRecovery()`. Berisi logika: dynamic sleep cap (max 8h tidur, max 90 min power nap), kontekstual daytime/nighttime arrival, smart light instruction, conservative fallback |
| **`NotificationService.swift`** | Local notification scheduler. Singleton pattern (`shared`). Jadwalkan notifikasi untuk setiap instruksi + pengingat tidur 30 menit sebelum bedtime |

**Yang harus kamu pahami di `Circadian.swift`:**
- `cbtMin` = WakeTime − 2.5 jam → titik terendah suhu tubuh, referensi utama sirkadian
- `effectiveGap` → Jika gap > 12 jam, dibalik: `24 − gap`, arah dibalik. Kenapa? Karena tubuh lebih cepat adaptasi lewat jalur yang lebih pendek
- `recoveryDays` = `ceil(remainingGap / adaptationRate)` → Eastward lebih lambat dari Westward

**Yang harus kamu pahami di `PlanBuilder.swift`:**
- **Sleep Cap 8h**: Manusia tidak bisa tidur >8 jam di kursi pesawat. Jika penerbangan panjang (15h), timeline-nya: terjaga 3h → tidur 8h → bangun 4h sebelum mendarat
- **Power Nap Cap 90min**: Lebih dari 90 menit masuk Deep Sleep → bangun dengan *sleep inertia* (mabuk tidur)
- **4 jam sebelum mendarat**: Waktu untuk cortisol naik (1-2h) + caffeine bekerja (30-45min) + light anchoring (retina mengirim sinyal siang ke SCN otak). Saat mendarat, jam biologis sudah "mode siang"
- **Daytime vs Nighttime branching**: Daytime = butuh cahaya (GetSunlight), Nighttime = butuh gelap (AvoidBrightLight)

---

### 📁 `Views/OnBoarding/` — First-Time User Flow

| File | Peran |
|---|---|
| **`SplashScreenView.swift`** | Splash screen 1.2 detik dengan animasi logo |
| **`OnBoardingChoice.swift`** | Pilih metode input: Apple Watch atau Manual. Terdapat animasi ilustrasi dan penjelasan tiap mode |
| **`ConnectAppleWatch.swift`** | Alur koneksi Apple Watch (reserved untuk integrasi HealthKit) |
| **`ManualSetup.swift`** | Form manual: bedtime picker, wake time picker, adaptation profile. Simpan ke AppState → navigasi ke YourTrip |
| **`HealthScreeningModal.swift`** | Sheet disclaimer kesehatan. Wajib diterima sebelum menggunakan app. Menggunakan `@AppStorage` agar hanya tampil sekali seumur hidup |

---

### 📁 `Views/TripSetup/` — Trip Configuration

| File | Peran |
|---|---|
| **`YourTrip.swift`** | Form utama: kota asal/tujuan (autocomplete via LocationSearchService), date picker departure/arrival, toggle transit. Setelah submit → `generatePlan()` → navigasi ke LoadingPhaseView |
| **`LocationSearchService.swift`** | Service autocomplete kota menggunakan `MKLocalSearchCompleter`. Menerjemahkan nama kota ke TimeZone identifier |
| **`LoadingPhaseView.swift`** | Menampilkan 1-3 hari pre-flight loading. Setiap hari: instruksi geser tidur + seek light + caffeine cutoff. Tombol Next Day maju ke hari berikutnya. Hari terakhir → transisi ke AdaptationProgressView. Ada deteksi timezone berubah di `.onAppear` |

---

### 📁 `Views/Instructions/` — In-Flight & Recovery

| File | Peran |
|---|---|
| **`SleepNow.swift`** | Instruksi tidur in-flight. Menampilkan durasi tidur dinamis (dari PlanBuilder). Setelah Done → bercabang: Daytime Arrival → GetSunlight, Nighttime Arrival → AvoidBrightLight. Menggunakan `completeInflightStep("sleep")` untuk mencegah double credit |
| **`GetSunlight.swift`** | Instruksi cari cahaya (Daytime Arrival). Setelah Done → langsung ke RecoveryPhaseView. Guard: `completeInflightStep("sunlight")` |
| **`AvoidBrightLight.swift`** | Instruksi hindari cahaya (Nighttime Arrival). Setelah Done → RecoveryPhaseView. Guard: `completeInflightStep("avoidLight")` |
| **`InFlightDeviated.swift`** | Layar deviasi saat user tidak bisa mengikuti instruksi utama. Trigger recalculation. Setelah Done → RecoveryPhaseView |
| **`RecalculatedInstruction.swift`** | Menampilkan jadwal yang sudah di-recalculate setelah deviasi. Max 2x (conservative mode) |
| **`WatchDetects.swift`** | Layar deteksi Watch ketika HRV menunjukkan pola tidak sesuai. Navigasi ke RecalculatedInstruction |
| **`RecoveryPhaseView.swift`** | N hari recovery di destinasi. Setiap hari: sleep anchor lokal + seek light + exercise. Hari terakhir → langsung ke FullyAdaptedView (bukan lewat AdaptationProgressView, untuk menghindari glitch navigasi ganda) |

---

### 📁 `Views/Progress/` — Dashboard & Completion

| File | Peran |
|---|---|
| **`ProgressSuccess.swift`** | Berisi 2 view: `AdaptationProgressView` (dashboard checkpoint — menampilkan persentase adaptasi, lingkaran progres, statistik tidur, tombol CTA ke fase berikutnya) dan `FullyAdaptedView` (layar akhir: 100% adapted, confetti, tombol plan next trip) |

**Yang harus kamu pahami:**
- `AdaptationProgressView` punya `.navigationBarBackButtonHidden(true)` → checkpoint, user tidak boleh kembali
- `FullyAdaptedView` → tombol "Plan Next Trip" memanggil `resetForNewTrip()` → navigasi ke OnboardingChoice

---

### 📁 `Views/Shared/` — Reusable Components

| File | Peran |
|---|---|
| **`CircadianComponents.swift`** | Komponen visual: `CircadianHeroCard` (kartu utama dengan lingkaran adaptasi), `CircadianRingView` (lingkaran gradient animasi), `DayProgressTracker` (progress bar hari), `StarsBackground` + `MoonDecoration` (latar dekoratif), `NavDots` (page indicator) |
| **`UIComponents.swift`** | Design tokens terpusat: `Color.nazeitTeal`, `Color.semanticPrimaryTeal`, `Color.staticTeal` (untuk gradient, menghindari bug SwiftUI transparency), button styles, interactive text styles |

**Yang harus kamu pahami:**
- `staticTeal` vs `nazeitTeal`: SwiftUI punya bug di mana Dynamic UIColor transparan di gradient. `staticTeal` adalah warna statis untuk solusi ini
- `@ScaledMetric` pada ikon → mendukung Dynamic Type (Accessibility)

---

## 2. Alur Data End-to-End

```
[User isi form YourTrip]
        ↓
[generatePlan()] → [PlanBuilder.build()] → [Circadian calculations]
        ↓
[TripPlan: loading[] + inflight + recovery[]]
        ↓
[AppState.tripPlan = plan] → [scheduleSave() → UserDefaults]
        ↓
[Views membaca tripPlan → render UI]
```

---

## 3. Alur In-Flight (Kontekstual per Tipe Kedatangan)

```
                ┌─ Daytime Arrival ─── SleepNow → GetSunlight → Recovery
In-Flight ──────┤
                └─ Nighttime Arrival ─ SleepNow → AvoidBrightLight → Recovery
```

**Kenapa bercabang?**
- **Daytime:** Tubuh ngantuk (jam biologis = malam) tapi tiba siang → obatnya **cahaya** (menekan melatonin, reset jam biologis ke mode siang)
- **Nighttime:** Tubuh terjaga (jam biologis = siang) tapi tiba malam → obatnya **gelap** (melatonin naik, bantu tidur di waktu lokal)

**Instruksi cahaya yang salah arah akan MEMPERBURUK jet lag, bukan menyembuhkannya.**

---

## 4. Konsep Sirkadian Kunci

### 12-Hour Rule
Gap > 12 jam → dibalik: `24 - gap`, arah dibalik (Eastward↔Westward). Tubuh lebih cepat adaptasi lewat jalur pendek.

### Adaptation Rate (Waterhouse et al.)
- **Eastward:** 0.95 jam/hari (sulit mempercepat jam biologis)
- **Westward:** 1.53 jam/hari (lebih mudah memperlambat jam biologis)

### In-Flight Sleep Cap
- Full sleep: **max 8 jam** (satu siklus lengkap)
- Power nap: **max 90 menit** (lebih dari itu → sleep inertia)
- **Bangun 4 jam sebelum mendarat**: 2h pulih sleep inertia + cortisol rise + caffeine + light anchoring

### Step Completion Guard
`completedInflightSteps: Set<String>` di AppState. Setiap instruksi punya ID unik. `completeInflightStep()` mengecek Set sebelum memberikan kredit. Mencegah eksploitasi skor dengan back + Done ulang.

### Recalculation Limit
Max 2x per fase. Setelahnya → Conservative Recovery Mode (3 instruksi dasar saja). Mencegah *Endless Adaptation Loop*.

---

## 5. Prediksi Pertanyaan Mentor

### "Kenapa pakai `@EnvironmentObject` bukan `@ObservedObject`?"
> AppState dibutuhkan oleh 15+ view bersarang. Passing manual via init → *prop drilling* kotor. `@EnvironmentObject` menyuntikkan state implisit ke seluruh hierarki.

### "Kenapa `UserDefaults` bukan CoreData/SwiftData?"
> Data kecil (String, Date, Enum). Tidak ada relasi atau query kompleks. CoreData = over-engineering.

### "Kenapa `Circadian.swift` pakai `static func` semua?"
> Supaya *testable* tanpa instantiation: `XCTAssertEqual(Circadian.recoveryDays(remaining: 6, direction: .westward), 4)`.

### "Apa yang terjadi jika user force-close app?"
> State sudah di-persist via `scheduleSave()`. Saat reopen, `loadFromDisk()` → deteksi `travelPhase` → render view yang sesuai.

### "Apa bedanya `circadianLevel` dan `adaptationPercent`?"
> Keduanya selalu in-sync. `circadianLevel` → animasi lingkaran visual. `adaptationPercent` → logika bisnis.

### "Kenapa user tidak boleh tekan back di AdaptationProgressView?"
> Halaman ini adalah checkpoint. Instruksi yang sudah selesai tidak boleh diulang (juga mencegah double credit).

### "Kenapa tidur di pesawat di-cap 8 jam?"
> Manusia tidak bisa tidur >8 jam di kursi pesawat. Untuk penerbangan 15 jam: terjaga 3h → tidur 8h → bangun 4h sebelum mendarat. Ini realistis secara biologis.

### "Kenapa power nap di-cap 90 menit?"
> Lebih dari 90 menit masuk fase Deep Sleep. Bangun dari Deep Sleep menyebabkan *sleep inertia* (pusing berat, disorientasi) yang bisa berlangsung 30 menit–2 jam.

### "Kenapa harus bangun 4 jam sebelum mendarat?"
> 4 jam = 1-2h pulih sleep inertia + cortisol rise + 30-45 menit caffeine absorption + light anchoring via retina. Saat mendarat, jam biologis sudah aktif mode siang.

### "Kenapa alur in-flight bercabang Daytime vs Nighttime?"
> Daytime Arrival: tubuh butuh cahaya untuk menahan kantuk. Nighttime Arrival: tubuh butuh gelap untuk membantu tidur. Memberikan instruksi cahaya yang salah arah memperburuk jet lag.

### "Kenapa `completedInflightSteps` pakai Set<String>?"
> Mencegah eksploitasi skor. Tanpa guard ini, user bisa tekan back → Done → skor naik tanpa batas. Set di-persist ke disk agar tidak reset saat app ditutup.

### "Kenapa `scheduleSave()` pakai debounce?"
> Saat `loadFromDisk()` memulihkan 15 properti sekaligus, setiap `didSet` memicu `scheduleSave()`. Debounce 0.5 detik menggabungkan semua trigger → hanya 1 write ke disk.

---

## 6. HIG iOS 26+ Compliance

- [x] **Dynamic Type** — Semantic font sizes (`.body`, `.title2`, `.caption`)
- [x] **Dark/Light Mode** — `Color(uiColor:)` otomatis adaptif
- [x] **Semantic Colors** — Palet terpusat di `UIComponents.swift`
- [x] **Accessibility** — `@ScaledMetric` untuk ikon responsif
- [x] **NavigationStack** — Bukan `NavigationView` yang deprecated
- [x] **Spring Animations** — `.spring()` responses, bukan durasi kaku
- [x] **System Patterns** — `.alert()`, `.sheet()`, `@AppStorage`
- [x] **No Back to Completed Steps** — `navigationBarBackButtonHidden` di checkpoint
- [x] **Debounced Persistence** — Mencegah excessive disk writes
