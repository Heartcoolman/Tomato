//
//  AnimationPresets.swift
//  TomatoTimer
//
//  iPadOS 26 Animation System
//  Professional animation presets for consistent UX
//

import SwiftUI

/// 动画预设 - 统一的动画系统
extension Animation {
    
    // MARK: - Liquid Glass Animations
    
    /// Liquid Glass 流体动画 - iPadOS 26 标志性动画
    /// 用于主要的状态转换和界面变化
    static var liquidGlass: Animation {
        .spring(response: 0.55, dampingFraction: 0.825, blendDuration: 0.3)
    }
    
    /// Liquid Glass 快速 - 用于即时反馈
    static var liquidGlassFast: Animation {
        .spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.2)
    }
    
    /// Liquid Glass 缓慢 - 用于大型元素
    static var liquidGlassSlow: Animation {
        .spring(response: 0.75, dampingFraction: 0.8, blendDuration: 0.4)
    }
    
    // MARK: - Professional Animations
    
    /// 专业精准动画 - 用于控制面板和按钮
    /// 提供清晰的操作反馈
    static var professional: Animation {
        .spring(response: 0.45, dampingFraction: 0.88, blendDuration: 0.2)
    }
    
    /// 专业快速 - 用于小元素和图标
    static var professionalFast: Animation {
        .spring(response: 0.3, dampingFraction: 0.9, blendDuration: 0.15)
    }
    
    // MARK: - Subtle Animations
    
    /// 微妙悬浮动画 - 用于悬停效果
    /// 提供细腻的交互感受
    static var subtle: Animation {
        .easeInOut(duration: 0.25)
    }
    
    /// 微妙缓慢 - 用于背景元素
    static var subtleSlow: Animation {
        .easeInOut(duration: 0.4)
    }
    
    // MARK: - Progress Animations
    
    /// 进度动画 - 用于进度环和加载指示器
    static var progress: Animation {
        .linear(duration: 0.3)
    }
    
    /// 流体进度 - 带有弹性的进度动画
    static var fluidProgress: Animation {
        .interpolatingSpring(
            mass: 1.0,
            stiffness: 100,
            damping: 15,
            initialVelocity: 0
        )
    }
    
    // MARK: - Celebration Animations
    
    /// 庆祝动画 - 用于完成状态
    static var celebration: Animation {
        .spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)
    }
    
    /// 庆祝弹性 - 更有弹性的庆祝效果
    static var celebrationBounce: Animation {
        .spring(response: 0.65, dampingFraction: 0.65, blendDuration: 0.35)
    }
    
    // MARK: - Transition Animations
    
    /// 页面切换 - 用于视图切换
    static var pageTransition: Animation {
        .spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.25)
    }
    
    /// 模态出现 - 用于模态窗口
    static var modalPresentation: Animation {
        .spring(response: 0.45, dampingFraction: 0.88, blendDuration: 0.22)
    }
    
    // MARK: - Hover Animations
    
    /// 悬停效果 - 用于按钮和卡片的悬停状态
    static var hover: Animation {
        .easeOut(duration: 0.2)
    }
    
    /// 悬停放大 - 带有轻微放大的悬停效果
    static var hoverScale: Animation {
        .spring(response: 0.3, dampingFraction: 0.85, blendDuration: 0.15)
    }
    
    // MARK: - Glass Morphing
    
    /// 玻璃态变形 - 用于 Liquid Glass 元素的变形
    static var glassMorph: Animation {
        .interpolatingSpring(
            mass: 1.2,
            stiffness: 90,
            damping: 18,
            initialVelocity: 0
        )
    }
    
    // MARK: - Continuous Animations
    
    /// 持续脉动 - 用于等待状态
    static var continuousPulse: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    }
    
    /// 持续旋转 - 用于加载指示器
    static var continuousRotation: Animation {
        .linear(duration: 1.0).repeatForever(autoreverses: false)
    }
    
    /// 持续光晕 - 用于高亮元素
    static var continuousGlow: Animation {
        .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    }
}

// MARK: - Animation Timing

/// 动画时长常量
struct AnimationTiming {
    /// 瞬时 (< 0.2s)
    static let instant: TimeInterval = 0.15
    
    /// 快速 (0.2s - 0.3s)
    static let fast: TimeInterval = 0.25
    
    /// 标准 (0.3s - 0.5s)
    static let standard: TimeInterval = 0.4
    
    /// 中等 (0.5s - 0.8s)
    static let medium: TimeInterval = 0.65
    
    /// 缓慢 (0.8s - 1.2s)
    static let slow: TimeInterval = 1.0
    
    /// 非常缓慢 (> 1.2s)
    static let verySlow: TimeInterval = 1.5
}

// MARK: - View Modifiers

extension View {
    /// 应用悬停动画效果
    func hoverEffect(scale: CGFloat = 1.05) -> some View {
        self.modifier(HoverEffectModifier(scale: scale))
    }
    
    /// 应用按压动画效果
    func pressEffect(scale: CGFloat = 0.95) -> some View {
        self.modifier(PressEffectModifier(scale: scale))
    }
}

// MARK: - Custom Modifiers

/// 悬停效果修饰器
struct HoverEffectModifier: ViewModifier {
    let scale: CGFloat
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .animation(.hover, value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

/// 按压效果修饰器
struct PressEffectModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.professionalFast, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

