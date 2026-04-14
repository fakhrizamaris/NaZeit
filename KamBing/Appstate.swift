//
//  Appstate.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 14/04/26.
//

//  AppState.swift — KamBing
import SwiftUI
import Combine

enum InputMethod { case watch, manual }

class AppState: ObservableObject {
    @Published var inputMethod: InputMethod = .watch
    @Published var circadianLevel: Double = 0.45
    @Published var currentHRV: Int = 52
    @Published var sleepHours: Double = 7.2
    @Published var preferredBedtime: Date = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date()) ?? Date()
    @Published var preferredWakeTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var fromCity: String = ""
    @Published var toCity: String = ""
    @Published var departureDate: Date = Date()
    @Published var adaptationPercent: Double = 0.65
    @Published var daysRemaining: Int = 2
}

extension Color {
    static let bgNight       = Color(red: 0.05, green: 0.04, blue: 0.18)
    static let bgNightTop    = Color(red: 0.08, green: 0.05, blue: 0.22)
    static let bgMorning     = Color(red: 0.99, green: 0.88, blue: 0.45)
    static let bgMorningBase = Color(red: 0.96, green: 0.72, blue: 0.22)
    static let bgEvening     = Color(red: 0.12, green: 0.06, blue: 0.22)
    static let bgSuccess     = Color(red: 0.04, green: 0.20, blue: 0.12)
    static let bgOnboarding  = Color(red: 0.04, green: 0.04, blue: 0.16)
    static let circadianTeal = Color(red: 0.18, green: 0.80, blue: 0.68)
    static let adaptOrange   = Color(red: 0.95, green: 0.55, blue: 0.12)
}

extension ShapeStyle where Self == Color {
    static var bgNight: Color { Color.bgNight }
    static var bgNightTop: Color { Color.bgNightTop }
    static var bgMorning: Color { Color.bgMorning }
    static var bgMorningBase: Color { Color.bgMorningBase }
    static var bgEvening: Color { Color.bgEvening }
    static var bgSuccess: Color { Color.bgSuccess }
    static var bgOnboarding: Color { Color.bgOnboarding }
    static var circadianTeal: Color { Color.circadianTeal }
    static var adaptOrange: Color { Color.adaptOrange }
}

// Shared glassmorphism card modifier — dipakai di semua instruction screens
struct InstructionCardStyle: ViewModifier {
    var isAdjusted: Bool = false
    func body(content: Content) -> some View {
        content
            .padding(28)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(
                isAdjusted ? Color.adaptOrange.opacity(0.5) : Color.white.opacity(0.14), lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 20, y: 8)
    }
}
extension View {
    func instructionCard(isAdjusted: Bool = false) -> some View {
        modifier(InstructionCardStyle(isAdjusted: isAdjusted))
    }
}

// Shared primary button label
struct PrimaryBtn: View {
    let title: String
    var color: Color = .accentColor
    var body: some View {
        Text(title)
            .font(.body).fontWeight(.semibold).foregroundStyle(.white)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(LinearGradient(colors: [color, color.opacity(0.75)],
                startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: color.opacity(0.35), radius: 10, y: 5)
    }
}
