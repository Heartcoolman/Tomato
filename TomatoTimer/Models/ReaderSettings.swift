//
//  ReaderSettings.swift
//  Tomato
//

import Foundation
import SwiftUI

/// 阅读器设置
struct ReaderSettings: Codable {
    var displayMode: DisplayMode = .paging
    var fontSize: CGFloat = 18
    var lineSpacing: CGFloat = 1.5
    var paragraphSpacing: CGFloat = 8
    var horizontalPadding: CGFloat = 30
    var verticalPadding: CGFloat = 40
    var fontName: String = "System"
    var theme: ReaderTheme = .light
    var autoTheme: Bool = true
    
    enum DisplayMode: String, Codable {
        case paging = "paging"
        case scrolling = "scrolling"
    }
}

/// 阅读主题
enum ReaderTheme: String, Codable, CaseIterable {
    case light = "light"
    case dark = "dark"
    case sepia = "sepia"
    
    var backgroundColor: Color {
        switch self {
        case .light: return Color.white
        case .dark: return Color.black
        case .sepia: return Color(red: 0.96, green: 0.93, blue: 0.85)
        }
    }
    
    var textColor: Color {
        switch self {
        case .light: return Color.black
        case .dark: return Color.white
        case .sepia: return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
    }
    
    var displayName: String {
        switch self {
        case .light: return "白天"
        case .dark: return "夜间"
        case .sepia: return "护眼"
        }
    }
}
