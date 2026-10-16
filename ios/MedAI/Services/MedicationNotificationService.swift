
import Foundation
import UserNotifications

enum MedicationNotificationService {

    static func requestPermission() async throws {
        let center = UNUserNotificationCenter.current()

        let granted = try await center.requestAuthorization(
            options: [.alert, .sound, .badge]
        )

        if !granted {
            throw NotificationError.permissionDenied
        }
    }

    static func schedule(
        reminderID: Int,
        medicationName: String,
        time: Date,
        weekdays: [Int]
    ) async throws {
        guard !weekdays.isEmpty else {
            throw NotificationError.noDaysSelected
        }

        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents(
            [.hour, .minute],
            from: time
        )

        for weekday in weekdays {
            var components = DateComponents()
            components.weekday = weekday
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute

            let content = UNMutableNotificationContent()
            content.title = "Medication Reminder"
            content.body = "Time to take \(medicationName)."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "medication-\(reminderID)-day-\(weekday)",
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        }
    }

    static func cancel(reminderID: Int) {
        let identifiers = (1...7).map {
            "medication-\(reminderID)-day-\($0)"
        }

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: identifiers
            )
    }

    enum NotificationError: LocalizedError {
        case permissionDenied
        case noDaysSelected

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Allow notifications in Settings to receive reminders."
            case .noDaysSelected:
                return "Select at least one day for this reminder."
            }
        }
    }
}
