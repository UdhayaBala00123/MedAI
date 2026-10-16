
import Foundation
import Alamofire

final class APIService {

    static let shared = APIService()

    private init() {}

    private let baseURL = "http://127.0.0.1:8000"

    func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: HTTPHeaders = [],
        authenticated: Bool = false
    ) async throws -> T {

        guard let url = URL(string: baseURL + path) else {
            throw APIServiceError.invalidURL
        }

        var requestHeaders = headers

        if authenticated {
            guard let token = KeychainService.shared.getToken(),
                  !token.isEmpty else {
                throw APIServiceError.missingToken
            }

            requestHeaders.update(
                name: "Authorization",
                value: "Bearer \(token)"
            )
        }

        let dataRequest = AF.request(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: requestHeaders
        )

        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss"
            ]

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            for format in formats {
                formatter.dateFormat = format

                if let date = formatter.date(from: dateString) {
                    return date
                }
            }

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            isoFormatter.formatOptions = [.withInternetDateTime]

            if let date = isoFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported date format: \(dateString)"
            )
        }

        do {
            return try await dataRequest
                .validate()
                .serializingDecodable(T.self, decoder: decoder)
                .value
        } catch {
            print("API request failed: \(method) \(path)")
            print("Error details: \(error)")

            if let response = dataRequest.response {
                print("HTTP status: \(response.statusCode)")
            }

            if let data = dataRequest.data,
               let body = String(data: data, encoding: .utf8) {
                print("API response body: \(body)")
            }

            throw error
        }
    }
}

enum APIServiceError: LocalizedError {
    case invalidURL
    case missingToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL is invalid."
        case .missingToken:
            return "Please log in before making this request."
        }
    }
}
