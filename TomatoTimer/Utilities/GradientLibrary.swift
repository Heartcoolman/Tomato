//
//  GradientLibrary.swift
//  TomatoTimer
//
//  玻璃态UI渐变库
//  集中管理所有渐变效果
//

import SwiftUI

/// 渐变库 - 为不同UI元素提供预定义渐变
struct GradientLibrary {
    
    // MARK: - 计时器模式渐变
    
    /// 工作模式渐变（蓝紫色）
    static let workMode = LinearGradient(
        colors: [Color.modernBlue1, Color.modernBlue2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 短休息模式渐变（青蓝色）
    static let shortBreakMode = LinearGradient(
        colors: [Color.modernGreen1, Color.modernGreen2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 长休息模式渐变（紫青色）
    static let longBreakMode = LinearGradient(
        colors: [Color.modernPurple1, Color.modernPurple2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 根据计时器模式获取渐变
    static func gradient(for mode: TimerMode) -> LinearGradient {
        switch mode {
        case .work:
            return workMode
        case .shortBreak:
            return shortBreakMode
        case .longBreak:
            return longBreakMode
        }
    }
    
    // MARK: - 按钮渐变
    
    /// 主要按钮渐变
    static let primaryButton = LinearGradient(
        colors: [Color.modernBlue1, Color.modernBlue2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 次要按钮渐变
    static let secondaryButton = LinearGradient(
        colors: [Color.modernPink1, Color.modernPink2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 成功按钮渐变
    static let successButton = LinearGradient(
        colors: [Color.modernGreen1, Color.modernGreen2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 警告按钮渐变
    static let warningButton = LinearGradient(
        colors: [Color.modernOrange1, Color.modernOrange2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 卡片背景渐变
    
    /// 番茄币卡片渐变
    static let coinCard = LinearGradient(
        colors: [Color.gold1.opacity(0.3), Color.gold2.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 连续天数卡片渐变
    static let streakCard = LinearGradient(
        colors: [Color.modernPink1.opacity(0.3), Color.modernPink2.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 今日进度卡片渐变
    static let progressCard = LinearGradient(
        colors: [Color.modernBlue1.opacity(0.3), Color.modernBlue2.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 宠物相关渐变
    
    /// 猫咪渐变背景
    static let catPet = RadialGradient(
        colors: [Color.modernPink1.opacity(0.3), Color.clear],
        center: .center,
        startRadius: 50,
        endRadius: 200
    )
    
    /// 兔子渐变背景
    static let rabbitPet = RadialGradient(
        colors: [Color.modernPurple1.opacity(0.3), Color.clear],
        center: .center,
        startRadius: 50,
        endRadius: 200
    )
    
    /// 熊猫渐变背景
    static let pandaPet = RadialGradient(
        colors: [Color.modernBlue1.opacity(0.3), Color.clear],
        center: .center,
        startRadius: 50,
        endRadius: 200
    )
    
    // MARK: - 状态条渐变
    
    /// 健康状态渐变（红色）
    static let healthStatus = LinearGradient(
        colors: [Color(hex: "#FF6B6B"), Color(hex: "#EE5A52")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// 快乐状态渐变（黄色）
    static let happinessStatus = LinearGradient(
        colors: [Color(hex: "#FFC837"), Color(hex: "#FF8008")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// 饱食状态渐变（绿色）
    static let hungerStatus = LinearGradient(
        colors: [Color(hex: "#4ECDC4"), Color(hex: "#44A08D")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    /// 精力状态渐变（蓝色）
    static let energyStatus = LinearGradient(
        colors: [Color(hex: "#5E9FFF"), Color(hex: "#4A90E2")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - 互动按钮渐变
    
    /// 喂食按钮渐变
    static let feedButton = LinearGradient(
        colors: [Color(hex: "#4ECDC4"), Color(hex: "#44A08D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 玩耍按钮渐变
    static let playButton = LinearGradient(
        colors: [Color(hex: "#5E9FFF"), Color(hex: "#4A90E2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 抚摸按钮渐变
    static let patButton = LinearGradient(
        colors: [Color(hex: "#FFB7C5"), Color(hex: "#FF8FA3")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 治疗按钮渐变
    static let healButton = LinearGradient(
        colors: [Color(hex: "#FF6B6B"), Color(hex: "#EE5A52")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 游戏卡片渐变
    
    /// 水果接接乐渐变
    static let fruitCatchGame = LinearGradient(
        colors: [Color.modernOrange1.opacity(0.2), Color.modernOrange2.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 番茄2048渐变
    static let tomato2048Game = LinearGradient(
        colors: [Color.modernYellow1.opacity(0.2), Color.modernYellow2.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 记忆翻牌渐变
    static let memoryCardGame = LinearGradient(
        colors: [Color.modernPurple1.opacity(0.2), Color.modernPurple2.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 成就徽章渐变
    
    /// 金色徽章渐变
    static let goldBadge = LinearGradient(
        colors: [Color.gold1, Color.gold2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 银色徽章渐变
    static let silverBadge = LinearGradient(
        colors: [Color.silver1, Color.silver2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 铜色徽章渐变
    static let bronzeBadge = LinearGradient(
        colors: [Color.bronze1, Color.bronze2],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 彩虹徽章渐变（稀有成就）
    static let rainbowBadge = LinearGradient(
        colors: [
            Color.modernPink1,
            Color.modernOrange1,
            Color.modernYellow1,
            Color.modernGreen1,
            Color.modernBlue1,
            Color.modernPurple1
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - 背景渐变
    
    /// 主背景渐变
    static let mainBackground = LinearGradient(
        colors: [
            Color.surfaceSecondary,
            Color.surfaceTertiary
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// 庆祝背景渐变
    static func celebrationBackground(for mode: TimerMode) -> RadialGradient {
        let colors: [Color]
        switch mode {
        case .work:
            colors = [Color.modernBlue1.opacity(0.15), Color.modernBlue2.opacity(0.05), Color.clear]
        case .shortBreak:
            colors = [Color.modernGreen1.opacity(0.15), Color.modernGreen2.opacity(0.05), Color.clear]
        case .longBreak:
            colors = [Color.modernPurple1.opacity(0.15), Color.modernPurple2.opacity(0.05), Color.clear]
        }
        
        return RadialGradient(
            colors: colors,
            center: .center,
            startRadius: 100,
            endRadius: 500
        )
    }
    
    // MARK: - 辅助方法
    
    /// 创建自定义渐变
    static func custom(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    
    /// 创建渐变叠加（用于毛玻璃卡片）
    static func overlay(baseColor: Color, opacity: Double = 0.2) -> LinearGradient {
        LinearGradient(
            colors: [
                baseColor.opacity(opacity),
                baseColor.opacity(opacity * 0.7)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

