
import Foundation
import Alamofire

final class ReportService {
    static let shared = ReportService()
    private init() {}

    // Fetch reports from the backend
    func fetchReports() async throws -> [MedicalReport] {
        try await APIService.shared.request(
            "/api/reports",
            authenticated: true
        )
    }

    // Upload a new medical report
    func uploadReport(
        fileURL: URL,
        title: String,
        reportType: String
    ) async throws -> MedicalReport {

        guard let token = KeychainService.shared.getToken(),
              !token.isEmpty else {
            throw APIServiceError.missingToken
        }

        let baseURL = "http://127.0.0.1:8000"
        let url = "\(baseURL)/api/reports/upload"

        let hasAccess = fileURL.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: { formData in
                    formData.append(
                        Data(title.utf8),
                        withName: "title"
                    )

                    formData.append(
                        Data(reportType.utf8),
                        withName: "report_type"
                    )

                    formData.append(
                        fileURL,
                        withName: "file",
                        fileName: fileURL.lastPathComponent,
                        mimeType: Self.mimeType(for: fileURL)
                    )
                },
                to: url,
                method: .post,
                headers: [
                    "Authorization": "Bearer \(token)"
                ]
            )
            .validate()
            .responseDecodable(of: MedicalReport.self) { response in
                switch response.result {
                case .success(let report):
                    continuation.resume(returning: report)

                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        print("Report upload HTTP status: \(statusCode)")
                    }
                    print("Report upload failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        default:
            return "application/octet-stream"
        }
    }
}
