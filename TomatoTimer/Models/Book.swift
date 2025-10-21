//
//  Book.swift
//  Tomato
//

import Foundation

/// 书籍模型
struct Book: Identifiable, Codable {
    let id: UUID
    var title: String
    var author: String?
    var filePath: String // WebDAV 路径或本地路径
    var fileSize: Int64
    var source: BookSource
    var encoding: String? // 记住的编码
    var lastReadDate: Date?
    var readingProgress: Double // 0.0 - 1.0
    var currentPosition: Int // 字符位置
    var totalCharacters: Int
    
    init(id: UUID = UUID(), title: String, filePath: String, fileSize: Int64, source: BookSource) {
        self.id = id
        self.title = title
        self.filePath = filePath
        self.fileSize = fileSize
        self.source = source
        self.readingProgress = 0.0
        self.currentPosition = 0
        self.totalCharacters = 0
    }
}

/// 书籍来源
enum BookSource: String, Codable {
    case webdav = "webdav"
    case local = "local"
}

/// 书签
struct Bookmark: Identifiable, Codable {
    let id: UUID
    var bookId: UUID
    var position: Int
    var chapterTitle: String?
    var preview: String // 前后文预览
    var createdDate: Date
    var note: String?
    
    init(id: UUID = UUID(), bookId: UUID, position: Int, chapterTitle: String? = nil, preview: String, note: String? = nil) {
        self.id = id
        self.bookId = bookId
        self.position = position
        self.chapterTitle = chapterTitle
        self.preview = preview
        self.createdDate = Date()
        self.note = note
    }
}

/// 高亮标注
struct Highlight: Identifiable, Codable {
    let id: UUID
    var bookId: UUID
    var startPosition: Int
    var endPosition: Int
    var color: HighlightColor
    var note: String?
    var createdDate: Date
    
    init(id: UUID = UUID(), bookId: UUID, startPosition: Int, endPosition: Int, color: HighlightColor, note: String? = nil) {
        self.id = id
        self.bookId = bookId
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.color = color
        self.note = note
        self.createdDate = Date()
    }
}

/// 高亮颜色
enum HighlightColor: String, Codable, CaseIterable {
    case yellow = "yellow"
    case green = "green"
    case blue = "blue"
    case pink = "pink"
    case purple = "purple"
}

/// 章节
struct Chapter: Identifiable {
    let id: UUID
    var title: String
    var startPosition: Int
    var endPosition: Int?
    
    init(id: UUID = UUID(), title: String, startPosition: Int, endPosition: Int? = nil) {
        self.id = id
        self.title = title
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
}
