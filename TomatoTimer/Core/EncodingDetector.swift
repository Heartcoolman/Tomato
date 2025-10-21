//
//  EncodingDetector.swift
//  Tomato
//

import Foundation

/// 编码检测器
class EncodingDetector {
    
    /// 支持的编码列表
    static let supportedEncodings: [(String.Encoding, String)] = [
        (.utf8, "UTF-8"),
        (.utf16, "UTF-16"),
        (.utf16BigEndian, "UTF-16 BE"),
        (.utf16LittleEndian, "UTF-16 LE"),
        (.init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))), "GB18030"),
        (.init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))), "Big5"),
        (.shiftJIS, "Shift-JIS"),
        (.isoLatin1, "ISO-8859-1"),
        (.windowsCP1252, "Windows-1252"),
        (.init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.KOI8_R.rawValue))), "KOI8-R"),
        (.init(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))), "EUC-KR")
    ]
    
    /// 自动检测编码
    static func detectEncoding(data: Data) -> (encoding: String.Encoding, confidence: Float)? {
        // 1. 检查 BOM
        if let bomEncoding = detectBOM(data: data) {
            return (bomEncoding, 1.0)
        }
        
        // 2. 尝试各种编码
        var bestMatch: (encoding: String.Encoding, confidence: Float)?
        
        for (encoding, _) in supportedEncodings {
            if let string = String(data: data, encoding: encoding) {
                let confidence = calculateConfidence(string: string, encoding: encoding)
                
                if let current = bestMatch {
                    if confidence > current.confidence {
                        bestMatch = (encoding, confidence)
                    }
                } else {
                    bestMatch = (encoding, confidence)
                }
            }
        }
        
        return bestMatch
    }
    
    /// 检测 BOM (Byte Order Mark)
    private static func detectBOM(data: Data) -> String.Encoding? {
        guard data.count >= 2 else { return nil }
        
        let bytes = [UInt8](data.prefix(4))
        
        // UTF-8 BOM: EF BB BF
        if bytes.count >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF {
            return .utf8
        }
        
        // UTF-16 LE BOM: FF FE
        if bytes[0] == 0xFF && bytes[1] == 0xFE {
            return .utf16LittleEndian
        }
        
        // UTF-16 BE BOM: FE FF
        if bytes[0] == 0xFE && bytes[1] == 0xFF {
            return .utf16BigEndian
        }
        
        return nil
    }
    
    /// 计算编码置信度
    private static func calculateConfidence(string: String, encoding: String.Encoding) -> Float {
        var confidence: Float = 0.0
        
        // 检查是否包含替换字符（�）
        let replacementCount = string.filter { $0 == "\u{FFFD}" }.count
        if replacementCount > 0 {
            confidence -= Float(replacementCount) / Float(string.count) * 0.5
        }
        
        // 检查是否包含常见中文字符
        let chineseCount = string.filter { char in
            let scalar = char.unicodeScalars.first?.value ?? 0
            return (0x4E00...0x9FFF).contains(scalar)
        }.count
        
        if chineseCount > 0 {
            confidence += Float(chineseCount) / Float(string.count) * 0.3
        }
        
        // 检查是否包含常见标点符号
        let punctuationCount = string.filter { "。，、；：？！""''（）《》【】".contains($0) }.count
        if punctuationCount > 0 {
            confidence += Float(punctuationCount) / Float(string.count) * 0.2
        }
        
        // 基础分数
        confidence += 0.5
        
        return min(max(confidence, 0.0), 1.0)
    }
    
    /// 解码文本
    static func decodeText(data: Data, encoding: String.Encoding) -> String? {
        // 移除 BOM
        var cleanData = data
        if let bomEncoding = detectBOM(data: data), bomEncoding == encoding {
            if encoding == .utf8 && data.count >= 3 {
                cleanData = data.dropFirst(3)
            } else if (encoding == .utf16LittleEndian || encoding == .utf16BigEndian) && data.count >= 2 {
                cleanData = data.dropFirst(2)
            }
        }
        
        guard var string = String(data: cleanData, encoding: encoding) else {
            return nil
        }
        
        // 统一换行符
        string = string.replacingOccurrences(of: "\r\n", with: "\n")
        string = string.replacingOccurrences(of: "\r", with: "\n")
        
        return string
    }
    
    /// 获取编码显示名称
    static func getEncodingName(encoding: String.Encoding) -> String {
        for (enc, name) in supportedEncodings {
            if enc == encoding {
                return name
            }
        }
        return "未知编码"
    }
    
    /// 预览文本（前几行）
    static func previewText(data: Data, encoding: String.Encoding, lines: Int = 5) -> String? {
        guard let text = decodeText(data: data, encoding: encoding) else {
            return nil
        }
        
        let allLines = text.components(separatedBy: "\n")
        let previewLines = allLines.prefix(lines)
        return previewLines.joined(separator: "\n")
    }
}
