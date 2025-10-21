//
//  WebDAVAccount.swift
//  Tomato
//

import Foundation

/// WebDAV 账号配置
struct WebDAVAccount: Identifiable, Codable {
    let id: UUID
    var name: String
    var serverURL: String
    var username: String
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, serverURL: String, username: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.serverURL = serverURL
        self.username = username
        self.isDefault = isDefault
    }
}

/// WebDAV 文件项
struct WebDAVItem: Identifiable {
    let id: UUID
    var name: String
    var path: String
    var isDirectory: Bool
    var size: Int64?
    var modifiedDate: Date?
    
    init(id: UUID = UUID(), name: String, path: String, isDirectory: Bool, size: Int64? = nil, modifiedDate: Date? = nil) {
        self.id = id
        self.name = name
        self.path = path
        self.isDirectory = isDirectory
        self.size = size
        self.modifiedDate = modifiedDate
    }
}
