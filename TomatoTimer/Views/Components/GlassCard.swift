//
//  GlassCard.swift
//  TomatoTimer
//
//  Reusable Liquid Glass Card Component
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let useMaterial: Bool
    
    init(
        padding: CGFloat = DesignTokens.Spacing.cardPadding,
        cornerRadius: CGFloat = DesignTokens.CornerRadius.card,
        useMaterial: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.useMaterial = useMaterial
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                Group {
                    if useMaterial {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.surfacePrimary)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(
                color: DesignTokens.Shadow.small.color,
                radius: DesignTokens.Shadow.small.radius,
                x: DesignTokens.Shadow.small.x,
                y: DesignTokens.Shadow.small.y
            )
    }
}

// MARK: - Floating Glass Card

struct FloatingGlassCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    init(
        padding: CGFloat = DesignTokens.Spacing.cardPadding,
        cornerRadius: CGFloat = DesignTokens.CornerRadius.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.glassHighlight,
                                Color.glassBorder
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: DesignTokens.Shadow.medium.color,
                radius: DesignTokens.Shadow.medium.radius,
                x: DesignTokens.Shadow.medium.x,
                y: DesignTokens.Shadow.medium.y
            )
    }
}

// MARK: - Gradient Glass Card

/// 带渐变叠加的玻璃卡片
struct GradientGlassCard<Content: View>: View {
    let content: Content
    let gradient: LinearGradient
    let padding: CGFloat
    let cornerRadius: CGFloat
    let useMaterial: Bool
    
    init(
        gradient: LinearGradient,
        padding: CGFloat = DesignTokens.Spacing.cardPadding,
        cornerRadius: CGFloat = DesignTokens.CornerRadius.card,
        useMaterial: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.useMaterial = useMaterial
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // 毛玻璃背景
                    if useMaterial {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.surfacePrimary)
                    }
                    
                    // 渐变叠加
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(gradient.opacity(0.15))
                        .blendMode(.softLight)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(
                color: DesignTokens.Shadow.small.color,
                radius: DesignTokens.Shadow.small.radius,
                x: DesignTokens.Shadow.small.x,
                y: DesignTokens.Shadow.small.y
            )
    }
}

// MARK: - Multi-Shadow Glass Card

/// 带多层阴影的玻璃卡片
struct MultiShadowGlassCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowColor: Color
    
    init(
        padding: CGFloat = DesignTokens.Spacing.cardPadding,
        cornerRadius: CGFloat = DesignTokens.CornerRadius.card,
        shadowColor: Color = .black,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowColor = shadowColor
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            // 第一层阴影
            .shadow(
                color: shadowColor.opacity(0.08),
                radius: 8,
                x: 0,
                y: 4
            )
            // 第二层阴影
            .shadow(
                color: shadowColor.opacity(0.04),
                radius: 16,
                x: 0,
                y: 8
            )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Glass Card")
                    .font(DesignTokens.Typography.title3)
                Text("This is a Liquid Glass card with material background")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(.neutralMid)
            }
        }
        
        GradientGlassCard(gradient: GradientLibrary.progressCard) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Gradient Glass Card")
                    .font(DesignTokens.Typography.title3)
                Text("With gradient overlay")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(.neutralMid)
            }
        }
        
        FloatingGlassCard {
            HStack {
                Image(systemName: "timer")
                    .font(.system(size: DesignTokens.IconSize.large))
                Text("Floating Card")
                    .font(DesignTokens.Typography.title3)
            }
        }
        
        MultiShadowGlassCard(shadowColor: .modernBlue1) {
            Text("Multi-Shadow Card")
                .font(DesignTokens.Typography.body)
        }
    }
    .padding()
    .background(Color.surfaceSecondary)
}

