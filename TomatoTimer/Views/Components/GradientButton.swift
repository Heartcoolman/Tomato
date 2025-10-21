//
//  GradientButton.swift
//  TomatoTimer
//
//  Modern Gradient Button with Animations
//

import SwiftUI

/// 渐变按钮样式
enum GradientButtonStyle {
    case primary      // 主要按钮
    case secondary    // 次要按钮
    case success      // 成功按钮
    case warning      // 警告按钮
    case outline      // 轮廓按钮
    case custom(LinearGradient)  // 自定义渐变
    
    var gradient: LinearGradient {
        switch self {
        case .primary:
            return GradientLibrary.primaryButton
        case .secondary:
            return GradientLibrary.secondaryButton
        case .success:
            return GradientLibrary.successButton
        case .warning:
            return GradientLibrary.warningButton
        case .outline:
            return GradientLibrary.primaryButton
        case .custom(let gradient):
            return gradient
        }
    }
}

/// 渐变按钮
struct GradientButton: View {
    let title: String
    let icon: String?
    let style: GradientButtonStyle
    let action: () -> Void
    let fullWidth: Bool
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    
    init(
        _ title: String,
        icon: String? = nil,
        style: GradientButtonStyle = .primary,
        fullWidth: Bool = true,
        height: CGFloat = 64,
        cornerRadius: CGFloat = 16,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
        self.fullWidth = fullWidth
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Button(action: {
            action()
            triggerRipple()
        }) {
            ZStack {
                // 背景和边框
                backgroundView
                
                // 涟漪效果
                if rippleOpacity > 0 {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .scaleEffect(rippleScale)
                        .opacity(rippleOpacity)
                }
                
                // 按钮内容
                contentView
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: height)
            .background(buttonBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderGradient, lineWidth: isOutline ? 2 : 0)
            )
            .shadow(
                color: shadowColor,
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDistance: 0, pressing: { pressing in
            withAnimation(.elasticButton) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    // MARK: - Subviews
    
    private var contentView: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 17, weight: .semibold))
        }
        .foregroundColor(textColor)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if !isOutline {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(style.gradient)
        }
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        if isOutline {
            Color.clear
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Computed Properties
    
    private var isOutline: Bool {
        if case .outline = style {
            return true
        }
        return false
    }
    
    private var textColor: Color {
        isOutline ? .primary : .white
    }
    
    private var borderGradient: LinearGradient {
        style.gradient
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return Color.modernBlue1.opacity(0.3)
        case .secondary:
            return Color.modernPink1.opacity(0.3)
        case .success:
            return Color.modernGreen1.opacity(0.3)
        case .warning:
            return Color.modernOrange1.opacity(0.3)
        case .outline:
            return Color.black.opacity(0.1)
        case .custom:
            return Color.black.opacity(0.2)
        }
    }
    
    // MARK: - Actions
    
    private func triggerRipple() {
        rippleScale = 0
        rippleOpacity = 0.6
        
        withAnimation(.easeOut(duration: 0.6)) {
            rippleScale = 1.5
            rippleOpacity = 0
        }
    }
}

// MARK: - Compact Gradient Button

/// 紧凑型渐变按钮
struct CompactGradientButton: View {
    let title: String
    let icon: String?
    let style: GradientButtonStyle
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        _ title: String,
        icon: String? = nil,
        style: GradientButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(style.gradient)
            .cornerRadius(DesignTokens.CornerRadius.sm)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDistance: 0, pressing: { pressing in
            withAnimation(.quick) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Icon Gradient Button

/// 图标渐变按钮（圆形）
struct IconGradientButton: View {
    let icon: String
    let style: GradientButtonStyle
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    init(
        icon: String,
        style: GradientButtonStyle = .primary,
        size: CGFloat = 48,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(style.gradient)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.9 : (isHovered ? 1.05 : 1.0))
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: isPressed ? 4 : 8,
                    x: 0,
                    y: isPressed ? 2 : 4
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDistance: 0, pressing: { pressing in
            withAnimation(.elasticButton) {
                isPressed = pressing
            }
        }, perform: {})
        .onHover { hovering in
            withAnimation(.hover) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        GradientButton("开始", icon: "play.fill", style: .primary) {
            print("Primary tapped")
        }
        
        GradientButton("暂停", icon: "pause.fill", style: .secondary) {
            print("Secondary tapped")
        }
        
        GradientButton("完成", icon: "checkmark", style: .success, fullWidth: false) {
            print("Success tapped")
        }
        
        GradientButton("重置", icon: "arrow.counterclockwise", style: .outline) {
            print("Outline tapped")
        }
        
        HStack(spacing: 16) {
            CompactGradientButton("保存", icon: "square.and.arrow.down") {
                print("Compact tapped")
            }
            
            CompactGradientButton("分享", icon: "square.and.arrow.up", style: .secondary) {
                print("Share tapped")
            }
        }
        
        HStack(spacing: 16) {
            IconGradientButton(icon: "heart.fill", style: .warning) {
                print("Heart tapped")
            }
            
            IconGradientButton(icon: "star.fill", style: .success) {
                print("Star tapped")
            }
            
            IconGradientButton(icon: "bell.fill", style: .primary) {
                print("Bell tapped")
            }
        }
    }
    .padding()
    .background(Color.surfaceSecondary)
}

