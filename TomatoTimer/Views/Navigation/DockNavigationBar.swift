//
//  DockNavigationBar.swift
//  TomatoTimer
//
//  Bottom Dock Navigation Bar with Glass Effect
//

import SwiftUI

/// Dock导航项
enum DockItem: String, CaseIterable, Identifiable {
    case timer = "计时器"
    case pet = "宠物"
    case achievements = "成就"
    case history = "历史"
    case settings = "设置"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .timer: return "timer"
        case .pet: return "pawprint.fill"
        case .achievements: return "trophy.fill"
        case .history: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

/// Dock导航栏
struct DockNavigationBar: View {
    @Binding var selectedItem: DockItem
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(DockItem.allCases) { item in
                DockButton(
                    item: item,
                    isSelected: selectedItem == item
                ) {
                    withAnimation(.liquidGlass) {
                        selectedItem = item
                    }
                    HapticManager.shared.playSelection()
                }
            }
        }
        .frame(height: 88)
        .background(dockBackground)
        .overlay(dockBorder, alignment: .top)
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 24,
            x: 0,
            y: -4
        )
    }
    
    private var dockBackground: some View {
        ZStack {
            // 毛玻璃背景
            Rectangle()
                .fill(.ultraThinMaterial)
            
            // 渐变叠加
            LinearGradient(
                colors: [
                    Color.white.opacity(0.05),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var dockBorder: some View {
        Rectangle()
            .fill(Color.glassBorder)
            .frame(height: 0.5)
    }
}

/// Dock按钮
struct DockButton: View {
    let item: DockItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // 图标
                ZStack {
                    // 图标背景（仅选中时显示）
                    if isSelected {
                        Circle()
                            .fill(iconBackgroundGradient)
                            .frame(width: 48, height: 48)
                    }
                    
                    // 图标
                    Image(systemName: item.icon)
                        .font(.system(size: isSelected ? 24 : 22, weight: .medium))
                        .foregroundStyle(iconGradient)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                }
                .frame(height: 48)
                
                // 标签
                Text(item.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .neutralGray : .neutralMid)
                
                // 选中指示器
                if isSelected {
                    Circle()
                        .fill(indicatorGradient)
                        .frame(width: 4, height: 4)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Color.clear
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDistance: 0, pressing: { pressing in
            withAnimation(.elasticButton) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    // MARK: - Styling
    
    private var iconGradient: LinearGradient {
        if isSelected {
            return GradientLibrary.primaryButton
        } else {
            return LinearGradient(colors: [.neutralMid], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private var iconBackgroundGradient: LinearGradient {
        GradientLibrary.primaryButton.opacity(0.15)
    }
    
    private var indicatorGradient: LinearGradient {
        GradientLibrary.primaryButton
    }
}

// MARK: - Compact Dock (for small screens)

/// 紧凑型Dock导航栏
struct CompactDockNavigationBar: View {
    @Binding var selectedItem: DockItem
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(DockItem.allCases) { item in
                CompactDockButton(
                    item: item,
                    isSelected: selectedItem == item
                ) {
                    withAnimation(.liquidGlass) {
                        selectedItem = item
                    }
                    HapticManager.shared.playSelection()
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .frame(height: 64)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 16,
                    x: 0,
                    y: -2
                )
        )
        .padding(.horizontal)
        .padding(.bottom, DesignTokens.Spacing.xs)
    }
}

struct CompactDockButton: View {
    let item: DockItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: item.icon)
                    .font(.system(size: isSelected ? 22 : 20, weight: .medium))
                    .foregroundStyle(isSelected ? GradientLibrary.primaryButton : LinearGradient(colors: [.neutralMid], startPoint: .leading, endPoint: .trailing))
                
                if isSelected {
                    Circle()
                        .fill(GradientLibrary.primaryButton)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview("Standard Dock") {
    @Previewable @State var selectedItem: DockItem = .timer
    
    return VStack {
        Spacer()
        
        Text("Selected: \(selectedItem.rawValue)")
            .font(.title2)
        
        Spacer()
        
        DockNavigationBar(selectedItem: $selectedItem)
    }
    .background(Color.surfaceSecondary)
}

#Preview("Compact Dock") {
    @Previewable @State var selectedItem: DockItem = .pet
    
    return VStack {
        Spacer()
        
        Text("Selected: \(selectedItem.rawValue)")
            .font(.title2)
        
        Spacer()
        
        CompactDockNavigationBar(selectedItem: $selectedItem)
    }
    .background(Color.surfaceSecondary)
}

