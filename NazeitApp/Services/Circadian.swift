//
//  Circadian.swift
//  NazeitApp
//
//  Pure computation functions for circadian rhythm calculations.
//  All formulas sourced from RumusSchedule.md.
//

import Foundation

struct Circadian {

    // MARK: - CBTmin

    static func cbtMin(
        wakeTime: Date,
        method: InputMethod,
        temperatureNadir: Date? = nil
    ) -> Date {
        if method == .watch, let nadir = temperatureNadir {
            return nadir
        }
        return wakeTime.addingTimeInterval(-2.5 * 3600)
    }

    // MARK: - Timezone Gap & Direction (12-Hour Rule)

    static func timezoneGap(fromOffset: Int, toOffset: Int) -> Int {
        (toOffset - fromOffset) / 3600
    }

    static func effectiveGap(
        fromOffset: Int,
        toOffset: Int
    ) -> (hours: Double, direction: FlightDirection) {
        let raw = timezoneGap(fromOffset: fromOffset, toOffset: toOffset)
        let abs = abs(raw)

        if abs > 12 {
            let adjusted = Double(24 - abs)
            let dir: FlightDirection = raw > 0 ? .westward : .eastward
            return (adjusted, dir)
        } else {
            let dir: FlightDirection = raw >= 0 ? .eastward : .westward
            return (Double(abs), dir)
        }
    }

    // MARK: - Daily Shift

    static func dailyShift(gap: Double, days: Int, profile: AdaptationProfile) -> Double {
        guard days > 0 else { return 0 }
        return min(gap / Double(days), profile.maxDailyShiftHours)
    }

    static func totalLoadingShift(gap: Double, days: Int, profile: AdaptationProfile) -> Double {
        min(dailyShift(gap: gap, days: days, profile: profile) * Double(days), gap)
    }

    static func remainingGap(totalGap: Double, days: Int, profile: AdaptationProfile) -> Double {
        max(0, totalGap - totalLoadingShift(gap: totalGap, days: days, profile: profile))
    }

    // MARK: - Recovery

    static func recoveryDays(remaining: Double, direction: FlightDirection) -> Int {
        guard remaining > 0 else { return 0 }
        return Int(ceil(remaining / direction.adaptationRatePerDay))
    }

    // MARK: - Light Windows

    static func lightWindows(
        cbtMin: Date,
        direction: FlightDirection,
        profile: AdaptationProfile
    ) -> (seekStart: Date, seekEnd: Date, avoidStart: Date, avoidEnd: Date) {
        let buf = TimeInterval(profile.lightBufferMinutes * 60)

        switch direction {
        case .eastward:
            return (
                seekStart: cbtMin.addingTimeInterval(-buf),
                seekEnd: cbtMin.addingTimeInterval(4 * 3600 + buf),
                avoidStart: cbtMin.addingTimeInterval(-3 * 3600 - buf),
                avoidEnd: cbtMin.addingTimeInterval(buf)
            )
        case .westward:
            return (
                seekStart: cbtMin.addingTimeInterval(-4 * 3600 - buf),
                seekEnd: cbtMin.addingTimeInterval(buf),
                avoidStart: cbtMin.addingTimeInterval(-buf),
                avoidEnd: cbtMin.addingTimeInterval(3 * 3600 + buf)
            )
        }
    }

    // MARK: - Caffeine Cutoff

    static func caffeineCutoff(bedtime: Date, profile: AdaptationProfile) -> Date {
        bedtime.addingTimeInterval(-profile.caffeineCutoffHours * 3600)
    }

    // MARK: - In-Flight
    static func arrivalWindow(arrival: Date, zone: TimeZone) -> ArrivalWindow {
        let hour = Calendar.current.dateComponents(in: zone, from: arrival).hour ?? 12
        return ArrivalWindow(arrivalHour: hour)
    }

    static func inflightWakeTime(arrival: Date) -> Date {
        arrival.addingTimeInterval(-4 * 3600)
    }

    // MARK: - Adaptation Level

    static func adaptationLevel(daysCompleted: Int, totalDays: Int) -> Double {
        guard totalDays > 0 else { return 1.0 }
        return min(1.0, Double(daysCompleted) / Double(totalDays))
    }

    static func stateLabel(for level: Double) -> String {
        if level < 0.35 { return "Misaligned" }
        if level < 0.65 { return "Adjusting" }
        return "Aligned"
    }

    // MARK: - Sleep Window Shift

    static func shiftedSleepWindow(
        bedtime: Date,
        wakeTime: Date,
        shiftHours: Double,
        dayIndex: Int,
        direction: FlightDirection
    ) -> (bedtime: Date, wakeTime: Date) {
        let seconds = shiftHours * Double(dayIndex + 1) * 3600
        let sign: Double = direction == .eastward ? -1.0 : 1.0
        return (
            bedtime.addingTimeInterval(sign * seconds),
            wakeTime.addingTimeInterval(sign * seconds)
        )
    }

    // MARK: - Prep Days

    static func prepDays(departure: Date, from now: Date = Date()) -> Int {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: departure)).day ?? 0
        // Always provide at least 3 loading days to maximize pre-flight adaptation
        // and minimize recovery time at the destination. Cap at 5 for very early planners.
        guard days > 0 else { return 0 }
        return min(max(days, 3), 5)
    }
}
