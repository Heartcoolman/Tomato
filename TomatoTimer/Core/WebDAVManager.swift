//
//  WebDAVManager.swift
//  Tomato
//

import Foundation
import Security

/// WebDAV 管理器
@MainActor
class WebDAVManager: ObservableObject {
    static let shared = WebDAVManager()
    
    @Published var accounts: [WebDAVAccount] = []
    @Published var isConnecting = false
    @Published var errorMessage: String?
    
    private let accountsKey = "webdav_accounts"
    
    init() {
        loadAccounts()
    }
    
    // MARK: - 账号管理
    
    func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: accountsKey),
           let decoded = try? JSONDecoder().decode([WebDAVAccount].self, from: data) {
            accounts = decoded
        }
    }
    
    func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsKey)
        }
    }
    
    func addAccount(_ account: WebDAVAccount, password: String) {
        accounts.append(account)
        savePassword(for: account.id, password: password)
        saveAccounts()
    }
    
    func updateAccount(_ account: WebDAVAccount, password: String?) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            if let password = password {
                savePassword(for: account.id, password: password)
            }
            saveAccounts()
        }
    }
    
    func deleteAccount(_ account: WebDAVAccount) {
        accounts.removeAll { $0.id == account.id }
        deletePassword(for: account.id)
        saveAccounts()
    }
    
    // MARK: - Keychain 密码管理
    
    private func savePassword(for accountId: UUID, password: String) {
        let service = "com.tomato.webdav"
        let account = accountId.uuidString
        
        guard let passwordData = password.data(using: .utf8) else { return }
        
        // 删除旧密码
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // 添加新密码
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: passwordData
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }
    
    func getPassword(for accountId: UUID) -> String? {
        let service = "com.tomato.webdav"
        let account = accountId.uuidString
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return password
    }
    
    private func deletePassword(for accountId: UUID) {
        let service = "com.tomato.webdav"
        let account = accountId.uuidString
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - WebDAV 操作
    
    func testConnection(account: WebDAVAccount, password: String) async throws -> Bool {
        isConnecting = true
        errorMessage = nil
        
        defer { isConnecting = false }
        
        guard let url = URL(string: account.serverURL) else {
            throw WebDAVError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PROPFIND"
        request.setValue("0", forHTTPHeaderField: "Depth")
        
        // Basic Auth
        let credentials = "\(account.username):\(password)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WebDAVError.invalidResponse
        }
        
        if httpResponse.statusCode == 207 || httpResponse.statusCode == 200 {
            return true
        } else if httpResponse.statusCode == 401 {
            throw WebDAVError.authenticationFailed
        } else {
            throw WebDAVError.connectionFailed(statusCode: httpResponse.statusCode)
        }
    }
    
    func listFiles(account: WebDAVAccount, path: String = "/") async throws -> [WebDAVItem] {
        guard let password = getPassword(for: account.id) else {
            throw WebDAVError.noPassword
        }
        
        let fullURL = account.serverURL + path
        guard let url = URL(string: fullURL) else {
            throw WebDAVError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")
        
        // Basic Auth
        let credentials = "\(account.username):\(password)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 207 else {
            throw WebDAVError.invalidResponse
        }
        
        // 解析 WebDAV XML 响应
        return try parseWebDAVResponse(data: data, basePath: path)
    }
    
    func downloadFile(account: WebDAVAccount, path: String) async throws -> Data {
        guard let password = getPassword(for: account.id) else {
            throw WebDAVError.noPassword
        }
        
        let fullURL = account.serverURL + path
        guard let url = URL(string: fullURL) else {
            throw WebDAVError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Basic Auth
        let credentials = "\(account.username):\(password)"
        if let credentialsData = credentials.data(using: .utf8) {
            let base64Credentials = credentialsData.base64EncodedString()
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WebDAVError.downloadFailed
        }
        
        return data
    }
    
    // MARK: - 辅助方法
    
    private func parseWebDAVResponse(data: Data, basePath: String) throws -> [WebDAVItem] {
        // 简化的 XML 解析（实际应使用 XMLParser）
        let items: [WebDAVItem] = []
        
        // 这里需要实现完整的 WebDAV XML 解析
        // 暂时返回空数组，后续完善
        
        return items
    }
}

// MARK: - 错误类型

enum WebDAVError: LocalizedError {
    case invalidURL
    case invalidResponse
    case authenticationFailed
    case connectionFailed(statusCode: Int)
    case noPassword
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的服务器地址"
        case .invalidResponse:
            return "服务器响应无效"
        case .authenticationFailed:
            return "用户名或密码错误"
        case .connectionFailed(let code):
            return "连接失败（状态码：\(code)）"
        case .noPassword:
            return "未找到保存的密码"
        case .downloadFailed:
            return "文件下载失败"
        }
    }
}
