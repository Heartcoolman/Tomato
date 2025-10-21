//
//  MainViewNew.swift
//  TomatoTimer
//
//  Modern navigation with iPadOS 26 support
//

import SwiftUI

struct MainViewNew: View {
    @StateObject private var coordinator = AppStateCoordinator.shared
    @State private var selectedItem: NavigationItem = .timer
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var timerEngine: TimerEngine {
        coordinator.getTimerEngine()
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
            modernSidebar
        } detail: {
            // Detail content
            detailView
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(.primary)
    }
    
    // MARK: - Modern Sidebar
    
    private var modernSidebar: some View {
        ZStack {
            // Background with Liquid Glass effect
            Color.surfaceSecondary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                sidebarHeader
                    .padding(.top, DesignTokens.Spacing.xl)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                
                // Navigation items
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(NavigationItem.allCases) { item in
                            ModernSidebarItem(
                                item: item,
                                isSelected: selectedItem == item
                            ) {
                                withAnimation(.liquidGlass) {
                                    selectedItem = item
                                }
                            }
                        }
                    }
                    .padding(DesignTokens.Spacing.md)
                }
                
                Spacer()
                
                // Footer info
                sidebarFooter
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.xl)
            }
        }
        .frame(minWidth: 250)
    }
    
    private var sidebarHeader: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "timer")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("番茄")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.neutralGray)
            }
            
            Text("专注计时器")
                .font(DesignTokens.Typography.caption)
                .foregroundColor(.neutralMid)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var sidebarFooter: some View {
        GlassCard(padding: DesignTokens.Spacing.md, useMaterial: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.warning)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("连续 \(coordinator.getStatsStore().currentStreak) 天")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.neutralGray)
                    
                    Text("继续保持！")
                        .font(.system(size: 11))
                        .foregroundColor(.neutralMid)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Detail View
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .timer:
            TimerViewNew(
                timerEngine: timerEngine,
                settingsStore: coordinator.getSettingsStore(),
                statsStore: coordinator.getStatsStore()
            )
            .navigationTitle("")
            
        case .history:
            HistoryViewNew(statsStore: coordinator.getStatsStore())
                .navigationTitle(selectedItem.rawValue)
            
        case .settings:
            SettingsViewNew(settingsStore: coordinator.getSettingsStore())
                .navigationTitle(selectedItem.rawValue)
        }
    }
}

// MARK: - Modern Sidebar Item

struct ModernSidebarItem: View {
    let item: NavigationItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Icon
                Image(systemName: item.icon)
                    .font(.system(size: DesignTokens.IconSize.medium, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: DesignTokens.IconSize.xlarge)
                
                // Label
                Text(item.rawValue)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(textColor)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 6, height: 6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : 0)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? Color.primary.opacity(0.2) : .clear,
                radius: 8,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.hover) {
                isHovered = hovering
            }
        }
    }
    
    // MARK: - Styling
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.surfacePrimary
        } else if isHovered {
            return Color.white.opacity(0.5)
        } else {
            return Color.clear
        }
    }
    
    private var iconColor: Color {
        isSelected ? .primary : .neutralMid
    }
    
    private var textColor: Color {
        isSelected ? .neutralGray : .neutralMid
    }
    
    private var borderColor: Color {
        isSelected ? Color.primary.opacity(0.3) : .clear
    }
}

// MARK: - Preview

#Preview {
    MainViewNew()
        .frame(width: 1200, height: 800)
}

