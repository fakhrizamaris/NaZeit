//
//  LoadingPhaseView.swift
//  KamBing
//

import SwiftUI

struct LoadingPhaseView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDayIndex: Int = 0 
    @State private var navigatetoDashboard: Bool = false
    
    // MARK: - Data Models
    let offsets = [3, 2, 1]
    let sleepTargets = [
        "10:00 PM - 06:00 AM", 
        "09:00 PM - 05:00 AM", 
        "08:00 PM - 04:00 AM"
    ]
    let shifts = ["-1 Hour Shift", "-2 Hour Shift", "-3 Hour Shift"]
    
    private var baseColor: Color { Color(uiColor: .nazeitTeal) }

    private func dateString(for offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: appState.departureDate) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(uiColor: .secondarySystemBackground), Color(uiColor: .systemBackground)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Circle()
                    .fill(baseColor.opacity(0.12))
                    .frame(maxWidth: 400)
                    .blur(radius: 120)
                    .offset(x: -80, y: -200)

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            
                            // MARK: - Header
                            VStack(spacing: 6) {
                                Text("Pre-flight Loading Phase")
                                    .font(.system(.title2, design: .rounded).weight(.bold))
                                    .foregroundStyle(Color(uiColor: .label))
                                
                                Text("Your circadian adjustment has started. Follow this schedule to minimize fast cognition shock upon arrival.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 8)
                            
                            // MARK: - Progress Tracker
                            DayProgressTracker(offsets: offsets, dateProvider: dateString, selectedIndex: selectedDayIndex, activeColor: baseColor)
                                .padding(.horizontal, 24)
                            
                            // MARK: - Content Cards
                            VStack(spacing: 24) {
                                HeroSleepTargetView(
                                    title: "Tonight's Sleep Target",
                                    timeRange: sleepTargets[selectedDayIndex],
                                    shiftLabel: shifts[selectedDayIndex],
                                    color: baseColor
                                )
                                .padding(.horizontal, 24)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Daily Protocol")
                                        .font(.headline)
                                        .foregroundStyle(Color(uiColor: .label))
                                        .padding(.horizontal, 32)
                                    
                                    VStack(spacing: 12) {
                                        ProtocolCard(
                                            icon: "sun.max.fill", iconTint: .cyan,
                                            title: "Seek Morning Light", detail: "Get 15 mins of sunlight immediately after waking up."
                                        )
                                        
                                        ProtocolCard(
                                            icon: "cup.and.saucer.fill", iconTint: baseColor,
                                            title: "Caffeine Cutoff", detail: "No coffee or tea after 02:00 PM today."
                                        )
                                        
                                        ProtocolCard(
                                            icon: "moon.fill", iconTint: .mint,
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
                            
                            Spacer(minLength: 24)
                        }
                    }
                    
                    // MARK: - Bottom Navigation Bar
                    HStack(spacing: 16) {
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
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if selectedDayIndex < offsets.count - 1 { 
                                    selectedDayIndex += 1 
                                } else {
                                    // TODO: Handle completion navigation
                                    navigatetoDashboard = true
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
                    .padding(.bottom, 16)
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

// MARK: - Components

struct DayProgressTracker: View {
    let offsets: [Int]
    let dateProvider: (Int) -> String
    var selectedIndex: Int
    let activeColor: Color
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geo in
                let stepWidth = geo.size.width / CGFloat(offsets.count * 2)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(activeColor)
                        .frame(width: max(0, CGFloat(selectedIndex) * (geo.size.width - (stepWidth * 2)) / CGFloat(max(1, offsets.count - 1))), height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedIndex)
                }
                .padding(.horizontal, stepWidth)
                .offset(y: 14)
            }
            .frame(height: 32)
            
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
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            Text(timeRange)
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
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCompleted.toggle()
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconTint.opacity(0.12))
                        .frame(width: 38, height: 38)
                    
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(iconTint)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Text(detail)
                        .font(.footnote)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: 0)
                
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
            .padding(14)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoadingPhaseView().environmentObject(AppState())
}
