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
final class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    @Published var isAuthorized = false

    // Waktu sebelum instruksi (dalam hitungan jam). Ubah angka 1.0 ini untuk mengganti waktu notifikasi.
    var hoursBefore: Double = 1.0

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Force notifications to show as banners even if the app is currently open
        completionHandler([.banner, .sound])
    }



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
        var notifyTime = instruction.scheduledTime.addingTimeInterval(-hoursBefore * 3600)
        
        // If the 1-hour mark has passed but the event hasn't happened yet, fire almost immediately
        if notifyTime <= Date() {
            if instruction.scheduledTime > Date() {
                notifyTime = Date().addingTimeInterval(5)
            } else {
                return // Event has completely passed
            }
        }

        let timeText = hoursBefore == 1.0 ? "1 hour" : "\(hoursBefore) hours"
        let engagingPrefixes = [
            "Almost time! ✨",
            "Next up in \(timeText) ⏰",
            "Beat jet lag! 🛫",
            "Stay on track 🔋"
        ]
        let prefix = engagingPrefixes.randomElement() ?? "Up next:"

        let content = UNMutableNotificationContent()
        content.title = "\(prefix) \(instruction.title)"
        content.body = instruction.detail
        content.sound = .default
        content.categoryIdentifier = "circadian_\(instruction.type.rawValue)"
        content.userInfo = ["type": instruction.type.rawValue, "phase": phase.rawValue, "day": day]

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notifyTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let id = "nazeit_\(phase.rawValue)_d\(day)_\(instruction.type.rawValue)_\(instruction.id.uuidString.prefix(8))"

        do {
            try await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        } catch {
            print("[Notifications] Schedule failed: \(error)")
        }
    }

    // MARK: - Sleep Reminder

    private func scheduleSleepReminder(_ window: SleepWindow, day: Int, phase: TravelPhase) async {
        var notifyTime = window.bedtime.addingTimeInterval(-hoursBefore * 3600)
        
        // If the 1-hour mark has passed but bedtime hasn't happened yet, fire almost immediately
        if notifyTime <= Date() {
            if window.bedtime > Date() {
                notifyTime = Date().addingTimeInterval(5)
            } else {
                return // Bedtime has completely passed
            }
        }

        let timeText = hoursBefore == 1.0 ? "1 hour" : "\(hoursBefore) hours"

        let content = UNMutableNotificationContent()
        content.title = "Wind down time! 💤"
        content.body = "Bedtime is in \(timeText). Dim the lights, put away screens, and let your body clock sync up. You've got this!"
        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notifyTime)
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
