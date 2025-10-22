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
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
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
        
        // 正确拼接 URL，避免双斜杠
        let baseURL = account.serverURL.hasSuffix("/") ? String(account.serverURL.dropLast()) : account.serverURL
        let cleanPath = path.hasPrefix("/") ? path : "/" + path
        let fullURL = baseURL + cleanPath
        
        guard let url = URL(string: fullURL) else {
            throw WebDAVError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PROPFIND"
        request.setValue("1", forHTTPHeaderField: "Depth")
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
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
        
        // 正确拼接 URL，避免双斜杠
        let baseURL = account.serverURL.hasSuffix("/") ? String(account.serverURL.dropLast()) : account.serverURL
        let cleanPath = path.hasPrefix("/") ? path : "/" + path
        let fullURL = baseURL + cleanPath
        
        guard let url = URL(string: fullURL) else {
            throw WebDAVError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        
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
        let parser = WebDAVXMLParser(basePath: basePath)
        return try parser.parse(data: data)
    }
}

// MARK: - WebDAV XML 解析器

class WebDAVXMLParser: NSObject, XMLParserDelegate {
    private var items: [WebDAVItem] = []
    private var currentElement = ""
    private var currentHref = ""
    private var currentSize: Int64?
    private var currentModifiedDate: Date?
    private var isDirectory = false
    private var inPropStat = false
    private let basePath: String
    private let dateFormatter = ISO8601DateFormatter()
    
    init(basePath: String) {
        self.basePath = basePath
        super.init()
    }
    
    func parse(data: Data) throws -> [WebDAVItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        if parser.parse() {
            // 过滤掉当前目录本身和空项
            return items.filter { !$0.name.isEmpty && $0.path != basePath }
        } else if let error = parser.parserError {
            throw error
        } else {
            throw WebDAVError.invalidResponse
        }
    }
    
    // XMLParserDelegate 方法
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "d:response" || elementName == "response" {
            // 重置当前项的状态
            currentHref = ""
            currentSize = nil
            currentModifiedDate = nil
            isDirectory = false
            inPropStat = false
        } else if elementName == "d:propstat" || elementName == "propstat" {
            inPropStat = true
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let content = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        switch currentElement {
        case "d:href", "href":
            currentHref += content
            
        case "d:getcontentlength", "getcontentlength":
            if let size = Int64(content) {
                currentSize = size
            }
            
        case "d:getlastmodified", "getlastmodified":
            if let date = dateFormatter.date(from: content) {
                currentModifiedDate = date
            } else {
                // 尝试其他日期格式
                let fallbackFormatter = DateFormatter()
                fallbackFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                fallbackFormatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = fallbackFormatter.date(from: content) {
                    currentModifiedDate = date
                }
            }
            
        case "d:resourcetype", "resourcetype":
            break
            
        case "d:collection", "collection":
            isDirectory = true
            
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "d:response" || elementName == "response" {
            // 完成一个文件/目录的解析
            if !currentHref.isEmpty {
                // 解码 URL 编码的路径
                guard let decodedHref = currentHref.removingPercentEncoding else {
                    currentElement = ""
                    return
                }
                
                // 处理完整 URL（如 https://server.com/path/to/file）
                var pathOnly = decodedHref
                if let url = URL(string: decodedHref), let path = url.path.isEmpty ? nil : url.path {
                    pathOnly = path
                } else if decodedHref.hasPrefix("http://") || decodedHref.hasPrefix("https://") {
                    // 如果是 URL 但无法解析，尝试手动提取路径
                    if let pathStart = decodedHref.range(of: "/", options: [], range: decodedHref.index(decodedHref.startIndex, offsetBy: 8)..<decodedHref.endIndex) {
                        pathOnly = String(decodedHref[pathStart.lowerBound...])
                    }
                }
                
                // 提取文件/文件夹名称和路径
                let pathComponents = pathOnly.components(separatedBy: "/").filter { !$0.isEmpty }
                
                if let name = pathComponents.last {
                    // 构建完整路径
                    let fullPath = "/" + pathComponents.joined(separator: "/") + (isDirectory ? "/" : "")
                    
                    let item = WebDAVItem(
                        name: name,
                        path: fullPath,
                        isDirectory: isDirectory,
                        size: currentSize,
                        modifiedDate: currentModifiedDate
                    )
                    
                    items.append(item)
                }
            }
        } else if elementName == "d:propstat" || elementName == "propstat" {
            inPropStat = false
        }
        
        currentElement = ""
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
