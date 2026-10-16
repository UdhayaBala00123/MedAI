
import Foundation
import Alamofire

struct AIChatResponse: Decodable {
    let answer: String
}

final class AIChatService {
    static let shared = AIChatService()

    private init() {}

    func sendMessage(
        _ message: String,
        healthContext: String = ""
    ) async throws -> String {

        let parameters: [String: String] = [
            "health_context": healthContext,
            "user_message": message
        ]

        let response: AIChatResponse =
            try await APIService.shared.request(
                "/api/ai/chat",
                method: .post,
                parameters: parameters,
                authenticated: true
            )

        return response.answer
    }
}
