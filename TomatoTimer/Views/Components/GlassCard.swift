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
        
        FloatingGlassCard {
            HStack {
                Image(systemName: "timer")
                    .font(.system(size: DesignTokens.IconSize.large))
                Text("Floating Card")
                    .font(DesignTokens.Typography.title3)
            }
        }
        
        GlassCard(useMaterial: false) {
            Text("Solid Card")
                .font(DesignTokens.Typography.body)
        }
    }
    .padding()
    .background(Color.surfaceSecondary)
}

