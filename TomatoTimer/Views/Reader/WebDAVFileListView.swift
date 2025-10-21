//
//  WebDAVFileListView.swift
//  Tomato
//

import SwiftUI

struct WebDAVFileListView: View {
    let account: WebDAVAccount
    @StateObject private var manager = WebDAVManager.shared
    @StateObject private var bookStore = BookStore.shared
    
    @State private var currentPath = "/"
    @State private var items: [WebDAVItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var showingEncodingPicker = false
    @State private var currentFileData: Data?
    @State private var currentFileName: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("搜索文件", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // 文件列表
            if isLoading {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text(error)
                        .foregroundColor(.secondary)
                    Button("重试") {
                        loadFiles()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    // 返回上级目录
                    if currentPath != "/" {
                        Button(action: goBack) {
                            HStack {
                                Image(systemName: "arrow.up")
                                Text("返回上级")
                            }
                        }
                    }
                    
                    // 文件和文件夹
                    ForEach(filteredItems) { item in
                        if item.isDirectory {
                            Button(action: { openDirectory(item) }) {
                                FileItemRow(item: item)
                            }
                        } else {
                            Button(action: { openFile(item) }) {
                                FileItemRow(item: item)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(currentPath == "/" ? account.name : currentPath.components(separatedBy: "/").last ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFiles()
        }
        .sheet(isPresented: $showingEncodingPicker) {
            if let data = currentFileData {
                EncodingPickerView(fileData: data) { encoding in
                    decodeAndOpenFile(data: data, encoding: encoding, fileName: currentFileName)
                }
            }
        }
    }
    
    private var filteredItems: [WebDAVItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func loadFiles() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedItems = try await manager.listFiles(account: account, path: currentPath)
                await MainActor.run {
                    // 只显示文件夹和 .txt 文件
                    items = loadedItems.filter { item in
                        item.isDirectory || item.name.lowercased().hasSuffix(".txt")
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func openDirectory(_ item: WebDAVItem) {
        currentPath = item.path
        loadFiles()
    }
    
    private func goBack() {
        let components = currentPath.components(separatedBy: "/").filter { !$0.isEmpty }
        if components.count > 1 {
            currentPath = "/" + components.dropLast().joined(separator: "/") + "/"
        } else {
            currentPath = "/"
        }
        loadFiles()
    }
    
    private func openFile(_ item: WebDAVItem) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 下载文件
                let data = try await manager.downloadFile(account: account, path: item.path)
                
                await MainActor.run {
                    isLoading = false
                    
                    // 尝试自动检测编码
                    if let (encoding, confidence) = EncodingDetector.detectEncoding(data: data),
                       confidence > 0.7 {
                        // 置信度高，直接解码
                        decodeAndOpenFile(data: data, encoding: encoding, fileName: item.name)
                    } else {
                        // 置信度低，显示编码选择器
                        currentFileData = data
                        currentFileName = item.name
                        showingEncodingPicker = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "文件下载失败: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func decodeAndOpenFile(data: Data, encoding: String.Encoding, fileName: String) {
        guard let content = EncodingDetector.decodeText(data: data, encoding: encoding) else {
            errorMessage = "文件解码失败"
            return
        }
        
        // 创建书籍记录
        let book = Book(
            title: fileName.replacingOccurrences(of: ".txt", with: ""),
            filePath: currentPath + fileName,
            fileSize: Int64(data.count),
            source: .webdav
        )
        
        var newBook = book
        newBook.encoding = EncodingDetector.getEncodingName(encoding: encoding)
        newBook.totalCharacters = content.count
        
        bookStore.addBook(newBook)
        
        // TODO: 导航到阅读视图
        print("打开书籍: \(newBook.title)")
    }
}

struct FileItemRow: View {
    let item: WebDAVItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isDirectory ? "folder.fill" : "doc.text.fill")
                .font(.title3)
                .foregroundColor(item.isDirectory ? .blue : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                
                HStack(spacing: 8) {
                    if let size = item.size, !item.isDirectory {
                        Text(formatFileSize(size))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let date = item.modifiedDate {
                        Text(formatDate(date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if !item.isDirectory {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
