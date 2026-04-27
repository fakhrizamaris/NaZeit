//
//  AppState.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 14/04/26.
//
//  Central state management with persistence and engine integration.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {

    // MARK: - User Profile
    @Published var inputMethod: InputMethod = .manual {
        didSet { scheduleSave() }
    }
    @Published var adaptationProfile: AdaptationProfile = .normal {
        didSet { scheduleSave() }
    }
    @Published var preferredBedtime: Date = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date()) ?? Date() {
        didSet { scheduleSave() }
    }
    @Published var preferredWakeTime: Date = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date() {
        didSet { scheduleSave() }
    }
    @Published var sleepHours: Double = 7.2

    // MARK: - Watch Data (reserved for future Apple Watch integration)
    @Published var currentHRV: Int = 0
    @Published var baselineHRV: Int = 0
    @Published var consecutiveGoodSleeps: Int = 0

    // MARK: - Trip Configuration
    @Published var hasTransit: Bool = false {
        didSet { scheduleSave() }
    }
    @Published var transitCity: String = "" {
        didSet { scheduleSave() }
    }
    @Published var layoverDuration: Int = 2 {
        didSet { scheduleSave() }
    }
    @Published var transitTimeZone: TimeZone = .current {
        didSet { scheduleSave() }
    }
    @Published var fromCity: String = "" {
        didSet { scheduleSave() }
    }
    @Published var toCity: String = "" {
        didSet { scheduleSave() }
    }
    @Published var fromTimeZone: TimeZone = .current {
        didSet { scheduleSave() }
    }
    @Published var toTimeZone: TimeZone = .current {
        didSet { scheduleSave() }
    }
    @Published var departureDate: Date = Date().addingTimeInterval(86400 * 3) {
        didSet { scheduleSave() }
    }
    @Published var arrivalDate: Date = Date().addingTimeInterval(86400 * 3 + 3600 * 15) {
        didSet { scheduleSave() }
    }


    // MARK: - Health Screening
    @Published var isSleepDisorder = false
    @Published var selectedDisorder = ""

    // MARK: - Plan Output
    @Published var tripPlan: TripPlan? {
        didSet { scheduleSave() }
    }

    // MARK: - Phase & Progress
    @Published var travelPhase: TravelPhase = .preflight {
        didSet { scheduleSave() }
    }
    /// Single source of truth for adaptation progress.
    /// `circadianLevel` is a convenience alias — always reads from `adaptationPercent`.
    var circadianLevel: Double { adaptationPercent }
    @Published var adaptationPercent: Double = 0.0
    @Published var daysRemaining: Int = 0
    @Published var recalcCount: Int = 0 {
        didSet { scheduleSave() }
    }

    // MARK: - Phase Day Index Persistence
    @Published var loadingPhaseDayIndex: Int = 0 {
        didSet { scheduleSave() }
    }
    @Published var recoveryPhaseDayIndex: Int = 0 {
        didSet { scheduleSave() }
    }

    // MARK: - In-Flight Step Completion Guard
    @Published var completedInflightSteps: Set<String> = [] {
        didSet { scheduleSave() }
    }

    // MARK: - Daily Protocol Step Completion
    @Published var completedProtocolSteps: Set<String> = [] {
        didSet { scheduleSave() }
    }

    @discardableResult
    func completeInflightStep(_ stepId: String, credit: Double) -> Bool {
        guard !completedInflightSteps.contains(stepId) else { return false }
        completedInflightSteps.insert(stepId)
        adaptationPercent = min(1.0, adaptationPercent + credit)
        return true
    }

    /// Whether the system is in Conservative Recovery Mode (§4.1)
    var isConservativeMode: Bool {
        recalcCount >= 2
    }

    // MARK: - Computed Engine Values

    /// Core Body Temperature minimum (Section 1.A)
    var cbtMin: Date {
        Circadian.cbtMin(wakeTime: preferredWakeTime, method: inputMethod)
    }

    /// Effective timezone gap and flight direction (with 12-Hour Rule)
    /// Uses departureDate as the single reference point for both timezones
    /// to avoid DST-related discrepancies.
    var effectiveGap: (hours: Double, direction: FlightDirection) {
        Circadian.effectiveGap(
            fromOffset: fromTimeZone.secondsFromGMT(for: departureDate),
            toOffset: toTimeZone.secondsFromGMT(for: departureDate)
        )
    }

    /// Raw timezone shift in hours
    var timezoneShiftHours: Int {
        Circadian.timezoneGap(
            fromOffset: fromTimeZone.secondsFromGMT(for: departureDate),
            toOffset: toTimeZone.secondsFromGMT(for: departureDate)
        )
    }

    /// Estimated recovery days
    var estimatedRecoveryDays: Int {
        let (gap, direction) = effectiveGap
        let remaining = Circadian.remainingGap(
            totalGap: gap,
            days: Circadian.prepDays(departure: departureDate),
            profile: adaptationProfile
        )
        return Circadian.recoveryDays(remaining: remaining, direction: direction)
    }

    /// Formatted bedtime string for display
    var bedtimeString: String {
        Self.timeFormatter.string(from: preferredBedtime)
    }

    /// Formatted wake time string for display
    var wakeTimeString: String {
        Self.timeFormatter.string(from: preferredWakeTime)
    }

    // MARK: - Plan Generation

    func generatePlan() {
        // Safety: if departure is in the past (stale data), push it to 3 days from now
        // so the user always gets a meaningful loading phase.
        if departureDate < Date() {
            departureDate = Date().addingTimeInterval(86400 * 3)
            arrivalDate = departureDate.addingTimeInterval(3600 * 15)
        }

        let plan = PlanBuilder.build(
            bedtime: preferredBedtime,
            wakeTime: preferredWakeTime,
            departure: departureDate,
            arrival: arrivalDate,
            fromZone: fromTimeZone,
            toZone: toTimeZone,
            profile: adaptationProfile,
            method: inputMethod
        )
        tripPlan = plan
        daysRemaining = plan.estimatedRecoveryDays
        adaptationPercent = plan.totalGapHours == 0 ? 1.0 : 0.0
        recalcCount = 0
        loadingPhaseDayIndex = 0
        recoveryPhaseDayIndex = 0

        Task {
            await NotificationService.shared.schedule(for: plan)
        }
    }

    /// Recalculate plan after deviation (max 2x per phase, Section 4.1)
    /// Each deviation extends estimated recovery by +1 day (adaptation penalty).
    @discardableResult
    func recalculatePlanIfAllowed() -> Bool {
        guard recalcCount < 2 else { return false }
        generatePlan()
        recalcCount += 1
        tripPlan?.recalcCount = recalcCount

        // Penalty: each deviation adds +1 day to recovery estimate
        if let plan = tripPlan {
            let penaltyDays = recalcCount
            let extended = plan.estimatedRecoveryDays + penaltyDays
            // Rebuild recovery phase with extended days
            daysRemaining = extended
        }
        return true
    }

    /// Call when the user completes a full day without deviation.
    /// Per §4.1: "reset ke 0 jika user menyelesaikan 1 siklus harian tanpa deviasi mayor"
    func completeSuccessfulDay() {
        if recalcCount > 0 {
            recalcCount = 0
            tripPlan?.recalcCount = 0
        }
    }

    /// Reset only the trip-specific fields (keeps user profile like bedtime/wakeTime).
    /// Call this when navigating to YourTrip from onboarding to ensure a clean slate.
    func resetTripFields() {
        fromCity = ""
        toCity = ""
        fromTimeZone = .current
        toTimeZone = .current
        departureDate = Date().addingTimeInterval(86400 * 3)
        arrivalDate = Date().addingTimeInterval(86400 * 3 + 3600 * 15)
        hasTransit = false
        transitCity = ""
        layoverDuration = 2
        adaptationPercent = 0.0
        daysRemaining = 0
        loadingPhaseDayIndex = 0
        recoveryPhaseDayIndex = 0
        recalcCount = 0
        consecutiveGoodSleeps = 0
        tripPlan = nil
        travelPhase = .preflight
        restedLoadingDays.removeAll()
        restedRecoveryDays.removeAll()
        completedInflightSteps = []
        NotificationService.shared.cancelAll()
    }

    /// Reset for a new trip (full reset)
    func resetForNewTrip() {
        resetTripFields()
    }

    /// Track which days have been rested
    @Published var restedLoadingDays: Set<Int> = []
    @Published var restedRecoveryDays: Set<Int> = []

    /// Safety Override state for current day
    var isRestDayActive: Bool {
        if travelPhase == .preflight {
            return restedLoadingDays.contains(loadingPhaseDayIndex)
        } else if travelPhase == .postflight {
            return restedRecoveryDays.contains(recoveryPhaseDayIndex)
        }
        return false
    }

    /// Toggle rest mode for the current day, allowing users to resume schedule
    func toggleRestMode() {
        if travelPhase == .preflight {
            if restedLoadingDays.contains(loadingPhaseDayIndex) {
                restedLoadingDays.remove(loadingPhaseDayIndex)
            } else {
                restedLoadingDays.insert(loadingPhaseDayIndex)
            }
        } else if travelPhase == .postflight {
            if restedRecoveryDays.contains(recoveryPhaseDayIndex) {
                restedRecoveryDays.remove(recoveryPhaseDayIndex)
            } else {
                restedRecoveryDays.insert(recoveryPhaseDayIndex)
            }
        }
    }

    // MARK: - HRV-based "Fully Adapted"

    /// Call after each sleep cycle (Apple Watch mode).
    /// If HRV ratio >= 90% for 2 consecutive cycles → Fully Adapted.
    func recordSleepCycleHRV(currentHRV: Int) {
        guard inputMethod == .watch, baselineHRV > 0 else { return }
        self.currentHRV = currentHRV

        let ratio = Double(currentHRV) / Double(baselineHRV)
        if ratio >= 0.90 {
            consecutiveGoodSleeps += 1
        } else {
            consecutiveGoodSleeps = 0
        }
    }

    /// Whether the user is fully adapted based on HRV (Watch mode)
    var isHRVFullyAdapted: Bool {
        inputMethod == .watch && consecutiveGoodSleeps >= 2
    }

    /// Whether the user is fully adapted based on time (Manual mode)
    /// Checks if days since arrival >= estimated recovery days
    var isTimeBasedFullyAdapted: Bool {
        guard inputMethod == .manual,
              travelPhase == .postflight,
              let plan = tripPlan else { return false }
        let daysSinceArrival = Calendar.current.dateComponents(
            [.day], from: Calendar.current.startOfDay(for: arrivalDate),
            to: Calendar.current.startOfDay(for: Date())
        ).day ?? 0
        return daysSinceArrival >= plan.estimatedRecoveryDays
    }

    /// Combined check for fully adapted status (both modes)
    var isFullyAdapted: Bool {
        guard travelPhase == .postflight else { return false }
        
        if let plan = tripPlan, plan.estimatedRecoveryDays == 0 {
            return true
        }
        
        return adaptationPercent >= 1.0 || isHRVFullyAdapted || isTimeBasedFullyAdapted
    }

    /// Update phase and calculate adaptation progress based on completed work.
    /// - preflight → inflight: credit the loading phase shift
    /// - inflight → postflight: no bulk credit (each in-flight step already credited individually)
    func transitionPhase(to phase: TravelPhase) {
        if let plan = tripPlan {
            let totalGap = plan.totalGapHours
            guard totalGap > 0 else {
                travelPhase = phase
                recalcCount = 0
                return
            }

            switch (travelPhase, phase) {
            case (.preflight, .inflight):
                // Credit loading phase: each completed day shifts by dailyShift hours
                let loadingDays = plan.loadingPhase.count
                let loadingShift = Circadian.totalLoadingShift(
                    gap: totalGap,
                    days: loadingDays,
                    profile: plan.profile
                )
                adaptationPercent = min(1.0, loadingShift / totalGap)

            case (.inflight, .postflight):
                // Credit in-flight sleep alignment (§3): sleeping synced to
                // destination time covers ~1 adaptation-rate unit toward recovery.
                let inflightCredit = plan.direction.adaptationRatePerDay
                let creditPercent = inflightCredit / totalGap
                adaptationPercent = min(1.0, adaptationPercent + creditPercent)

                // Reduce remaining recovery days based on in-flight credit
                let remaining = Circadian.remainingGap(
                    totalGap: totalGap,
                    days: plan.loadingPhase.count,
                    profile: plan.profile
                )
                let adjustedRemaining = max(0, remaining - inflightCredit)
                daysRemaining = Circadian.recoveryDays(
                    remaining: adjustedRemaining,
                    direction: plan.direction
                )
                
                if daysRemaining == 0 {
                    adaptationPercent = 1.0
                }

            default:
                break
            }

            // circadianLevel is now a computed property — always reads adaptationPercent
        }

        travelPhase = phase
        recalcCount = 0
    }

    // MARK: - Persistence
    private static let storageKey = "nazeit_app_state"
    private var saveWorkItem: DispatchWorkItem?

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    /// Debounced save — prevents excessive writes during rapid changes.
    private func scheduleSave() {
        saveWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.saveToDisk()
        }
        saveWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
    }

    func saveToDisk() {
        let snapshot = PersistableState(
            inputMethod: inputMethod,
            adaptationProfile: adaptationProfile,
            preferredBedtime: preferredBedtime,
            preferredWakeTime: preferredWakeTime,
            fromCity: fromCity,
            toCity: toCity,
            fromTimeZoneId: fromTimeZone.identifier,
            toTimeZoneId: toTimeZone.identifier,
            departureDate: departureDate,
            arrivalDate: arrivalDate,
            hasTransit: hasTransit,
            transitCity: transitCity,
            layoverDuration: layoverDuration,
            travelPhase: travelPhase,
            loadingPhaseDayIndex: loadingPhaseDayIndex,
            recoveryPhaseDayIndex: recoveryPhaseDayIndex,
            recalcCount: recalcCount,
            completedInflightSteps: Array(completedInflightSteps),
            completedProtocolSteps: Array(completedProtocolSteps),
            adaptationPercent: adaptationPercent,
            tripPlan: tripPlan
        )

        do {
            let data = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        } catch {
            print("[AppState] Save failed: \(error)")
        }
    }

    func loadFromDisk() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey) else { return }

        do {
            let snapshot = try JSONDecoder().decode(PersistableState.self, from: data)
            inputMethod = snapshot.inputMethod
            adaptationProfile = snapshot.adaptationProfile
            preferredBedtime = snapshot.preferredBedtime
            preferredWakeTime = snapshot.preferredWakeTime
            fromCity = snapshot.fromCity
            toCity = snapshot.toCity
            fromTimeZone = TimeZone(identifier: snapshot.fromTimeZoneId) ?? .current
            toTimeZone = TimeZone(identifier: snapshot.toTimeZoneId) ?? .current
            departureDate = snapshot.departureDate
            arrivalDate = snapshot.arrivalDate
            hasTransit = snapshot.hasTransit
            transitCity = snapshot.transitCity
            layoverDuration = snapshot.layoverDuration
            travelPhase = snapshot.travelPhase
            loadingPhaseDayIndex = snapshot.loadingPhaseDayIndex
            recoveryPhaseDayIndex = snapshot.recoveryPhaseDayIndex
            recalcCount = snapshot.recalcCount
            completedInflightSteps = Set(snapshot.completedInflightSteps)
            completedProtocolSteps = Set(snapshot.completedProtocolSteps ?? [])
            adaptationPercent = snapshot.adaptationPercent
            tripPlan = snapshot.tripPlan

            if let plan = tripPlan {
                daysRemaining = plan.estimatedRecoveryDays
            }
            
            // If the trip is still in preflight and there's no active in-flight/recovery phase,
            // check if the saved trip data is stale and should be cleared.
            if travelPhase == .preflight && tripPlan == nil && !fromCity.isEmpty {
                // Old trip setup that was never completed — clear it
                resetTripFields()
            } else if travelPhase == .preflight && departureDate < Date() {
                // Departure has passed but user never progressed past preflight
                resetTripFields()
            }
            
        } catch {
            print("[AppState] Load failed: \(error)")
        }
    }

    /// Check if there's a saved trip in progress
    var hasSavedTrip: Bool {
        UserDefaults.standard.data(forKey: Self.storageKey) != nil && tripPlan != nil
    }
}

// MARK: - Persistable Snapshot
/// Codable struct for disk persistence. TimeZone is stored as identifier string.
private struct PersistableState: Codable {
    let inputMethod: InputMethod
    let adaptationProfile: AdaptationProfile
    let preferredBedtime: Date
    let preferredWakeTime: Date
    let fromCity: String
    let toCity: String
    let fromTimeZoneId: String
    let toTimeZoneId: String
    let departureDate: Date
    let arrivalDate: Date
    let hasTransit: Bool
    let transitCity: String
    let layoverDuration: Int
    let travelPhase: TravelPhase
    let loadingPhaseDayIndex: Int
    let recoveryPhaseDayIndex: Int
    let recalcCount: Int
    let completedInflightSteps: [String]
    let completedProtocolSteps: [String]?
    let adaptationPercent: Double
    let tripPlan: TripPlan?
}


// MARK: - UIColor Extensions (unchanged)
extension UIColor {
    static let nazeitTeal = UIColor { trait in
        return trait.userInterfaceStyle == .dark ?
        UIColor(red: 0.10, green: 0.50, blue: 0.38, alpha: 1.0) :
        UIColor(red: 0.12, green: 0.62, blue: 0.52, alpha: 1.0)
    }

    static let circadianTeal = UIColor.nazeitTeal

    static let nazeitBackground = UIColor { trait in
        return trait.userInterfaceStyle == .dark ?
        UIColor(red: 0.04, green: 0.04, blue: 0.16, alpha: 1.0) :
        UIColor(red: 0.96, green: 0.97, blue: 1.00, alpha: 1.0)
    }
}

extension UIColor {
    static let bgOnboarding = UIColor { (traitColletion: UITraitCollection) -> UIColor in
        if traitColletion.userInterfaceStyle == .dark {
            return UIColor(red: 0.05, green: 0.04, blue: 0.18, alpha: 1.0)
        } else {
            return UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0)
        }
    }
}
