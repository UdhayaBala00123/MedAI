
import Foundation
import Alamofire

final class MedicationReminderService {
    static let shared = MedicationReminderService()

    private init() {}

    func getReminders(
        medicationID: Int
    ) async throws -> [MedicationReminder] {
        try await APIService.shared.request(
            "/api/medication-reminders/medication/\(medicationID)",
            method: .get,
            authenticated: true
        )
    }

    func addReminder(
        medicationID: Int,
        time: Date,
        daysOfWeek: String
    ) async throws -> MedicationReminder {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"

        let payload = MedicationReminderCreate(
            medication_id: medicationID,
            reminder_time: formatter.string(from: time),
            days_of_week: daysOfWeek
        )

        let data = try JSONEncoder().encode(payload)
        let parameters = try JSONSerialization.jsonObject(
            with: data
        ) as? Parameters

        return try await APIService.shared.request(
            "/api/medication-reminders",
            method: .post,
            parameters: parameters,
            authenticated: true
        )
    }

    func deleteReminder(id: Int) async throws {
        let url = "http://127.0.0.1:8000/api/medication-reminders/\(id)"

        guard let token = KeychainService.shared.getToken(),
              !token.isEmpty else {
            throw APIServiceError.missingToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]


        let _: Data = try await AF.request(
            url,
            method: .delete,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .value

    }

    func updateReminder(
        id: Int,
        medicationID: Int,
        time: Date,
        daysOfWeek: String
    ) async throws -> MedicationReminder {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"

        let payload = MedicationReminderCreate(
            medication_id: medicationID,
            reminder_time: formatter.string(from: time),
            days_of_week: daysOfWeek
        )

        let data = try JSONEncoder().encode(payload)
        let parameters = try JSONSerialization.jsonObject(
            with: data
        ) as? Parameters

        return try await APIService.shared.request(
            "/api/medication-reminders/\(id)",
            method: .put,
            parameters: parameters,
            authenticated: true
        )
    }


}
