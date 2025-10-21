//
//  BookStore.swift
//  Tomato
//

import Foundation
import Combine

/// 书籍数据管理
@MainActor
class BookStore: ObservableObject {
    static let shared = BookStore()
    
    @Published var books: [Book] = []
    @Published var bookmarks: [Bookmark] = []
    @Published var highlights: [Highlight] = []
    @Published var readerSettings = ReaderSettings()
    
    private let booksKey = "reader_books"
    private let bookmarksKey = "reader_bookmarks"
    private let highlightsKey = "reader_highlights"
    private let settingsKey = "reader_settings"
    
    init() {
        loadData()
    }
    
    // MARK: - 数据持久化
    
    func loadData() {
        // 加载书籍
        if let data = UserDefaults.standard.data(forKey: booksKey),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            books = decoded
        }
        
        // 加载书签
        if let data = UserDefaults.standard.data(forKey: bookmarksKey),
           let decoded = try? JSONDecoder().decode([Bookmark].self, from: data) {
            bookmarks = decoded
        }
        
        // 加载高亮
        if let data = UserDefaults.standard.data(forKey: highlightsKey),
           let decoded = try? JSONDecoder().decode([Highlight].self, from: data) {
            highlights = decoded
        }
        
        // 加载设置
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(ReaderSettings.self, from: data) {
            readerSettings = decoded
        }
    }
    
    func saveBooks() {
        if let encoded = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encoded, forKey: booksKey)
        }
    }
    
    func saveBookmarks() {
        if let encoded = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(encoded, forKey: bookmarksKey)
        }
    }
    
    func saveHighlights() {
        if let encoded = try? JSONEncoder().encode(highlights) {
            UserDefaults.standard.set(encoded, forKey: highlightsKey)
        }
    }
    
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(readerSettings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    // MARK: - 书籍管理
    
    func addBook(_ book: Book) {
        books.append(book)
        saveBooks()
    }
    
    func updateBook(_ book: Book) {
        if let index = books.firstIndex(where: { $0.id == book.id }) {
            books[index] = book
            saveBooks()
        }
    }
    
    func deleteBook(_ book: Book) {
        books.removeAll { $0.id == book.id }
        // 同时删除相关的书签和高亮
        bookmarks.removeAll { $0.bookId == book.id }
        highlights.removeAll { $0.bookId == book.id }
        saveBooks()
        saveBookmarks()
        saveHighlights()
    }
    
    func updateReadingProgress(bookId: UUID, position: Int, totalCharacters: Int) {
        if let index = books.firstIndex(where: { $0.id == bookId }) {
            books[index].currentPosition = position
            books[index].totalCharacters = totalCharacters
            books[index].readingProgress = totalCharacters > 0 ? Double(position) / Double(totalCharacters) : 0.0
            books[index].lastReadDate = Date()
            saveBooks()
        }
    }
    
    func updateBookEncoding(bookId: UUID, encoding: String) {
        if let index = books.firstIndex(where: { $0.id == bookId }) {
            books[index].encoding = encoding
            saveBooks()
        }
    }
    
    // MARK: - 书签管理
    
    func addBookmark(_ bookmark: Bookmark) {
        bookmarks.append(bookmark)
        saveBookmarks()
    }
    
    func deleteBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        saveBookmarks()
    }
    
    func getBookmarks(for bookId: UUID) -> [Bookmark] {
        return bookmarks.filter { $0.bookId == bookId }.sorted { $0.position < $1.position }
    }
    
    // MARK: - 高亮管理
    
    func addHighlight(_ highlight: Highlight) {
        highlights.append(highlight)
        saveHighlights()
    }
    
    func deleteHighlight(_ highlight: Highlight) {
        highlights.removeAll { $0.id == highlight.id }
        saveHighlights()
    }
    
    func getHighlights(for bookId: UUID) -> [Highlight] {
        return highlights.filter { $0.bookId == bookId }.sorted { $0.startPosition < $1.startPosition }
    }
    
    func getHighlight(at position: Int, for bookId: UUID) -> Highlight? {
        return highlights.first { highlight in
            highlight.bookId == bookId &&
            position >= highlight.startPosition &&
            position <= highlight.endPosition
        }
    }
    
    // MARK: - 设置管理
    
    func updateSettings(_ settings: ReaderSettings) {
        readerSettings = settings
        saveSettings()
    }
}
