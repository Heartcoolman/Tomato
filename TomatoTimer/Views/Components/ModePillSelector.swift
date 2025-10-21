//
//  ModePillSelector.swift
//  TomatoTimer
//
//  Mode Pill Selector with Gradient
//

import SwiftUI

/// 模式药丸选择器
struct ModePillSelector: View {
    @ObservedObject var timerEngine: TimerEngine
    let isDisabled: Bool
    
    init(timerEngine: TimerEngine, isDisabled: Bool = false) {
        self.timerEngine = timerEngine
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(TimerMode.allCases) { mode in
                ModePill(
                    mode: mode,
                    isSelected: timerEngine.currentMode == mode,
                    isDisabled: isDisabled,
                    action: {
                        if !isDisabled {
                            withAnimation(.elasticButton) {
                                timerEngine.switchMode(to: mode)
                            }
                            // 触觉反馈由调用方处理
                            HapticManager.shared.playSelection()
                        }
                    }
                )
            }
        }
    }
}

/// 单个模式药丸按钮
struct ModePill: View {
    let mode: TimerMode
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                // 指示器圆点
                Circle()
                    .fill(isSelected ? Color.white : indicatorColor)
                    .frame(width: 8, height: 8)
                
                // 文字
                Text(mode.displayName)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .frame(minWidth: 120)
            .background(backgroundView)
            .cornerRadius(28) // 胶囊形
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(borderColor, lineWidth: isSelected ? 1.5 : 0)
            )
            .scaleEffect(isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
            .shadow(
                color: shadowColor,
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
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
    
    // MARK: - Styling
    
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            GradientLibrary.gradient(for: mode)
        } else {
            Color.white.opacity(isHovered ? 0.8 : 0.5)
        }
    }
    
    private var textColor: Color {
        isSelected ? .white : .neutralGray
    }
    
    private var indicatorColor: Color {
        switch mode {
        case .work:
            return Color.modernBlue1
        case .shortBreak:
            return Color.modernGreen1
        case .longBreak:
            return Color.modernPurple1
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return Color.white.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private var shadowColor: Color {
        if !isSelected {
            return Color.black.opacity(0.05)
        }
        
        switch mode {
        case .work:
            return Color.modernBlue1.opacity(0.3)
        case .shortBreak:
            return Color.modernGreen1.opacity(0.3)
        case .longBreak:
            return Color.modernPurple1.opacity(0.3)
        }
    }
}

// MARK: - Compact Mode Selector

/// 紧凑型模式选择器（用于小屏幕）
struct CompactModeSelector: View {
    @ObservedObject var timerEngine: TimerEngine
    let isDisabled: Bool
    
    init(timerEngine: TimerEngine, isDisabled: Bool = false) {
        self.timerEngine = timerEngine
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            ForEach(TimerMode.allCases) { mode in
                CompactModeButton(
                    mode: mode,
                    isSelected: timerEngine.currentMode == mode,
                    isDisabled: isDisabled,
                    action: {
                        if !isDisabled {
                            withAnimation(.elasticButton) {
                                timerEngine.switchMode(to: mode)
                            }
                        }
                    }
                )
            }
        }
    }
}

struct CompactModeButton: View {
    let mode: TimerMode
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // 模式图标
                Image(systemName: modeIcon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isSelected ? GradientLibrary.gradient(for: mode) : LinearGradient(colors: [.neutralMid], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 32)
                
                // 模式名称
                Text(mode.displayName)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .neutralGray : .neutralMid)
                
                Spacer()
                
                // 选中指示器
                if isSelected {
                    Circle()
                        .fill(GradientLibrary.gradient(for: mode))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .fill(isSelected ? Color.white : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                    .stroke(isSelected ? Color.glassBorder : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }
    
    private var modeIcon: String {
        switch mode {
        case .work:
            return "briefcase.fill"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "couch.fill"
        }
    }
}

// MARK: - Segmented Mode Selector

/// 分段控制样式的模式选择器
struct SegmentedModeSelector: View {
    @ObservedObject var timerEngine: TimerEngine
    let isDisabled: Bool
    
    @Namespace private var animation
    
    init(timerEngine: TimerEngine, isDisabled: Bool = false) {
        self.timerEngine = timerEngine
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TimerMode.allCases) { mode in
                Button(action: {
                    if !isDisabled {
                        withAnimation(.liquidGlass) {
                            timerEngine.switchMode(to: mode)
                        }
                    }
                }) {
                    Text(mode.displayName)
                        .font(.system(size: 14, weight: timerEngine.currentMode == mode ? .semibold : .regular))
                        .foregroundColor(timerEngine.currentMode == mode ? .white : .neutralMid)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                        .background(
                            Group {
                                if timerEngine.currentMode == mode {
                                    GradientLibrary.gradient(for: mode)
                                        .matchedGeometryEffect(id: "background", in: animation)
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                .fill(.ultraThinMaterial)
        )
        .cornerRadius(DesignTokens.CornerRadius.sm)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Preview

#Preview {
    let settingsStore = SettingsStore()
    let statsStore = StatsStore()
    let gameStore = GameStore()
    let petStore = PetStore()
    let timerEngine = TimerEngine(
        settingsStore: settingsStore,
        statsStore: statsStore,
        gameStore: gameStore,
        petStore: petStore
    )
    
    return ScrollView {
        VStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 8) {
                Text("标准药丸选择器")
                    .font(.headline)
                ModePillSelector(timerEngine: timerEngine)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("禁用状态")
                    .font(.headline)
                ModePillSelector(timerEngine: timerEngine, isDisabled: true)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("紧凑型选择器")
                    .font(.headline)
                CompactModeSelector(timerEngine: timerEngine)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("分段控制选择器")
                    .font(.headline)
                SegmentedModeSelector(timerEngine: timerEngine)
            }
        }
        .padding()
    }
    .background(Color.surfaceSecondary)
}

