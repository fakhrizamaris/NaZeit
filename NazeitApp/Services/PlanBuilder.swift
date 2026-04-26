//
//  PlanBuilder.swift
//  NazeitApp
//
//  Builds a TripPlan from user inputs using Circadian calculations.
//

import Foundation

struct PlanBuilder {
    
    /// Locale-aware time formatter — respects the user's device 12h/24h setting,
    private static let timeFmt: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
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
            
            let cutoff = Circadian.caffeineCutoff(bedtime: bed, profile: profile)
            
            var items: [Instruction] = []
            
            let lightTime = wake
            let lightInst = smartLightInstruction(
                scheduledTime: lightTime,
                duration: 15 * 60,
                direction: direction,
                phase: .preflight
            )
            items.append(lightInst)
            
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
            let flightDuration = arrival.timeIntervalSince(departure)
            let maxSleepSec: TimeInterval = 8 * 3600    // Max 8h (one full cycle)
            let maxNapSec: TimeInterval = 90 * 60        // Max 90 min power nap
            let wakeWindowSec: TimeInterval = 4 * 3600   // 4h awake before landing
            
            let availableSleepSec = max(0, flightDuration - wakeWindowSec)
            let cappedSleepSec: TimeInterval
            
            if availableSleepSec >= 2 * 3600 {
                // Full sleep: cap at 8 hours
                cappedSleepSec = min(availableSleepSec, maxSleepSec)
            } else if availableSleepSec > 0 {
                // Power nap: cap at 90 minutes
                cappedSleepSec = min(availableSleepSec, maxNapSec)
            } else {
                cappedSleepSec = 0
            }
            
            // Calculate when to start sleeping (work backwards from wake time)
            let sleepTime = wakeUp.addingTimeInterval(-cappedSleepSec)
            let stayAwakeDuration = sleepTime.timeIntervalSince(departure)
            
            // If long flight: add "Stay Awake" instruction for the initial hours
            if stayAwakeDuration >= 3600 {
                items.append(Instruction(
                    type: .seekLight, scheduledTime: departure,
                    title: "Stay Awake & Active",
                    detail: "Keep active for the first \(Int(stayAwakeDuration / 3600))h of your flight.",
                    reasoning: "Staying awake early in the flight aligns your wake period with destination daytime.",
                    iconName: "figure.walk", accentColorName: "orange"
                ))
            }
            
            // Dim lights before sleep
            let dimTime = sleepTime.addingTimeInterval(-3600)
            if dimTime > departure {
                items.append(Instruction(
                    type: .dimLights, scheduledTime: dimTime,
                    title: "Dim Cabin Light",
                    detail: "Lower your screen brightness and close the window shade.",
                    reasoning: "Reducing light 1 hour before sleep primes your brain to produce melatonin for better sleep quality.",
                    iconName: "moon.stars.fill", accentColorName: "indigo"
                ))
            }
            
            // Sleep instruction
            let sleepHours = Int(cappedSleepSec / 3600)
            let sleepMins = Int((cappedSleepSec.truncatingRemainder(dividingBy: 3600)) / 60)
            
            let sleepTitle: String
            let sleepDetail: String
            
            if cappedSleepSec >= 2 * 3600 {
                sleepTitle = "Sleep Now"
                sleepDetail = "Sleep for ~\(sleepHours)h\(sleepMins > 0 ? " \(sleepMins)m" : ""). Wake at \(time(wakeUp))."
            } else if cappedSleepSec > 0 {
                sleepTitle = "Power Nap"
                let napMins = Int(cappedSleepSec / 60)
                sleepDetail = "Nap for ~\(napMins) min. Wake at \(time(wakeUp))."
            } else {
                sleepTitle = "Stay Alert"
                sleepDetail = "Short flight — stay awake and keep active."
            }
            
            items.append(Instruction(
                type: .sleep,
                scheduledTime: sleepTime,
                title: sleepTitle,
                detail: sleepDetail,
                reasoning: "Sleeping aligned to destination daytime anchors your circadian clock for faster recovery.",
                iconName: "moon.zzz.fill", accentColorName: "indigo"
            ))
            items.append(Instruction(
                type: .wake,
                scheduledTime: wakeUp,
                title: "Wake Up & Get Active",
                detail: "Have caffeine and stay awake until landing.",
                reasoning: "Waking 4 hours before arrival anchors your wake signal to local daytime.",
                iconName: "sun.max.fill", accentColorName: "orange"
            ))
            
        case .evening:
            let dimTime = arrival.addingTimeInterval(-3600)
            items.append(Instruction(
                type: .dimLights,
                scheduledTime: dimTime,
                title: "Start Wind-Down",
                detail: "Dim your screen and close the window shade — you're arriving in the evening.",
                reasoning: "Reducing light 1 hour before evening arrival helps melatonin rise naturally.",
                iconName: "moon.stars.fill",
                accentColorName: "indigo"
            ))
            items.append(Instruction(
                type: .avoidLight,
                scheduledTime: arrival,
                title: "Avoid Bright Light",
                detail: "Wear sunglasses in the bright airport terminal and keep your hotel lights warm and dim.",
                reasoning: "Bright artificial light will suppress your melatonin and trick your brain into thinking it's daytime, ruining your sleep schedule.",
                iconName: "moon.fill",
                accentColorName: "indigo"
            ))
            let targetBedtime = arrival.addingTimeInterval(2 * 3600)
            items.append(Instruction(
                type: .sleep,
                scheduledTime: targetBedtime,
                title: "Sleep on Time",
                detail: "Aim to be in bed within 2 hours of landing. Put your devices away.",
                reasoning: "Sleeping at the correct local evening time is the strongest 'anchor' to lock your body clock to the new time zone.",
                iconName: "bed.double.fill",
                accentColorName: "cyan"
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
            // Dim lights before transitioning to sleep
            let dimTime = mid.addingTimeInterval(-1800)
            items.append(Instruction(
                type: .dimLights, scheduledTime: dimTime,
                title: "Dim Cabin Light",
                detail: "Start winding down — lower screens and close shades.",
                reasoning: "A 30-minute wind-down before sleep helps your circadian system shift to the destination's night.",
                iconName: "moon.stars.fill", accentColorName: "indigo"
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
        let arrivalLabel: String
        switch window {
        case .daytime:   arrivalLabel = "Daytime Arrival"
        case .evening:   arrivalLabel = "Evening Arrival"
        case .nighttime: arrivalLabel = "Nighttime Arrival"
        }
        
        return DailyProtocol(
            dayIndex: 0,
            phase: .inflight,
            date: departure,
            sleepWindow: sw,
            shiftLabel: arrivalLabel, // ← ganti dari yang lama
            dailyShiftHours: 0,
            instructions: items
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
            
            let cutoff = Circadian.caffeineCutoff(bedtime: bed, profile: profile)
            
            var items: [Instruction] = []
            
            // Use wake time for light instruction timing
            let lightInst = smartLightInstruction(
                scheduledTime: wake,
                duration: 20 * 60,
                direction: direction,
                phase: .postflight
            )
            items.append(lightInst)
            
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
    
    // MARK: - Smart Light Instruction
    private static func smartLightInstruction(
        scheduledTime: Date,
        duration: TimeInterval,
        direction: FlightDirection,
        phase: TravelPhase
    ) -> Instruction {
        let hour = Calendar.current.component(.hour, from: scheduledTime)
        let isPreSunrise = hour < 6
        
        let durationMinutes = Int(duration / 60)
        
        if isPreSunrise {
            // Pre-sunrise: recommend bright indoor light alternatives
            return Instruction(
                type: .seekLight,
                scheduledTime: scheduledTime,
                duration: duration,
                title: "Bright Indoor Light",
                detail: "Turn on all room lights for \(durationMinutes) mins after waking. The sun isn't up yet — bright indoor light helps too.",
                reasoning: "Any bright light signals your brain to stop melatonin. Turn on overhead lights, sit near a bright lamp, or face a window as dawn approaches.",
                iconName: "lightbulb.max.fill", accentColorName: "orange"
            )
        } else {
            // Post-sunrise: recommend outdoor sunlight
            let phaseDetail = phase == .preflight
            ? "Get \(durationMinutes) mins of sunlight immediately after waking up."
            : "Get \(durationMinutes) minutes of outdoor sunlight exposure."
            return Instruction(
                type: .seekLight,
                scheduledTime: scheduledTime,
                duration: duration,
                title: "Seek Morning Sunlight",
                detail: phaseDetail,
                reasoning: direction == .eastward
                ? "Morning sunlight halts melatonin and advances your circadian rhythm to match the destination."
                : "Timed sunlight exposure delays your body clock to align with the new time zone.",
                iconName: "sun.max.fill", accentColorName: "orange"
            )
        }
    }
    
    // MARK: - Conservative Recovery Mode (§4.1)
    static func conservativeInstructions(
        bedtime: Date,
        wakeTime: Date,
        direction: FlightDirection,
        profile: AdaptationProfile
    ) -> [Instruction] {
        let cutoff = Circadian.caffeineCutoff(bedtime: bedtime, profile: profile)
        
        let lightInst = smartLightInstruction(
            scheduledTime: wakeTime,
            duration: 20 * 60,
            direction: direction,
            phase: .postflight
        )
        
        return [
            Instruction(
                type: .sleep, scheduledTime: bedtime,
                title: "Sleep Anchor",
                detail: "Go to bed at \(time(bedtime)) and wake at \(time(wakeTime)). Consistency is the priority.",
                reasoning: "When your plan has been adjusted multiple times, the most effective strategy is to lock in a consistent sleep schedule.",
                iconName: "moon.fill", accentColorName: "cyan"
            ),
            lightInst,
            Instruction(
                type: .caffeineCutoff, scheduledTime: cutoff,
                title: "Caffeine Cutoff",
                detail: "No coffee, tea, or energy drinks after \(time(cutoff)).",
                reasoning: "A conservative caffeine cutoff protects your sleep anchor — the single most important factor for recovery.",
                iconName: "cup.and.saucer.fill", accentColorName: "indigo"
            )
        ]
    }
}
