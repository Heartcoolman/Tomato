//
//  ReaderMainView.swift
//  Tomato
//

import SwiftUI

/// 阅读器主视图
struct ReaderMainView: View {
    @StateObject private var webdavManager = WebDAVManager.shared
    @StateObject private var bookStore = BookStore.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部标签
                Picker("", selection: $selectedTab) {
                    Text("WebDAV").tag(0)
                    Text("本地").tag(1)
                    Text("书架").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 内容区域
                TabView(selection: $selectedTab) {
                    WebDAVBrowserView()
                        .tag(0)
                    
                    LocalFilesView()
                        .tag(1)
                    
                    BookshelfView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("阅读器")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

/// WebDAV 文件浏览视图
struct WebDAVBrowserView: View {
    @StateObject private var manager = WebDAVManager.shared
    @State private var showingAddAccount = false
    
    var body: some View {
        VStack {
            if manager.accounts.isEmpty {
                // 空状态
                VStack(spacing: 20) {
                    Image(systemName: "cloud")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("还没有 WebDAV 账号")
                        .font(.headline)
                    
                    Text("添加 WebDAV 账号以访问云端文件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showingAddAccount = true }) {
                        Label("添加账号", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                // 账号列表
                List {
                    ForEach(manager.accounts) { account in
                        NavigationLink(destination: WebDAVFileListView(account: account)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(account.name)
                                    .font(.headline)
                                Text(account.serverURL)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            manager.deleteAccount(manager.accounts[index])
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddAccount = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddWebDAVAccountView()
        }
    }
}

/// 本地文件视图（占位）
struct LocalFilesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("本地文件")
                .font(.headline)
            
            Text("从文件 App 打开 TXT 文件")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

/// 书架视图
struct BookshelfView: View {
    @StateObject private var bookStore = BookStore.shared
    
    var body: some View {
        Group {
            if bookStore.books.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("书架是空的")
                        .font(.headline)
                    
                    Text("打开一本书开始阅读吧")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                List {
                    ForEach(bookStore.books) { book in
                        NavigationLink(destination: Text("阅读视图")) {
                            BookRowView(book: book)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            bookStore.deleteBook(bookStore.books[index])
                        }
                    }
                }
            }
        }
    }
}

/// 书籍行视图
struct BookRowView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(book.title)
                .font(.headline)
            
            HStack {
                if let author = book.author {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(Int(book.readingProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: book.readingProgress)
                .tint(Color.accentColor)
        }
        .padding(.vertical, 4)
    }
}
