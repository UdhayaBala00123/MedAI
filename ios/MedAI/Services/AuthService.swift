
import Foundation
import Alamofire

// MARK: - Login Response

struct LoginResponse: Decodable {
    let access_token: String
    let token_type: String
}

// MARK: - Authentication Service

final class AuthService {

    static let shared = AuthService()

    private init() {}

    // MARK: - Login

    func login(
        email: String,
        password: String
    ) async throws -> LoginResponse {

        let parameters: Parameters = [
            "username": email,
            "password": password
        ]

        let response: LoginResponse =
            try await APIService.shared.request(
                "/api/auth/login",
                method: .post,
                parameters: parameters,
                encoding: URLEncoding.default
            )

        return response
    }
}
