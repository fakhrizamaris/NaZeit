//
//  AdaptationProfile.swift
//  NazeitApp
//
//  Data models for user health profiles and flight direction.
//

import Foundation

// MARK: - Adaptation Profile

/// User's health profile that modifies algorithm parameters.
/// Merges Gentle Mode and Insomnia Mode (RumusSchedule §5 & §6).
enum AdaptationProfile: String, Codable, CaseIterable, Sendable {
    case normal
    case gentle     // Elderly (>65 years)
    case insomnia   // Clinical Insomnia

    var maxDailyShiftHours: Double {
        switch self {
        case .normal: return 1.0
        case .gentle, .insomnia: return 0.5
        }
    }

    /// Hours before target bedtime to stop caffeine.
    /// Caffeine half-life ~5–6h. At 8h ~75% eliminated. At 12h ~94%.
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

    /// Extra buffer added to light windows for fragmented sleepers.
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
    case daytime    // 06:00–16:00
    case nighttime  // 18:00–05:00

    init(arrivalHour: Int) {
        self = (arrivalHour >= 6 && arrivalHour <= 16) ? .daytime : .nighttime
    }
}
