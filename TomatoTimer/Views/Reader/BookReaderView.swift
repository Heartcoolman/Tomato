//
//  BookReaderView.swift
//  Tomato
//

import SwiftUI

/// 书籍阅读视图
struct BookReaderView: View {
    let book: Book
    @StateObject private var bookStore = BookStore.shared
    @State private var content: String = ""
    @State private var chapters: [Chapter] = []
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var showingTableOfContents = false
    @State private var showingSettings = false
    @State private var isLoading = true
    
    var settings: ReaderSettings {
        bookStore.readerSettings
    }
    
    var body: some View {
        ZStack {
            // 背景色
            settings.theme.backgroundColor
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView("加载中...")
            } else {
                VStack(spacing: 0) {
                    // 顶部工具栏
                    readerToolbar
                    
                    // 阅读内容区
                    if settings.displayMode == .paging {
                        PagingReaderView(
                            content: content,
                            settings: settings,
                            currentPage: $currentPage,
                            totalPages: $totalPages
                        )
                    } else {
                        ScrollingReaderView(
                            content: content,
                            settings: settings
                        )
                    }
                    
                    // 底部进度条
                    readerFooter
                }
            }
        }
        .navigationBarHidden(true)
        .statusBar(hidden: true)
        .sheet(isPresented: $showingTableOfContents) {
            TableOfContentsView(chapters: chapters, book: book)
        }
        .sheet(isPresented: $showingSettings) {
            ReaderSettingsView()
        }
        .onAppear {
            loadBook()
        }
    }
    
    // MARK: - Toolbar
    
    private var readerToolbar: some View {
        HStack {
            Button(action: { /* 返回 */ }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(settings.theme.textColor)
            }
            
            Spacer()
            
            Text(book.title)
                .font(.headline)
                .foregroundColor(settings.theme.textColor)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: { showingTableOfContents = true }) {
                Image(systemName: "list.bullet")
                    .font(.title3)
                    .foregroundColor(settings.theme.textColor)
            }
            
            Button(action: { showingSettings = true }) {
                Image(systemName: "textformat.size")
                    .font(.title3)
                    .foregroundColor(settings.theme.textColor)
            }
        }
        .padding()
        .background(settings.theme.backgroundColor.opacity(0.95))
    }
    
    // MARK: - Footer
    
    private var readerFooter: some View {
        VStack(spacing: 8) {
            // 进度条
            ProgressView(value: Double(currentPage), total: Double(totalPages))
                .tint(Color.accentColor)
            
            // 信息栏
            HStack {
                if let chapter = getCurrentChapter() {
                    Text(chapter.title)
                        .font(.caption)
                        .foregroundColor(settings.theme.textColor.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(Int(book.readingProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(settings.theme.textColor.opacity(0.7))
                
                Text("第 \(currentPage + 1)/\(totalPages) 页")
                    .font(.caption)
                    .foregroundColor(settings.theme.textColor.opacity(0.7))
            }
        }
        .padding()
        .background(settings.theme.backgroundColor.opacity(0.95))
    }
    
    // MARK: - Helper Methods
    
    private func loadBook() {
        // TODO: 实际加载书籍内容
        // 这里需要从 WebDAV 或本地加载文件
        Task {
            // 模拟加载
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                content = "这是示例内容...\n\n第一章\n\n正文内容..."
                chapters = ChapterParser.parseChapters(text: content)
                isLoading = false
            }
        }
    }
    
    private func getCurrentChapter() -> Chapter? {
        // 根据当前位置查找章节
        return chapters.first
    }
}

/// 分页阅读视图
struct PagingReaderView: View {
    let content: String
    let settings: ReaderSettings
    @Binding var currentPage: Int
    @Binding var totalPages: Int
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<totalPages, id: \.self) { page in
                ScrollView {
                    Text(getPageContent(page: page))
                        .font(.system(size: settings.fontSize))
                        .lineSpacing(settings.lineSpacing * settings.fontSize - settings.fontSize)
                        .foregroundColor(settings.theme.textColor)
                        .padding(.horizontal, settings.horizontalPadding)
                        .padding(.vertical, settings.verticalPadding)
                }
                .tag(page)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    private func getPageContent(page: Int) -> String {
        // TODO: 实现分页逻辑
        return content
    }
}

/// 滚动阅读视图
struct ScrollingReaderView: View {
    let content: String
    let settings: ReaderSettings
    
    var body: some View {
        ScrollView {
            Text(content)
                .font(.system(size: settings.fontSize))
                .lineSpacing(settings.lineSpacing * settings.fontSize - settings.fontSize)
                .foregroundColor(settings.theme.textColor)
                .padding(.horizontal, settings.horizontalPadding)
                .padding(.vertical, settings.verticalPadding)
        }
    }
}

/// 目录视图
struct TableOfContentsView: View {
    let chapters: [Chapter]
    let book: Book
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(chapters) { chapter in
                    Button(action: {
                        // TODO: 跳转到章节
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chapter.title)
                                .font(.body)
                            
                            Text("位置: \(chapter.startPosition)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("目录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 阅读设置视图
struct ReaderSettingsView: View {
    @StateObject private var bookStore = BookStore.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var settings: ReaderSettings
    
    init() {
        _settings = State(initialValue: BookStore.shared.readerSettings)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("显示模式") {
                    Picker("模式", selection: $settings.displayMode) {
                        Text("分页").tag(ReaderSettings.DisplayMode.paging)
                        Text("滚动").tag(ReaderSettings.DisplayMode.scrolling)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("字体设置") {
                    HStack {
                        Text("字号")
                        Spacer()
                        Text("\(Int(settings.fontSize))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.fontSize, in: 12...36, step: 1)
                    
                    HStack {
                        Text("行距")
                        Spacer()
                        Text(String(format: "%.1f", settings.lineSpacing))
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.lineSpacing, in: 1.0...2.5, step: 0.1)
                }
                
                Section("页边距") {
                    HStack {
                        Text("水平")
                        Spacer()
                        Text("\(Int(settings.horizontalPadding))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.horizontalPadding, in: 10...50, step: 5)
                    
                    HStack {
                        Text("垂直")
                        Spacer()
                        Text("\(Int(settings.verticalPadding))")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $settings.verticalPadding, in: 10...50, step: 5)
                }
                
                Section("主题") {
                    Picker("主题", selection: $settings.theme) {
                        ForEach(ReaderTheme.allCases, id: \.self) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("跟随系统", isOn: $settings.autoTheme)
                }
                
                Section("预览") {
                    Text("这是预览文本。The quick brown fox jumps over the lazy dog. 春眠不觉晓，处处闻啼鸟。")
                        .font(.system(size: settings.fontSize))
                        .lineSpacing(settings.lineSpacing * settings.fontSize - settings.fontSize)
                        .foregroundColor(settings.theme.textColor)
                        .padding(settings.horizontalPadding)
                        .frame(maxWidth: .infinity)
                        .background(settings.theme.backgroundColor)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("阅读设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        bookStore.updateSettings(settings)
                        dismiss()
                    }
                }
            }
        }
    }
}
