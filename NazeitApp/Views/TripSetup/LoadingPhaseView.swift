//
//  LoadingPhaseView.swift
//  KamBing
//

import SwiftUI

struct LoadingPhaseView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDayIndex: Int = 0 
    
    // MARK: - Dummy Data & Contextual Calendar
    let offsets = [3, 2, 1] // Berapa hari sebelum H-0
    let sleepTargets = [
        "10:00 PM - 06:00 AM", 
        "09:00 PM - 05:00 AM", 
        "08:00 PM - 04:00 AM"
    ]
    let shifts = ["-1 Hour Shift", "-2 Hour Shift", "-3 Hour Shift"]
    
    // MARK: [HIG: Contextual Dates] 
    // Menghitung tanggal aktual dari H-X sehingga pengguna tidak menebak-nebak ini hari apa.
    private func dateString(for offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: appState.departureDate) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "MMM d" // e.g. "Oct 24"
        return f.string(from: date)
    }
    
    private var baseColor: Color { Color(uiColor: .nazeitTeal) }

    var body: some View {
        NavigationStack {
            ZStack {
                // [Background Ambient]: Linear Gradient Halus agar tidak terasa flat
                LinearGradient(
                    colors: [Color(uiColor: .secondarySystemBackground), Color(uiColor: .systemBackground)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // [Ambient Glow]: Efek relaksasi pada latar belakang yang menyatu dengan tema sirkadian
                Circle()
                    .fill(baseColor.opacity(0.12))
                    .frame(maxWidth: 400)
                    .blur(radius: 120)
                    .offset(x: -80, y: -200)

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) { // Diperkecil dari 32 ke 24
                            
                            // MARK: Header Instruction
                            VStack(spacing: 6) {
                                Text("Pre-flight Loading Phase")
                                    // [Typography Hierarchy]: Menggunakan .title2 & .rounded untuk kesan ilmiah namun tetap Humanist/friendly.
                                    .font(.system(.title2, design: .rounded).weight(.bold))
                                    .foregroundStyle(Color(uiColor: .label))
                                
                                Text("Your circadian adjustment has started. Follow this schedule to minimize fast cognition shock upon arrival.")
                                    // [Legibility]: .subheadline sangat cukup dibaca dan warnanya secondary agar title menonjol.
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 8)
                            
                            // MARK: Tracker 3 Hari
                            DayProgressTracker(offsets: offsets, dateProvider: dateString, selectedIndex: selectedDayIndex, activeColor: baseColor)
                                .padding(.horizontal, 24)
                            
                            // MARK: [HIG: Physical Sliding Transition] 
                            VStack(spacing: 24) { // Diperkecil dari 32 ke 24
                                // MARK: Hero Emphasis (Target Tidur)
                                HeroSleepTargetView(
                                    title: "Tonight's Sleep Target",
                                    timeRange: sleepTargets[selectedDayIndex],
                                    shiftLabel: shifts[selectedDayIndex],
                                    color: baseColor
                                )
                                .padding(.horizontal, 24)
                                
                                // MARK: Instruksi Protokol (Chronobiology Actionable Items)
                                VStack(alignment: .leading, spacing: 12) { // Diperkecil dari 16 ke 12
                                    Text("Daily Protocol")
                                        .font(.headline)
                                        .foregroundStyle(Color(uiColor: .label))
                                        .padding(.horizontal, 32)
                                    
                                    VStack(spacing: 12) {
                                        ProtocolCard(
                                            icon: "sun.max.fill", iconTint: .orange,
                                            title: "Seek Morning Light", detail: "Get 15 mins of sunlight immediately after waking up."
                                        )
                                        ProtocolCard(
                                            icon: "cup.and.saucer.fill", iconTint: .brown,
                                            title: "Caffeine Cutoff", detail: "No coffee or tea after 02:00 PM today."
                                        )
                                        ProtocolCard(
                                            icon: "moon.fill", iconTint: .indigo,
                                            title: "Dim the Lights", detail: "Use warm lights or blue-light blocking glasses 2 hours before bed."
                                        )
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                            .id(selectedDayIndex)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            
                            Spacer(minLength: 24) // Diperkecil dari 40 ke 24
                        }
                    }
                    
                    // MARK: Pagination Controls (Sticky Footer)
                    // Dipindahkan ke luar ScrollView agar tombol selalu berada di bawah layar penuh!
                    HStack(spacing: 16) {
                        // Back Button
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if selectedDayIndex > 0 { selectedDayIndex -= 1 }
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.headline)
                                .foregroundStyle(selectedDayIndex > 0 ? baseColor : Color(uiColor: .tertiaryLabel))
                                .frame(width: 56, height: 56)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                                .shadow(color: Color.black.opacity(selectedDayIndex > 0 ? 0.05 : 0), radius: 8, y: 4)
                        }
                        .disabled(selectedDayIndex == 0)
                        
                        // Next / Finish Button
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if selectedDayIndex < offsets.count - 1 { 
                                    selectedDayIndex += 1 
                                } else {
                                    // Aksi saat selesai membaca semua Loading Phase
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text(selectedDayIndex == offsets.count - 1 ? "Commit to Plan" : "Next Day")
                                if selectedDayIndex < offsets.count - 1 {
                                    Image(systemName: "arrow.right")
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .font(.headline)
                            .foregroundStyle(selectedDayIndex == offsets.count - 1 ? .white : Color(uiColor: .label))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(selectedDayIndex == offsets.count - 1 ? baseColor : Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 100, style: .continuous).stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 16) // Padding aman agar tidak memotong home indicator iPhone
                    .background(
                        LinearGradient(
                            stops: [
                                .init(color: Color(uiColor: .systemBackground).opacity(0), location: 0),
                                .init(color: Color(uiColor: .systemBackground), location: 0.2)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Reusable Modular Components

struct DayProgressTracker: View {
    let offsets: [Int]
    let dateProvider: (Int) -> String
    var selectedIndex: Int
    let activeColor: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            // Garis Penghubung Latar (Background Track)
            // Diposisikan menembus poros tengah dari lingkaran simpul
            GeometryReader { geo in
                let stepWidth = geo.size.width / CGFloat(offsets.count * 2)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(height: 4)
                    
                    // Garis Progres aktif
                    Rectangle()
                        .fill(activeColor)
                        .frame(width: max(0, CGFloat(selectedIndex) * (geo.size.width - (stepWidth * 2)) / CGFloat(max(1, offsets.count - 1))), height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedIndex)
                }
                .padding(.horizontal, stepWidth)
                .offset(y: 14) // Y=14 adalah titik tengah dari Circle berukuran 32 (dikurang setengah tinggi garis)
            }
            .frame(height: 32)
            
            // Simpul Lingkaran & Label Teks
            HStack(spacing: 0) {
                ForEach(0..<offsets.count, id: \.self) { index in
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(index <= selectedIndex ? activeColor : Color(uiColor: .systemBackground))
                                .frame(width: 32, height: 32)
                                .overlay(Circle().stroke(activeColor.opacity(index <= selectedIndex ? 0 : 0.2), lineWidth: 2))
                            
                            if index < selectedIndex {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .transition(.scale)
                            } else if index == selectedIndex {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 10, height: 10)
                                    .transition(.scale)
                            }
                        }
                        
                        VStack(spacing: 2) {
                            Text("Day -\(offsets[index])")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(index == selectedIndex ? activeColor : Color(uiColor: .secondaryLabel))
                                
                            Text(dateProvider(offsets[index]))
                                .font(.caption2)
                                .foregroundStyle(Color(uiColor: .tertiaryLabel))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct HeroSleepTargetView: View {
    let title: String
    let timeRange: String
    let shiftLabel: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                // [Color Theory]: Secondary memastikan mata tidak tertahan di label, langsung loncat ke angkanya.
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            Text(timeRange)
                // [Typography: Monospaced]: MonospacedDigit menjaga agar lebar barisan teks waktu (Jam) konstan dan rapi. Weight .black memberikan kontras ekstrem (Hero Text).
                .font(.system(.title, design: .rounded).monospacedDigit().weight(.black))
                .foregroundStyle(color)
            
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.forward.circle.fill")
                Text(shiftLabel)
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color, in: Capsule())
        }
        .padding(.vertical, 20) // Diperkecil dari 24 ke 20 untuk memadatkan Hero Card
        .frame(maxWidth: .infinity)
        // [Gestalt: Enclosure/Common Region]: Membungkus secara fisik agar angka-angka dirasakan terhubung erat oleh pengguna.
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        // [Visual Cue]: Shadow memberi dimensi Z bahwa card ini lebih tebal dan "paling penting".
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: timeRange)
    }
}

struct ProtocolCard: View {
    let icon: String
    let iconTint: Color
    let title: String
    let detail: String
    
    @State private var isCompleted = false
    
    var body: some View {
        Button {
            // MARK: [HIG: Gamification/Goal-Gradient]
            // Tap untuk komit menyelesaikan tugas. Menghasilkan animasi pantul dan checkmark hijau.
            // Bisa disambungkan ke Haptic Feedback!
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCompleted.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconTint.opacity(0.12))
                        .frame(width: 38, height: 38) // Diperkecil dari 44 ke 38
                    
                    Image(systemName: icon)
                        .font(.body) // Dari .title3 ke .body agar proporsional dengan 38
                        .foregroundStyle(iconTint)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        // [Accessibility]: Wajib hilang lineLimit agar card beradaptasi merenggang ke bawah jika ukuran font user sangat besar (XXX Large).
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: 0)
                
                // Kolom Checklist Indikator
                ZStack {
                    Circle()
                        .stroke(isCompleted ? .clear : Color(uiColor: .quaternaryLabel), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color(uiColor: .nazeitTeal))
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
            }
            .padding(14) // Diperkecil dari 16 ke 14
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain) // Mencegah highlight biru bawaan tombol di iOS
    }
}

#Preview {
    LoadingPhaseView().environmentObject(AppState())
}
