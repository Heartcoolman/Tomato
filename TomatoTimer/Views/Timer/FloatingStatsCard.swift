//
//  FloatingStatsCard.swift
//  TomatoTimer
//
//  Floating statistics card with Liquid Glass effect
//

import SwiftUI

struct FloatingStatsCard: View {
    @ObservedObject var statsStore: StatsStore
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Header
            header
            
            // Stats grid
            statsGrid
            
            // Progress bar
            if todayGoal > 0 {
                progressSection
                    .transition(DesignTokens.Transition.fluid)
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: DesignTokens.Layout.maxCardWidth)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.card)
                .stroke(
                    LinearGradient(
                        colors: [Color.glassHighlight, Color.glassBorder],
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
    
    // MARK: - Components
    
    private var header: some View {
        HStack {
            Label {
                Text("今日进度")
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(.neutralGray)
            } icon: {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: DesignTokens.IconSize.medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button {
                withAnimation(.liquidGlass) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "info.circle.fill")
                    .font(.system(size: DesignTokens.IconSize.medium))
                    .foregroundColor(.neutralMid)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var statsGrid: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            StatItem(
                icon: "circle.fill",
                value: "\(todayCompletedSessions)",
                label: "已完成",
                color: .primary
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                icon: "clock.fill",
                value: "\(totalMinutesToday)",
                label: "分钟",
                color: .secondary
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                icon: "flame.fill",
                value: "\(streakDays)",
                label: "连续",
                color: .warning
            )
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Text("每日目标")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(.neutralMid)
                
                Spacer()
                
                Text("\(todayCompletedSessions)/\(todayGoal)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.neutralSuperLight.opacity(0.3))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: Color.workModeGradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * progressPercentage,
                            height: 8
                        )
                        .animation(.liquidGlass, value: progressPercentage)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - Computed Properties
    
    private var todayCompletedSessions: Int {
        statsStore.todayPomodoroCount
    }
    
    private var totalMinutesToday: Int {
        statsStore.todayTotalMinutes
    }
    
    private var streakDays: Int {
        statsStore.currentStreak
    }
    
    private var todayGoal: Int {
        8 // Default goal, could be made configurable
    }
    
    private var progressPercentage: Double {
        guard todayGoal > 0 else { return 0 }
        return min(Double(todayCompletedSessions) / Double(todayGoal), 1.0)
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.neutralGray)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.neutralMid)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    FloatingStatsCard(statsStore: StatsStore())
        .padding()
        .background(Color.surfaceSecondary)
}

