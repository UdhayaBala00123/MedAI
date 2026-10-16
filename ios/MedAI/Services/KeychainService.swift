
import Foundation
import Security

final class KeychainService {

    static let shared = KeychainService()

    private init() {}

    private let service = "com.medai.auth"
    private let tokenKey = "access_token"

    // MARK: - Save Token

    @discardableResult
    func saveToken(_ token: String) -> Bool {

        guard !token.isEmpty,
              let data = token.data(using: .utf8) else {
            print("Keychain: Token is empty or invalid.")
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        // Delete the old token before saving the new one.
        let deleteStatus = SecItemDelete(query as CFDictionary)

        if deleteStatus != errSecSuccess &&
           deleteStatus != errSecItemNotFound {
            print("Keychain: Delete failed: \(deleteStatus)")
            return false
        }

        var saveQuery = query
        saveQuery[kSecValueData as String] = data
        saveQuery[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        let status = SecItemAdd(saveQuery as CFDictionary, nil)

        guard status == errSecSuccess else {
            print("Keychain: Save failed: \(status)")
            return false
        }

        print("Keychain: Token saved successfully.")
        return true
    }

    // MARK: - Read Token

    func getToken() -> String? {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        guard status == errSecSuccess else {
            print("Keychain: Read failed: \(status)")
            return nil
        }

        guard let data = result as? Data,
              let token = String(data: data, encoding: .utf8),
              !token.isEmpty else {
            print("Keychain: Retrieved token is invalid.")
            return nil
        }

        print("Keychain: Token retrieved successfully.")
        return token
    }

    // MARK: - Delete Token

    @discardableResult
    func deleteToken() -> Bool {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess ||
               status == errSecItemNotFound
    }
}
