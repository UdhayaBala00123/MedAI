
import Foundation

struct Medication: Codable, Identifiable, Sendable {
    let id: Int
    let user_id: Int
    let medicine_name: String
    let dosage: String
    let dosage_unit: String
    let instructions: String?
    let frequency: String
    let start_date: Date
    let end_date: Date?
    let active: Bool
    let created_at: Date

    var displayDosage: String {
        "\(dosage) \(dosage_unit)"
    }

    var displayInstructions: String {
        instructions ?? "No instructions provided"
    }
}

struct MedicationCreate: Encodable {
    let medicine_name: String
    let dosage: String
    let dosage_unit: String
    let instructions: String?
    let frequency: String
    let start_date: Date
    let end_date: Date?
}
