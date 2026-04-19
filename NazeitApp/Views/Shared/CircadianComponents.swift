//
//  CircadianComponents.swift
//  KamBing
//

import SwiftUI

// MARK: - Decorations
struct SunRaysDecoration: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<8) { i in
                Rectangle()
                    .fill(LinearGradient(colors: [Color(uiColor: .label).opacity(0.12), .clear],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 2, height: geo.size.height * 0.4)
                    .rotationEffect(.degrees(Double(i) * 45))
                    .position(x: geo.size.width * 0.5, y: geo.size.height * 0.12)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

struct MoonDecoration: View {
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(Color(red:0.85,green:0.82,blue:0.95).opacity(0.06))
                .frame(width: 200).blur(radius: 30)
                .position(x: geo.size.width * 0.82, y: geo.size.height * 0.12)
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

struct SuccessParticles: View {
    let particles: [(CGFloat, CGFloat, CGFloat, Double)] = (0..<20).map { _ in
        (CGFloat.random(in: 0...1),
         CGFloat.random(in: 0.1...0.6),
         CGFloat.random(in: 3...8),
         Double.random(in: 0.1...0.5))
    }
    var body: some View {
        GeometryReader { geo in
            ForEach(particles.indices, id: \.self) { i in
                Circle()
                    .fill(Color.circadianTeal.opacity(particles[i].3))
                    .frame(width: particles[i].2, height: particles[i].2)
                    .position(x: particles[i].0 * geo.size.width,
                              y: particles[i].1 * geo.size.height)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}

struct StarsBackground: View {
    let stars: [(CGFloat, CGFloat, CGFloat)] = (0..<40).map { _ in
        (CGFloat.random(in: 0...1), CGFloat.random(in: 0...0.6), CGFloat.random(in: 1...3))
    }
    var body: some View {
        GeometryReader { geo in
            ForEach(stars.indices, id: \.self) { i in
                Circle()
                    .fill(Color(uiColor: .label).opacity(Double.random(in: 0.08...0.35)))
                    .frame(width: stars[i].2, height: stars[i].2)
                    .position(x: stars[i].0 * geo.size.width,
                              y: stars[i].1 * geo.size.height)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false)
    }
}


// MARK: - Dual Timeline Component
struct DualTimeView: View {
    @EnvironmentObject var appState: AppState
    let localTime: String
    let isDaytime: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .center, spacing: 2) {
                Text(appState.fromTimeZone.abbreviation() ?? "ORIGIN").font(.system(size: 8, weight: .bold))
                Text("19:40").font(.caption.weight(.heavy))
            }
            .foregroundStyle(isDaytime ? .indigo : .teal)
            
            Image(systemName: "arrow.right").font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(uiColor: .quaternaryLabel))
            
            VStack(alignment: .center, spacing: 2) {
                Text(appState.toTimeZone.abbreviation() ?? "LOCAL").font(.system(size: 8, weight: .bold))
                Text(localTime).font(.caption.weight(.heavy))
            }
            .foregroundStyle(isDaytime ? Color(uiColor: .nazeitTeal) : Color(uiColor: .label))
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(Capsule())
    }
}


// MARK: - Progress & Metrics UI
struct MetricCard: View {
    let value: String
    let label: String
    let icon: String
    let iconColor: Color
    let trend: String?

    private var trendColor: Color {
        Color(uiColor: .nazeitTeal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: icon).font(.caption).foregroundStyle(iconColor)
            }
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value).font(.title3).fontWeight(.bold)
                if let t = trend {
                    Text(t).font(.caption).fontWeight(.bold).foregroundStyle(trendColor)
                }
            }
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


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


// MARK: - Lists & Actions
struct ProtocolCard: View {
    let icon: String
    let iconTint: Color
    let title: String
    let detail: String
    
    @State private var isCompleted = false
    
    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: isCompleted ? .light : .medium)
            generator.impactOccurred()
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


struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.caption).foregroundStyle(iconColor)
                Text(title)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            content()
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: .quaternaryLabel).opacity(0.25), lineWidth: 0.5)
        )
    }
}


struct TimeRow: View {
    let label: String
    let isExpanded: Bool

    var body: some View {
        HStack {
            Text(label).font(.body).foregroundStyle(Color(uiColor: .label))
            Spacer()
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.footnote).foregroundStyle(Color(uiColor: .secondaryLabel))
        }
    }
}
