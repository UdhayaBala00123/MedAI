
import Foundation

struct MedicationReminder: Codable, Identifiable, Sendable {
    let id: Int
    let medication_id: Int
    let reminder_time: String
    let days_of_week: String
    let active: Bool
    let created_at: Date
}

struct MedicationReminderCreate: Encodable {
    let medication_id: Int
    let reminder_time: String
    let days_of_week: String
}
