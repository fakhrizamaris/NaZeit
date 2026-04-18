//
//  LoadingPhaseView.swift
//  KamBing
//

import SwiftUI

struct LoadingPhaseView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDayIndex: Int = 0 
    
    // MARK: - Dummy Data
    let days = ["Day -3", "Day -2", "Day -1"]
    let sleepTargets = [
        "10:00 PM - 06:00 AM", 
        "09:00 PM - 05:00 AM", 
        "08:00 PM - 04:00 AM"
    ]
    let shifts = ["-1 Hour Shift", "-2 Hour Shift", "-3 Hour Shift"]
    
    // [Color Harmony]: Menggunakan Color Semantic yang menenangkan (Any Appearance support)
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // MARK: Header Instruction
                        VStack(spacing: 8) {
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
                        .padding(.top, 16)
                        
                        // MARK: Tracker 3 Hari
                        // [Gestalt: Continuity]: Terdapat garis yang menghubungkan simpul 1 ke yang lain secara visual.
                        DayProgressTracker(days: days, selectedIndex: $selectedDayIndex, activeColor: baseColor)
                            .padding(.horizontal, 24)
                        
                        // MARK: Hero Emphasis (Target Tidur)
                        // [Information Hierarchy: Strongest Emphasis]: Mata pengguna harus melihat bagian ini pertama kali (Fast Cognition)
                        HeroSleepTargetView(
                            title: "Tonight's Sleep Target",
                            timeRange: sleepTargets[selectedDayIndex],
                            shiftLabel: shifts[selectedDayIndex],
                            color: baseColor
                        )
                        .padding(.horizontal, 24)
                        
                        // MARK: Instruksi Protokol (Chronobiology Actionable Items)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Daily Protocol")
                                .font(.headline)
                                .foregroundStyle(Color(uiColor: .label))
                                .padding(.horizontal, 32)
                            
                            // [Gestalt: Proximity]: Meletakkan barisan card saling berdekatan sehingga terekognisi sebagai 1 grup aktivitas.
                            VStack(spacing: 12) {
                                ProtocolCard(
                                    icon: "sun.max.fill",
                                    iconTint: .orange,
                                    title: "Seek Morning Light",
                                    detail: "Get 15 mins of sunlight immediately after waking up."
                                )
                                
                                ProtocolCard(
                                    icon: "cup.and.saucer.fill",
                                    iconTint: .brown,
                                    title: "Caffeine Cutoff",
                                    detail: "No coffee or tea after 02:00 PM today."
                                )
                                
                                ProtocolCard(
                                    icon: "moon.fill",
                                    iconTint: .indigo,
                                    title: "Dim the Lights",
                                    detail: "Use warm lights or blue-light blocking glasses 2 hours before bed."
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        // [Animation]: .spring() memicu crossfade sangat halus jika konten protocol berubah berdasarkan Index harinya.
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedDayIndex)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Reusable Modular Components (Sesuai Konsep Agile/Clean Code)

struct DayProgressTracker: View {
    let days: [String]
    @Binding var selectedIndex: Int
    let activeColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<days.count, id: \.self) { index in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            // [Visual Priority]: Hari lalu/sekarang (warna aktif), Hari besok (mati/tertiary).
                            .fill(index <= selectedIndex ? activeColor : Color(uiColor: .tertiarySystemFill))
                            .frame(width: 32, height: 32)
                        
                        if index < selectedIndex {
                            // Status H- sudah terlewati
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                                .transition(.scale)
                        } else if index == selectedIndex {
                            // Status H- Sedang dijalankan (Animasi target)
                            Circle()
                                .fill(.white)
                                .frame(width: 10, height: 10)
                                .transition(.scale)
                        }
                    }
                    // [Interactive Design]: Interaksi untuk berpindah simulator H-3/2/1.
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedIndex = index
                        }
                    }
                    
                    Text(days[index])
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(index == selectedIndex ? activeColor : Color(uiColor: .secondaryLabel))
                }
                
                // [Gestalt: Continuity] Render garis yang jembatani tiap hari.
                if index < days.count - 1 {
                    Rectangle()
                        .fill(index < selectedIndex ? activeColor : Color(uiColor: .tertiarySystemFill))
                        .frame(height: 3)
                        .padding(.horizontal, 4)
                        .offset(y: -12) // Penyesuaian menyelinap pas ke titik circle.
                        .animation(.easeInOut, value: selectedIndex)
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
        .padding(.vertical, 24)
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
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconTint.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
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
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5)
        )
    }
}

#Preview {
    LoadingPhaseView().environmentObject(AppState())
}
