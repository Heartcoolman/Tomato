//
//  ChapterParser.swift
//  Tomato
//

import Foundation

/// 章节解析器
class ChapterParser {
    
    /// 章节匹配规则
    private static let chapterPatterns = [
        // 中文
        "^第[0-9零一二三四五六七八九十百千万]+[章回节卷集部篇].*$",
        "^[0-9零一二三四五六七八九十百千万]+、.*$",
        // 英文
        "^Chapter\\s+[0-9]+.*$",
        "^Part\\s+[0-9]+.*$",
        "^Section\\s+[0-9]+.*$",
        // 数字
        "^[0-9]+\\.\\s+.*$",
        "^[0-9]+\\s+.*$"
    ]
    
    /// 解析章节
    static func parseChapters(text: String) -> [Chapter] {
        var chapters: [Chapter] = []
        let lines = text.components(separatedBy: "\n")
        var currentPosition = 0
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // 检查是否匹配章节模式
            if isChapterTitle(trimmedLine) {
                let chapter = Chapter(
                    title: trimmedLine,
                    startPosition: currentPosition
                )
                chapters.append(chapter)
            }
            
            currentPosition += line.count + 1 // +1 for newline
        }
        
        // 设置每章的结束位置
        for i in 0..<chapters.count {
            if i < chapters.count - 1 {
                chapters[i].endPosition = chapters[i + 1].startPosition
            } else {
                chapters[i].endPosition = text.count
            }
        }
        
        // 如果没有找到章节，创建一个默认章节
        if chapters.isEmpty {
            chapters.append(Chapter(
                title: "正文",
                startPosition: 0,
                endPosition: text.count
            ))
        }
        
        return chapters
    }
    
    /// 判断是否为章节标题
    private static func isChapterTitle(_ line: String) -> Bool {
        // 空行不是章节
        if line.isEmpty {
            return false
        }
        
        // 太长的行不太可能是章节标题
        if line.count > 50 {
            return false
        }
        
        // 检查是否匹配任何章节模式
        for pattern in chapterPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(line.startIndex..., in: line)
                if regex.firstMatch(in: line, options: [], range: range) != nil {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// 查找当前位置所在的章节
    static func findChapter(at position: Int, in chapters: [Chapter]) -> Chapter? {
        return chapters.first { chapter in
            position >= chapter.startPosition &&
            (chapter.endPosition == nil || position < chapter.endPosition!)
        }
    }
    
    /// 获取章节进度
    static func getChapterProgress(position: Int, chapter: Chapter) -> Double {
        guard let endPosition = chapter.endPosition else {
            return 0.0
        }
        
        let chapterLength = endPosition - chapter.startPosition
        guard chapterLength > 0 else {
            return 0.0
        }
        
        let positionInChapter = position - chapter.startPosition
        return Double(positionInChapter) / Double(chapterLength)
    }
}
