//
//  DesignTokens.swift
//  TomatoTimer
//
//  iPadOS 26 Design System
//  Liquid Glass Design Tokens
//

import SwiftUI

/// 设计令牌 - iPadOS 26 Liquid Glass 设计系统
struct DesignTokens {
    
    // MARK: - Spacing
    
    /// 间距系统 - 基于 8pt 网格
    struct Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        /// 卡片内边距
        static let cardPadding: CGFloat = 20
        /// 容器内边距
        static let containerPadding: CGFloat = 24
        /// 屏幕边缘边距
        static let screenEdge: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    
    /// 圆角系统
    struct CornerRadius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        
        /// 卡片圆角
        static let card: CGFloat = 16
        /// 按钮圆角
        static let button: CGFloat = 14
        /// 模态窗口圆角
        static let modal: CGFloat = 20
    }
    
    // MARK: - Shadows
    
    /// 阴影系统
    struct Shadow {
        /// 微小阴影 - 用于悬浮元素
        static let subtle = (color: Color.black.opacity(0.04), radius: 4.0, x: 0.0, y: 2.0)
        
        /// 小阴影 - 用于卡片
        static let small = (color: Color.black.opacity(0.06), radius: 8.0, x: 0.0, y: 4.0)
        
        /// 中等阴影 - 用于浮动面板
        static let medium = (color: Color.black.opacity(0.08), radius: 16.0, x: 0.0, y: 8.0)
        
        /// 大阴影 - 用于模态窗口
        static let large = (color: Color.black.opacity(0.12), radius: 24.0, x: 0.0, y: 12.0)
    }
    
    // MARK: - Blur
    
    /// 模糊效果强度
    struct BlurRadius {
        static let subtle: CGFloat = 4
        static let light: CGFloat = 8
        static let medium: CGFloat = 16
        static let heavy: CGFloat = 24
    }
    
    // MARK: - Liquid Glass Effects
    
    /// Liquid Glass 效果参数
    struct LiquidGlass {
        /// 折射强度
        static let refractionIntensity: Double = 0.15
        
        /// 反射透明度
        static let reflectionOpacity: Double = 0.3
        
        /// 光泽强度
        static let glossIntensity: Double = 0.4
        
        /// 流体动画持续时间
        static let fluidDuration: TimeInterval = 0.8
        
        /// 渐变色停止点
        static let gradientStops: [CGFloat] = [0.0, 0.3, 0.7, 1.0]
    }
    
    // MARK: - Typography
    
    /// 字体系统
    struct Typography {
        /// 大标题
        static let largeTitle: Font = .system(size: 48, weight: .bold, design: .rounded)
        
        /// 标题1
        static let title1: Font = .system(size: 32, weight: .bold, design: .rounded)
        
        /// 标题2
        static let title2: Font = .system(size: 24, weight: .semibold, design: .rounded)
        
        /// 标题3
        static let title3: Font = .system(size: 20, weight: .semibold, design: .rounded)
        
        /// 正文
        static let body: Font = .system(size: 16, weight: .regular, design: .default)
        
        /// 说明文字
        static let caption: Font = .system(size: 13, weight: .regular, design: .default)
        
        /// 等宽字体 - 用于时间显示
        static let monoLarge: Font = .system(size: 72, weight: .light, design: .monospaced)
        static let monoMedium: Font = .system(size: 48, weight: .regular, design: .monospaced)
    }
    
    // MARK: - Transitions
    
    /// 过渡效果
    struct Transition {
        /// 流体过渡
        static let fluid: AnyTransition = .asymmetric(
            insertion: .scale(scale: 0.95).combined(with: .opacity),
            removal: .scale(scale: 1.05).combined(with: .opacity)
        )
        
        /// 滑入滑出
        static let slide: AnyTransition = .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
        
        /// 淡入淡出
        static let fade: AnyTransition = .opacity
        
        /// 模糊替换 - iPadOS 26 特性
        static let blurReplace: AnyTransition = .opacity.combined(with: .scale(scale: 0.98))
    }
    
    // MARK: - Icon Sizes
    
    /// 图标尺寸
    struct IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let xlarge: CGFloat = 48
    }
    
    // MARK: - Layout
    
    /// 布局常量
    struct Layout {
        /// 侧边栏宽度
        static let sidebarWidth: CGFloat = 280
        
        /// 最小内容宽度
        static let minContentWidth: CGFloat = 600
        
        /// 最大内容宽度
        static let maxContentWidth: CGFloat = 1200
        
        /// 卡片最大宽度
        static let maxCardWidth: CGFloat = 400
        
        /// 圆环尺寸
        static let timerRingSize: CGFloat = 400
        static let timerRingSizeCompact: CGFloat = 300
    }
    
    // MARK: - Opacity
    
    /// 透明度等级
    struct Opacity {
        static let disabled: Double = 0.5
        static let secondary: Double = 0.7
        static let tertiary: Double = 0.5
        static let ghost: Double = 0.3
    }
    
    // MARK: - Animation Curves (动画曲线)
    
    /// 预定义动画曲线
    struct AnimationCurves {
        /// 液体玻璃动画（流畅弹性）
        static let liquidGlass = Animation.spring(response: 0.6, dampingFraction: 0.8)
        
        /// 庆祝动画（强弹性）
        static let celebration = Animation.spring(response: 0.8, dampingFraction: 0.6)
        
        /// 弹性按钮动画
        static let elasticButton = Animation.spring(response: 0.3, dampingFraction: 0.7)
        
        /// 平滑过渡
        static let smooth = Animation.easeInOut(duration: 0.3)
        
        /// 快速过渡
        static let quick = Animation.easeOut(duration: 0.2)
        
        /// 悬浮效果
        static let hover = Animation.easeInOut(duration: 0.15)
        
        /// 呼吸效果
        static let breathing = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        
        /// 脉冲效果
        static let pulse = Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
        
        /// 流动效果（用于渐变）
        static let flowing = Animation.linear(duration: 3.0).repeatForever(autoreverses: false)
    }
    
    // MARK: - Card Sizes (卡片尺寸)
    
    /// 预定义卡片尺寸
    struct CardSize {
        /// 头部状态卡片
        static let headerCard = CGSize(width: 220, height: 72)
        
        /// 状态卡片
        static let statusCard = CGSize(width: 160, height: 120)
        
        /// 互动按钮卡片
        static let interactionCard = CGSize(width: 160, height: 160)
        
        /// 游戏卡片
        static let gameCard = CGSize(width: 880, height: 180)
        
        /// 成就卡片
        static let achievementCard = CGSize(width: 200, height: 240)
        
        /// 宠物展示卡片
        static let petDisplayCard = CGSize(width: 600, height: 700)
    }
}

// MARK: - View Modifiers

extension View {
    /// 应用卡片样式
    func cardStyle(isGlass: Bool = true) -> some View {
        self
            .padding(DesignTokens.Spacing.cardPadding)
            .background(
                Group {
                    if isGlass {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                            .fill(.ultraThinMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                            .fill(Color.white)
                    }
                }
            )
            .shadow(
                color: DesignTokens.Shadow.small.color,
                radius: DesignTokens.Shadow.small.radius,
                x: DesignTokens.Shadow.small.x,
                y: DesignTokens.Shadow.small.y
            )
    }
    
    /// 应用浮动样式
    func floatingStyle() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(DesignTokens.CornerRadius.lg)
            .shadow(
                color: DesignTokens.Shadow.medium.color,
                radius: DesignTokens.Shadow.medium.radius,
                x: DesignTokens.Shadow.medium.x,
                y: DesignTokens.Shadow.medium.y
            )
    }
    
    /// 应用 Liquid Glass 效果
    func liquidGlassEffect(color: Color = .white) -> some View {
        self
            .background(
                ZStack {
                    // 基础毛玻璃
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                        .fill(.ultraThinMaterial)
                    
                    // 颜色叠加
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                        .fill(color.opacity(DesignTokens.LiquidGlass.reflectionOpacity))
                        .blendMode(.softLight)
                }
            )
    }
}

