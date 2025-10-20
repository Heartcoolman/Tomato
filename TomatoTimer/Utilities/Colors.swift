//
//  Colors.swift
//  TomatoTimer
//
//  iPadOS 26 Color System
//  Liquid Glass Design Language
//

import SwiftUI

// MARK: - Base Colors

extension Color {
    // Legacy colors (maintained for compatibility)
    static let tomatoRed = Color(hex: "#B52B2D")
    static let lightYellow = Color(hex: "#F9F9F5")
    static let darkGray = Color(hex: "#2B2B2B")
    
    // MARK: - Semantic Colors
    
    /// 主要色 - 番茄红
    static let primary = Color(hex: "#B52B2D")
    static let primaryLight = Color(hex: "#D64345")
    static let primaryDark = Color(hex: "#8B2023")
    
    /// 次要色 - 橙色系
    static let secondary = Color(hex: "#FF8C42")
    static let secondaryLight = Color(hex: "#FFA566")
    static let secondaryDark = Color(hex: "#E67329")
    
    /// 强调色 - 用于工作番茄
    static let accent = Color(hex: "#FF5A5F")
    
    /// 成功色
    static let success = Color(hex: "#4CAF50")
    static let successLight = Color(hex: "#66BB6A")
    
    /// 警告色
    static let warning = Color(hex: "#FF9800")
    
    /// 错误色
    static let error = Color(hex: "#F44336")
    
    // MARK: - Neutral Colors
    
    /// 中性色系 - 用于文本和背景
    static let neutralDark = Color(hex: "#1A1A1A")
    static let neutralGray = Color(hex: "#2B2B2B")
    static let neutralMid = Color(hex: "#666666")
    static let neutralLight = Color(hex: "#999999")
    static let neutralSuperLight = Color(hex: "#E5E5E5")
    
    // MARK: - Surface Colors
    
    /// 表面颜色 - 用于卡片和容器
    static let surfacePrimary = Color(hex: "#FFFFFF")
    static let surfaceSecondary = Color(hex: "#F9F9F5")
    static let surfaceTertiary = Color(hex: "#F5F5F0")
    
    // MARK: - Mode-Specific Colors
    
    /// 工作模式颜色
    static let workMode = Color(hex: "#B52B2D")
    static let workModeLight = Color(hex: "#D64345")
    static let workModeGradient: [Color] = [
        Color(hex: "#B52B2D"),
        Color(hex: "#D64345")
    ]
    
    /// 短休息模式颜色
    static let shortBreakMode = Color(hex: "#FF8C42")
    static let shortBreakModeLight = Color(hex: "#FFA566")
    static let shortBreakModeGradient: [Color] = [
        Color(hex: "#FF8C42"),
        Color(hex: "#FFA566")
    ]
    
    /// 长休息模式颜色
    static let longBreakMode = Color(hex: "#4A90E2")
    static let longBreakModeLight = Color(hex: "#6CA6E8")
    static let longBreakModeGradient: [Color] = [
        Color(hex: "#4A90E2"),
        Color(hex: "#6CA6E8")
    ]
    
    // MARK: - Liquid Glass Colors
    
    /// Liquid Glass 基础色
    static let glassBase = Color.white.opacity(0.15)
    static let glassBorder = Color.white.opacity(0.2)
    static let glassHighlight = Color.white.opacity(0.4)
    
    /// Liquid Glass 阴影
    static let glassShadow = Color.black.opacity(0.1)
    static let glassShadowStrong = Color.black.opacity(0.15)
    
    // MARK: - Gradient Presets
    
    /// 预定义渐变
    static func liquidGlassGradient(baseColor: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                baseColor,
                baseColor.opacity(0.8),
                baseColor.opacity(0.6),
                baseColor.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// 主题渐变 - 番茄红
    static let primaryGradient = LinearGradient(
        colors: [Color.primary, Color.primaryLight, Color.primaryDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 背景渐变
    static let backgroundGradient = LinearGradient(
        colors: [
            Color.surfaceSecondary,
            Color.surfaceTertiary
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Helper Methods
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// 创建带有光晕效果的颜色
    func withGlow(intensity: Double = 0.3) -> Color {
        self.opacity(intensity)
    }
    
    /// 创建 Liquid Glass 变体
    func liquidGlass(opacity: Double = 0.7) -> Color {
        self.opacity(opacity)
    }
}

// MARK: - Material Extensions

extension Material {
    /// 自定义材质厚度
    static let liquidGlassUltraThin: Material = .ultraThinMaterial
    static let liquidGlassThin: Material = .thinMaterial
    static let liquidGlassRegular: Material = .regularMaterial
    static let liquidGlassThick: Material = .thickMaterial
}

