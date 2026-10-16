
import Foundation
import Alamofire

struct AIReportAnalysisResponse: Decodable {
    let report_id: Int
    let title: String
    let summary: String
}

final class AIReportService {
    static let shared = AIReportService()

    private init() {}

    func analyzeReport(
        id: Int
    ) async throws -> AIReportAnalysisResponse {
        try await APIService.shared.request(
            "/api/reports/\(id)/analyze",
            method: .post,
            authenticated: true
        )
    }
}
