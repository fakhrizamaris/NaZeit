//
//  NotificationService.swift
//  NazeitApp
//
//  Schedules local notifications for circadian protocol reminders.
//

import Foundation
import Combine
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    private let center = UNUserNotificationCenter.current()

    // MARK: - Authorization

    func requestAuthorization() async {
        do {
            isAuthorized = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("[Notifications] Authorization error: \(error)")
        }
    }

    // MARK: - Schedule Plan Notifications

    func schedule(for plan: TripPlan) async {
        cancelAll()

        if !isAuthorized {
            await requestAuthorization()
        }
        guard isAuthorized else { return }

        for day in plan.loadingPhase {
            for item in day.instructions { await schedule(item, phase: .preflight, day: day.dayIndex) }
            await scheduleSleepReminder(day.sleepWindow, day: day.dayIndex, phase: .preflight)
        }

        if let inflight = plan.inflightProtocol {
            for item in inflight.instructions { await schedule(item, phase: .inflight, day: 0) }
        }

        for day in plan.recoveryPhase {
            for item in day.instructions { await schedule(item, phase: .postflight, day: day.dayIndex) }
            await scheduleSleepReminder(day.sleepWindow, day: day.dayIndex, phase: .postflight)
        }
    }

    // MARK: - Individual Instruction

    private func schedule(_ instruction: Instruction, phase: TravelPhase, day: Int) async {
        guard instruction.scheduledTime > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = instruction.title
        content.body = instruction.detail
        content.sound = .default
        content.categoryIdentifier = "circadian_\(instruction.type.rawValue)"
        content.userInfo = ["type": instruction.type.rawValue, "phase": phase.rawValue, "day": day]

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: instruction.scheduledTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id = "nazeit_\(phase.rawValue)_d\(day)_\(instruction.type.rawValue)_\(instruction.id.uuidString.prefix(8))"

        do {
            try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        } catch {
            print("[Notifications] Schedule failed: \(error)")
        }
    }

    // MARK: - Sleep Reminder (30 min before bedtime)

    private func scheduleSleepReminder(_ window: SleepWindow, day: Int, phase: TravelPhase) async {
        let time = window.bedtime.addingTimeInterval(-30 * 60)
        guard time > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Bedtime in 30 Minutes"
        content.body = "Start winding down. Dim lights and avoid screens to prepare for sleep."
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        do {
            try await center.add(UNNotificationRequest(
                identifier: "nazeit_\(phase.rawValue)_d\(day)_sleep_reminder",
                content: content, trigger: trigger
            ))
        } catch {
            print("[Notifications] Sleep reminder failed: \(error)")
        }
    }

    // MARK: - Cancel

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
