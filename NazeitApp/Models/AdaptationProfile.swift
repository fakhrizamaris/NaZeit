//
//  AdaptationProfile.swift
//  NazeitApp
//
//  Data models for user health profiles and flight direction.
//

import Foundation

// MARK: - Adaptation Profile

enum AdaptationProfile: String, Codable, CaseIterable, Sendable {
    case normal
    case gentle
    case insomnia
    
    var maxDailyShiftHours: Double {
        switch self {
        case .normal: return 1.0
        case .gentle, .insomnia: return 0.5
        }
    }
    
    var caffeineCutoffHours: Double {
        switch self {
        case .normal: return 8.0
        case .gentle, .insomnia: return 12.0
        }
    }
    
    var hrvDropThreshold: Double {
        switch self {
        case .normal: return 0.15
        case .gentle, .insomnia: return 0.10
        }
    }
    
    var graceWindowMinutes: Int {
        switch self {
        case .normal: return 60
        case .gentle, .insomnia: return 90
        }
    }
    
    var lightBufferMinutes: Int {
        switch self {
        case .normal, .gentle: return 0
        case .insomnia: return 30
        }
    }
    
    var displayLabel: String {
        switch self {
        case .normal: return "Normal Sleep Pattern"
        case .gentle: return "Elderly (>65 years)"
        case .insomnia: return "Clinical Insomnia"
        }
    }
}

// MARK: - Flight Direction

enum FlightDirection: String, Codable, Sendable {
    case eastward   // Phase Advance
    case westward   // Phase Delay
    
    /// Eastward: 0.95h/day, Westward: 1.53h/day (Waterhouse et al.)
    var adaptationRatePerDay: Double {
        switch self {
        case .eastward: return 0.95
        case .westward: return 1.53
        }
    }
}

// MARK: - Travel Phase

enum TravelPhase: String, Codable, CaseIterable, Sendable {
    case preflight
    case inflight
    case postflight
}

// MARK: - Input Method

enum InputMethod: String, Codable, Sendable {
    case watch
    case manual
}

// MARK: - Arrival Window

enum ArrivalWindow: Sendable {
    case daytime    // 06:00 – 20:00
    case evening    // 20:00 - 22:00
    case nighttime  // 22:00 – 05:00
    
    init(arrivalHour: Int) {
        if arrivalHour >= 6 && arrivalHour < 20 {
            self = .daytime
        } else if arrivalHour >= 20 && arrivalHour < 22 {
            self = .evening
        } else {
            self = .nighttime
        }
        
    }
}

enum TransitWindow: Sendable {
    case day
    case night
    
    init(transitHour: Int) {
        if transitHour >= 6 && transitHour < 22 {
            self = .day
        } else {
            self = .night
        }
    }
}
