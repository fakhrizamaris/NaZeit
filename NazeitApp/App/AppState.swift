//
//  Appstate.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 14/04/26.
//

//  AppState.swift — KamBing
import SwiftUI
import Combine
import UIKit

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
    @Published var fromTimeZone: TimeZone = .current
    @Published var toTimeZone: TimeZone = .current
    
    @Published var departureDate: Date = Date()
    @Published var arrivalDate: Date = Date().addingTimeInterval(3600 * 15)
    @Published var adaptationPercent: Double = 0.65
    @Published var daysRemaining: Int = 2
    @Published var isSleepDisorder = false
    @Published var selectedDisorder = ""
}


extension UIColor {
    static let nazeitTeal = UIColor { trait in
        return trait.userInterfaceStyle == .dark ?
            UIColor(red: 0.10, green: 0.50, blue: 0.38, alpha: 1.0) :
            UIColor(red: 0.12, green: 0.62, blue: 0.52, alpha: 1.0)
    }
    
    static let circadianTeal = UIColor.nazeitTeal
    
    static let nazeitBackground = UIColor { trait in
        // Riset Insight #2: Jet lag adalah ketidaksesuaian jam internal.
        // Warna background membantu otak mengenali konteks waktu.
        return trait.userInterfaceStyle == .dark ?
            UIColor(red: 0.04, green: 0.04, blue: 0.16, alpha: 1.0) : // Dark Navy
            UIColor(red: 0.96, green: 0.97, blue: 1.00, alpha: 1.0)  // Off-White/Cloud
    }
}

extension UIColor {
    static let bgOnboarding = UIColor { (traitColletion: UITraitCollection) -> UIColor in
        if traitColletion.userInterfaceStyle == .dark {
            return UIColor(red: 0.05, green: 0.04, blue: 0.18, alpha: 1.0) // Dark Mode
        } else {
            return UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0) // Light Mode
        }
        
    }
}

