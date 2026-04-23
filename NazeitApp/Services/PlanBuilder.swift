//
//  PlanBuilder.swift
//  NazeitApp
//
//  Builds a TripPlan from user inputs using Circadian calculations.
//

import Foundation

struct PlanBuilder {

    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        return f
    }()

    static func time(_ date: Date) -> String { timeFmt.string(from: date) }

    // MARK: - Build Full Plan

    static func build(
        bedtime: Date,
        wakeTime: Date,
        departure: Date,
        arrival: Date,
        fromZone: TimeZone,
        toZone: TimeZone,
        profile: AdaptationProfile,
        method: InputMethod
    ) -> TripPlan {

        let (gap, direction) = Circadian.effectiveGap(
            fromOffset: fromZone.secondsFromGMT(for: departure),
            toOffset: toZone.secondsFromGMT(for: arrival)
        )
        let days = Circadian.prepDays(departure: departure)
        let shift = Circadian.dailyShift(gap: gap, days: days, profile: profile)
        let remaining = Circadian.remainingGap(totalGap: gap, days: days, profile: profile)
        let recovery = Circadian.recoveryDays(remaining: remaining, direction: direction)

        let loading = buildLoading(
            bedtime: bedtime, wakeTime: wakeTime, departure: departure,
            shift: shift, days: days, direction: direction, profile: profile, method: method
        )
        let inflight = buildInflight(
            departure: departure, arrival: arrival, toZone: toZone,
            direction: direction, profile: profile
        )
        let recoveryPhase = buildRecovery(
            arrival: arrival, bedtime: bedtime, wakeTime: wakeTime,
            toZone: toZone, remaining: remaining, recoveryDays: recovery,
            direction: direction, profile: profile, method: method
        )

        return TripPlan(
            direction: direction, totalGapHours: gap, profile: profile,
            estimatedRecoveryDays: recovery,
            loadingPhase: loading, inflightProtocol: inflight, recoveryPhase: recoveryPhase
        )
    }

    // MARK: - Loading Phase

    private static func buildLoading(
        bedtime: Date, wakeTime: Date, departure: Date,
        shift: Double, days: Int, direction: FlightDirection,
        profile: AdaptationProfile, method: InputMethod
    ) -> [DailyProtocol] {
        guard days > 0 else { return [] }
        let cal = Calendar.current

        return (0..<days).map { i in
            let date = cal.date(byAdding: .day, value: -(days - i), to: departure) ?? departure
            let (bed, wake) = Circadian.shiftedSleepWindow(
                bedtime: bedtime, wakeTime: wakeTime,
                shiftHours: shift, dayIndex: i, direction: direction
            )
            let window = SleepWindow(bedtime: bed, wakeTime: wake)
            let total = shift * Double(i + 1)
            let label = String(format: "-%.\(total.truncatingRemainder(dividingBy: 1) == 0 ? "0" : "1")f Hour Shift", total)

            let cbt = Circadian.cbtMin(wakeTime: wake, method: method)
            let light = Circadian.lightWindows(cbtMin: cbt, direction: direction, profile: profile)
            let cutoff = Circadian.caffeineCutoff(bedtime: bed, profile: profile)

            var items: [Instruction] = []

            items.append(Instruction(
                type: .seekLight, scheduledTime: light.seekStart, duration: 15 * 60,
                title: "Seek Morning Light",
                detail: "Get 15 mins of sunlight immediately after waking up.",
                reasoning: "Early bright light halts melatonin production and anchors your circadian rhythm.",
                iconName: "sun.max.fill", accentColorName: "orange"
            ))
            items.append(Instruction(
                type: .caffeineCutoff, scheduledTime: cutoff,
                title: "Caffeine Cutoff",
                detail: "Limit coffee or tea intake after \(time(cutoff)).",
                reasoning: profile == .normal
                    ? "Caffeine masks sleep pressure, making it harder to shift your bedtime earlier."
                    : "Your profile requires a longer caffeine clearance window to protect sleep quality.",
                iconName: "cup.and.saucer.fill", accentColorName: "indigo"
            ))

            let dimTime = bed.addingTimeInterval(-2 * 3600)
            items.append(Instruction(
                type: .dimLights, scheduledTime: dimTime,
                title: "Dim the Lights",
                detail: "Switch to warm lights, use blue-light blockers, or simply wear an eye mask.",
                reasoning: "Dim light signals your brain that night is approaching, naturally inducing sleep.",
                iconName: "moon.fill", accentColorName: "cyan"
            ))

            return DailyProtocol(
                dayIndex: i, phase: .preflight, date: date, sleepWindow: window,
                shiftLabel: label, dailyShiftHours: shift, instructions: items
            )
        }
    }

    // MARK: - In-Flight Protocol

    private static func buildInflight(
        departure: Date, arrival: Date, toZone: TimeZone,
        direction: FlightDirection, profile: AdaptationProfile
    ) -> DailyProtocol {
        let window = Circadian.arrivalWindow(arrival: arrival, zone: toZone)
        var items: [Instruction] = []

        switch window {
        case .daytime:
            let wakeUp = Circadian.inflightWakeTime(arrival: arrival)
            items.append(Instruction(
                type: .sleep, scheduledTime: departure.addingTimeInterval(3600),
                title: "Sleep Now",
                detail: "4 hrs before destination arrival",
                reasoning: "Sleeping now aligns your body with daytime at destination.",
                iconName: "moon.zzz.fill", accentColorName: "indigo"
            ))
            items.append(Instruction(
                type: .wake, scheduledTime: wakeUp,
                title: "Wake Up & Get Active",
                detail: "Have caffeine and stay awake until landing.",
                reasoning: "Waking 4 hours before arrival anchors your wake signal to local daytime.",
                iconName: "sun.max.fill", accentColorName: "orange"
            ))
        case .nighttime:
            let mid = departure.addingTimeInterval(arrival.timeIntervalSince(departure) * 0.6)
            items.append(Instruction(
                type: .seekLight, scheduledTime: departure.addingTimeInterval(3600),
                title: "Stay Awake & Active",
                detail: "Keep cabin light on, stay active in the first half of your flight.",
                reasoning: "Staying awake early delays your body clock to match destination night.",
                iconName: "figure.walk", accentColorName: "orange"
            ))
            items.append(Instruction(
                type: .sleep, scheduledTime: mid,
                title: "Sleep in the Second Half",
                detail: "Try to sleep for the remainder of the flight.",
                reasoning: "Late-flight sleep helps your body transition to the destination's nighttime.",
                iconName: "moon.zzz.fill", accentColorName: "indigo"
            ))
        }

        let sw = SleepWindow(
            bedtime: items.first(where: { $0.type == .sleep })?.scheduledTime ?? departure,
            wakeTime: items.first(where: { $0.type == .wake })?.scheduledTime ?? arrival
        )

        return DailyProtocol(
            dayIndex: 0, phase: .inflight, date: departure, sleepWindow: sw,
            shiftLabel: window == .daytime ? "Daytime Arrival" : "Nighttime Arrival",
            dailyShiftHours: 0, instructions: items
        )
    }

    // MARK: - Recovery Phase

    private static func buildRecovery(
        arrival: Date, bedtime: Date, wakeTime: Date, toZone: TimeZone,
        remaining: Double, recoveryDays: Int, direction: FlightDirection,
        profile: AdaptationProfile, method: InputMethod
    ) -> [DailyProtocol] {
        let cal = Calendar.current
        let count = min(recoveryDays, 7)
        guard count > 0 else { return [] }

        return (0..<count).map { i in
            let date = cal.date(byAdding: .day, value: i + 1, to: arrival) ?? arrival
            let progress = min(1.0, Double(i + 1) / Double(recoveryDays))
            let gapLeft = remaining * (1.0 - progress)
            let offset = gapLeft * 3600 * (direction == .eastward ? 1.0 : -1.0)

            let bed = bedtime.addingTimeInterval(offset)
            let wake = wakeTime.addingTimeInterval(offset)
            let window = SleepWindow(bedtime: bed, wakeTime: wake)

            let label: String
            if i == 0 { label = "Arrival Day" }
            else if i == count - 1 { label = "Fully Adapted" }
            else { label = "Recovery Day \(i + 1)" }

            let cbt = Circadian.cbtMin(wakeTime: wake, method: method)
            let light = Circadian.lightWindows(cbtMin: cbt, direction: direction, profile: profile)
            let cutoff = Circadian.caffeineCutoff(bedtime: bed, profile: profile)

            var items: [Instruction] = []

            items.append(Instruction(
                type: .seekLight, scheduledTime: light.seekStart, duration: 20 * 60,
                title: "Seek Sunlight",
                detail: "Get 20 minutes of outdoor light exposure.",
                reasoning: direction == .eastward
                    ? "Morning light advances your clock to match local time."
                    : "Afternoon light delays your clock to match local time.",
                iconName: "sun.max.fill", accentColorName: "orange"
            ))
            items.append(Instruction(
                type: .exercise,
                scheduledTime: cal.date(bySettingHour: 15, minute: 0, second: 0, of: date) ?? date,
                duration: 20 * 60,
                title: "Light Exercise",
                detail: "Do a 20-min walk under the sun.",
                reasoning: "Late afternoon light exposure pushes your body clock later to match the local timezone.",
                iconName: "figure.walk", accentColorName: "orange"
            ))
            items.append(Instruction(
                type: .caffeineCutoff, scheduledTime: cutoff,
                title: "Caffeine Cutoff",
                detail: "No coffee or tea after \(time(cutoff)).",
                reasoning: "Caffeine blocks adenosine receptors. Clearing it before bed protects your sleep anchor.",
                iconName: "cup.and.saucer.fill", accentColorName: "indigo"
            ))
            items.append(Instruction(
                type: .sleep, scheduledTime: bed,
                title: "Sleep Strictness",
                detail: "Go to bed exactly at \(time(bed)) local time.",
                reasoning: "Strictly anchoring your sleep builds biological consistency to clear jet lag faster.",
                iconName: "moon.fill", accentColorName: "cyan"
            ))

            return DailyProtocol(
                dayIndex: i, phase: .postflight, date: date, sleepWindow: window,
                shiftLabel: label, dailyShiftHours: direction.adaptationRatePerDay,
                instructions: items
            )
        }
    }
}
