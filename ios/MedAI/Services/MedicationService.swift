
import Foundation
import Alamofire

final class MedicationService {

    static let shared = MedicationService()

    private init() {}

    // Fetch all medications for the logged-in user
    func getMedications() async throws -> [Medication] {
        try await APIService.shared.request(
            "/api/medications",
            method: .get,
            authenticated: true
        )
    }

    // Add a new medication
    func addMedication(
        _ medication: MedicationCreate
    ) async throws -> Medication {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(medication)
        let parameters = try JSONSerialization.jsonObject(
            with: data
        ) as? Parameters

        return try await APIService.shared.request(
            "/api/medications",
            method: .post,
            parameters: parameters,
            authenticated: true
        )
    }

    // Update an existing medication
    func updateMedication(
        id: Int,
        medication: MedicationCreate
    ) async throws -> Medication {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(medication)
        let parameters = try JSONSerialization.jsonObject(
            with: data
        ) as? Parameters

        return try await APIService.shared.request(
            "/api/medications/\(id)",
            method: .put,
            parameters: parameters,
            authenticated: true
        )
    }

    // Delete a medication

   
    func deleteMedication(id: Int) async throws {
        let url = "http://127.0.0.1:8000/api/medications/\(id)"

        guard let token = KeychainService.shared.getToken(),
              !token.isEmpty else {
            throw APIServiceError.missingToken
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        let response = await AF.request(
            url,
            method: .delete,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .serializingData()
        .response

        if let error = response.error {
            throw error
        }
    }

}

private struct EmptyResponse: Decodable {}
