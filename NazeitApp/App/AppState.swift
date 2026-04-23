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

    // MARK: - Trip Configuration
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
    @Published var departureDate: Date = Date() {
        didSet { scheduleSave() }
    }
    @Published var arrivalDate: Date = Date().addingTimeInterval(3600 * 15) {
        didSet { scheduleSave() }
    }
    @Published var hasTransit: Bool = false {
        didSet { scheduleSave() }
    }
    @Published var transitCity: String = "" {
        didSet { scheduleSave() }
    }
    @Published var layoverDuration: Int = 2 {
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
    @Published var circadianLevel: Double = 0.0
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

    // MARK: - Computed Engine Values

    /// Core Body Temperature minimum (Section 1.A)
    var cbtMin: Date {
        Circadian.cbtMin(wakeTime: preferredWakeTime, method: inputMethod)
    }

    /// Effective timezone gap and flight direction (with 12-Hour Rule)
    var effectiveGap: (hours: Double, direction: FlightDirection) {
        Circadian.effectiveGap(
            fromOffset: fromTimeZone.secondsFromGMT(for: departureDate),
            toOffset: toTimeZone.secondsFromGMT(for: arrivalDate)
        )
    }

    /// Raw timezone shift in hours
    var timezoneShiftHours: Int {
        Circadian.timezoneGap(
            fromOffset: fromTimeZone.secondsFromGMT(for: departureDate),
            toOffset: toTimeZone.secondsFromGMT(for: arrivalDate)
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
        circadianLevel = 0.0
        adaptationPercent = 0.0
        recalcCount = 0
        loadingPhaseDayIndex = 0
        recoveryPhaseDayIndex = 0

        Task {
            await NotificationService.shared.schedule(for: plan)
        }
    }

    /// Recalculate plan after deviation (max 2x per phase, Section 4.1)
    func recalculatePlanIfAllowed() -> Bool {
        guard recalcCount < 2 else { return false }
        generatePlan()
        recalcCount += 1
        tripPlan?.recalcCount = recalcCount
        return true
    }

    /// Reset for a new trip
    func resetForNewTrip() {
        fromCity = ""
        toCity = ""
        fromTimeZone = .current
        toTimeZone = .current
        departureDate = Date()
        arrivalDate = Date().addingTimeInterval(3600 * 15)
        hasTransit = false
        transitCity = ""
        layoverDuration = 2
        adaptationPercent = 0.0
        daysRemaining = 0
        loadingPhaseDayIndex = 0
        recoveryPhaseDayIndex = 0
        recalcCount = 0
        tripPlan = nil
        travelPhase = .preflight
        circadianLevel = 0.0
        NotificationService.shared.cancelAll()
    }

    /// Reset recalcCount on phase transition (Section 4.1 Reset Policy)
    func transitionPhase(to phase: TravelPhase) {
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
            tripPlan = snapshot.tripPlan

            if let plan = tripPlan {
                daysRemaining = plan.estimatedRecoveryDays
            }
        } catch {
            print("[AppState] Load failed: \(error)")
        }
    }

    /// Check if there's a saved trip in progress
    var hasSavedTrip: Bool {
        UserDefaults.standard.data(forKey: Self.storageKey) != nil && !fromCity.isEmpty && !toCity.isEmpty
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
