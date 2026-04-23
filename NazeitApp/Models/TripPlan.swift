//
//  TripPlan.swift
//  NazeitApp
//
//  Data models for the generated adaptation plan.
//

import Foundation

// MARK: - Instruction

struct Instruction: Codable, Identifiable, Sendable {
    let id: UUID
    let type: InstructionType
    let scheduledTime: Date
    let duration: TimeInterval?
    let title: String
    let detail: String
    let reasoning: String
    let iconName: String
    let accentColorName: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        type: InstructionType,
        scheduledTime: Date,
        duration: TimeInterval? = nil,
        title: String,
        detail: String,
        reasoning: String,
        iconName: String,
        accentColorName: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.type = type
        self.scheduledTime = scheduledTime
        self.duration = duration
        self.title = title
        self.detail = detail
        self.reasoning = reasoning
        self.iconName = iconName
        self.accentColorName = accentColorName
        self.isCompleted = isCompleted
    }
}

enum InstructionType: String, Codable, Sendable {
    case seekLight
    case avoidLight
    case sleep
    case wake
    case caffeineCutoff
    case exercise
    case meal
    case dimLights
}

// MARK: - Sleep Window

struct SleepWindow: Codable, Sendable {
    let bedtime: Date
    let wakeTime: Date

    var durationHours: Double {
        let diff = wakeTime.timeIntervalSince(bedtime)
        let hours = diff / 3600
        return hours > 0 ? hours : hours + 24
    }
}

// MARK: - Daily Protocol

struct DailyProtocol: Codable, Identifiable, Sendable {
    let id: UUID
    let dayIndex: Int
    let phase: TravelPhase
    let date: Date
    let sleepWindow: SleepWindow
    let shiftLabel: String
    let dailyShiftHours: Double
    var instructions: [Instruction]

    init(
        id: UUID = UUID(),
        dayIndex: Int,
        phase: TravelPhase,
        date: Date,
        sleepWindow: SleepWindow,
        shiftLabel: String,
        dailyShiftHours: Double,
        instructions: [Instruction] = []
    ) {
        self.id = id
        self.dayIndex = dayIndex
        self.phase = phase
        self.date = date
        self.sleepWindow = sleepWindow
        self.shiftLabel = shiftLabel
        self.dailyShiftHours = dailyShiftHours
        self.instructions = instructions
    }
}

// MARK: - Trip Plan (full generated plan)

struct TripPlan: Codable, Sendable {
    let createdAt: Date
    let direction: FlightDirection
    let totalGapHours: Double
    let profile: AdaptationProfile
    let estimatedRecoveryDays: Int
    var loadingPhase: [DailyProtocol]
    var inflightProtocol: DailyProtocol?
    var recoveryPhase: [DailyProtocol]
    var recalcCount: Int

    init(
        createdAt: Date = Date(),
        direction: FlightDirection,
        totalGapHours: Double,
        profile: AdaptationProfile,
        estimatedRecoveryDays: Int,
        loadingPhase: [DailyProtocol] = [],
        inflightProtocol: DailyProtocol? = nil,
        recoveryPhase: [DailyProtocol] = [],
        recalcCount: Int = 0
    ) {
        self.createdAt = createdAt
        self.direction = direction
        self.totalGapHours = totalGapHours
        self.profile = profile
        self.estimatedRecoveryDays = estimatedRecoveryDays
        self.loadingPhase = loadingPhase
        self.inflightProtocol = inflightProtocol
        self.recoveryPhase = recoveryPhase
        self.recalcCount = recalcCount
    }
}
