//
//  StatusCard.swift
//  TomatoTimer
//
//  Status Card with Circular Progress
//

import SwiftUI

/// 状态卡片
struct StatusCard: View {
    let icon: String
    let title: String
    let value: Double  // 0-100
    let gradient: LinearGradient
    let showProgress: Bool
    
    @State private var animatedValue: Double = 0
    
    init(
        icon: String,
        title: String,
        value: Double,
        gradient: LinearGradient,
        showProgress: Bool = true
    ) {
        self.icon = icon
        self.title = title
        self.value = min(max(value, 0), 100)
        self.gradient = gradient
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            // 图标和进度环
            ZStack {
                if showProgress {
                    // 背景环
                    Circle()
                        .stroke(Color.neutralSuperLight.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    // 进度环
                    Circle()
                        .trim(from: 0, to: animatedValue / 100)
                        .stroke(gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                }
                
                // 图标
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(gradient)
            }
            
            // 数值
            Text("\(Int(value))%")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.neutralGray)
                .monospacedDigit()
            
            // 标题
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.neutralMid)
        }
        .frame(width: DesignTokens.CardSize.statusCard.width, height: DesignTokens.CardSize.statusCard.height)
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .stroke(Color.glassBorder, lineWidth: 0.5)
        )
        .shadow(
            color: DesignTokens.Shadow.small.color,
            radius: DesignTokens.Shadow.small.radius,
            x: DesignTokens.Shadow.small.x,
            y: DesignTokens.Shadow.small.y
        )
        .onAppear {
            withAnimation(.fluidProgress.delay(0.1)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { oldValue, newValue in
            withAnimation(.fluidProgress) {
                animatedValue = newValue
            }
        }
    }
}

// MARK: - Compact Status Card

/// 紧凑型状态卡片（水平布局）
struct CompactStatusCard: View {
    let icon: String
    let title: String
    let value: String
    let gradient: LinearGradient
    
    init(
        icon: String,
        title: String,
        value: String,
        gradient: LinearGradient
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.gradient = gradient
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // 图标容器
            ZStack {
                Circle()
                    .fill(gradient.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(gradient)
            }
            
            // 文字信息
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.neutralMid)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.neutralGray)
                    .monospacedDigit()
            }
            
            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
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

// MARK: - Header Status Card

/// 头部状态卡片（用于顶部栏）
struct HeaderStatusCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let gradient: LinearGradient
    
    init(
        icon: String,
        title: String,
        value: String,
        subtitle: String? = nil,
        gradient: LinearGradient
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.gradient = gradient
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            // 顶部：图标+标题
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.neutralMid)
            }
            
            // 数值
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.neutralGray)
                .monospacedDigit()
            
            // 副标题（可选）
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.neutralLight)
            }
        }
        .frame(width: DesignTokens.CardSize.headerCard.width, height: DesignTokens.CardSize.headerCard.height)
        .padding(DesignTokens.Spacing.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                    .fill(gradient.opacity(0.1))
                    .blendMode(.softLight)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
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

// MARK: - Mini Status Indicator

/// 迷你状态指示器
struct MiniStatusIndicator: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(color)
                .monospacedDigit()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            // 标准状态卡片
            HStack(spacing: 16) {
                StatusCard(
                    icon: "heart.fill",
                    title: "健康",
                    value: 95,
                    gradient: GradientLibrary.healthStatus
                )
                
                StatusCard(
                    icon: "face.smiling.fill",
                    title: "快乐",
                    value: 88,
                    gradient: GradientLibrary.happinessStatus
                )
                
                StatusCard(
                    icon: "fork.knife",
                    title: "饱食",
                    value: 75,
                    gradient: GradientLibrary.hungerStatus
                )
            }
            
            // 紧凑型卡片
            VStack(spacing: 12) {
                CompactStatusCard(
                    icon: "flame.fill",
                    title: "连续天数",
                    value: "15 天",
                    gradient: GradientLibrary.streakCard
                )
                
                CompactStatusCard(
                    icon: "chart.bar.fill",
                    title: "今日完成",
                    value: "6 个番茄",
                    gradient: GradientLibrary.progressCard
                )
            }
            .padding(.horizontal)
            
            // 头部状态卡片
            HStack(spacing: 12) {
                HeaderStatusCard(
                    icon: "💰",
                    title: "番茄币",
                    value: "1,234",
                    subtitle: "+50 今日",
                    gradient: GradientLibrary.coinCard
                )
                
                HeaderStatusCard(
                    icon: "🔥",
                    title: "连续打卡",
                    value: "15 天",
                    subtitle: "90% 至目标",
                    gradient: GradientLibrary.streakCard
                )
            }
            .padding(.horizontal)
            
            // 迷你指示器
            HStack(spacing: 12) {
                MiniStatusIndicator(icon: "heart.fill", value: "95%", color: .red)
                MiniStatusIndicator(icon: "bolt.fill", value: "88%", color: .blue)
                MiniStatusIndicator(icon: "leaf.fill", value: "75%", color: .green)
            }
        }
        .padding()
    }
    .background(Color.surfaceSecondary)
}

