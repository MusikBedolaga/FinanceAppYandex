import Foundation
import Security

@MainActor
final class APIKeysStorage {
    static let shared = APIKeysStorage()

    private let baseURLKey = "baseURL"
    private let tokenKey = "apiToken"

    // MARK: - Token (Keychain)
    func saveToken(_ token: String) {
        let data = token.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    // MARK: - BaseURL (UserDefaults)
    func saveBaseURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: baseURLKey)
    }

    func getBaseURL() -> URL? {
        if let string = UserDefaults.standard.string(forKey: baseURLKey) {
            return URL(string: string)
        }
        return nil
    }
}
