//
//  MinimalModeSelector.swift
//  TomatoTimer
//
//  Minimal and efficient mode selector
//

import SwiftUI

struct MinimalModeSelector: View {
    @ObservedObject var timerEngine: TimerEngine
    let isDisabled: Bool
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(TimerMode.allCases) { mode in
                ModeSegment(
                    mode: mode,
                    isSelected: timerEngine.currentMode == mode,
                    isDisabled: isDisabled
                ) {
                    if !isDisabled {
                        withAnimation(.liquidGlass) {
                            timerEngine.switchMode(to: mode)
                        }
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .stroke(Color.glassBorder, lineWidth: 0.5)
        )
        .disabled(isDisabled)
        .opacity(isDisabled ? DesignTokens.Opacity.disabled : 1.0)
    }
}

// MARK: - Mode Segment

struct ModeSegment: View {
    let mode: TimerMode
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.xxs) {
                // Icon
                Image(systemName: modeIcon)
                    .font(.system(size: DesignTokens.IconSize.medium, weight: .medium))
                    .foregroundColor(iconColor)
                
                // Label
                Text(mode.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                            .fill(selectionBackground)
                            .shadow(
                                color: shadowColor,
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                    } else {
                        RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.sm)
                            .fill(Color.clear)
                    }
                }
            )
            .scaleEffect(isHovered && !isDisabled ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.hover) {
                isHovered = hovering
            }
        }
        .disabled(isDisabled)
    }
    
    // MARK: - Styling
    
    private var modeIcon: String {
        switch mode {
        case .work:
            return "briefcase.fill"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "powersleep"
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return .white
        } else {
            switch mode {
            case .work:
                return Color.workMode
            case .shortBreak:
                return Color.shortBreakMode
            case .longBreak:
                return Color.longBreakMode
            }
        }
    }
    
    private var textColor: Color {
        isSelected ? .white : .neutralGray
    }
    
    private var selectionBackground: LinearGradient {
        switch mode {
        case .work:
            return Color.liquidGlassGradient(baseColor: Color.workMode)
        case .shortBreak:
            return Color.liquidGlassGradient(baseColor: Color.shortBreakMode)
        case .longBreak:
            return Color.liquidGlassGradient(baseColor: Color.longBreakMode)
        }
    }
    
    private var shadowColor: Color {
        switch mode {
        case .work:
            return Color.workMode.opacity(0.3)
        case .shortBreak:
            return Color.shortBreakMode.opacity(0.3)
        case .longBreak:
            return Color.longBreakMode.opacity(0.3)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        MinimalModeSelector(
            timerEngine: TimerEngine(
                settingsStore: SettingsStore(),
                statsStore: StatsStore()
            ),
            isDisabled: false
        )
        
        MinimalModeSelector(
            timerEngine: TimerEngine(
                settingsStore: SettingsStore(),
                statsStore: StatsStore()
            ),
            isDisabled: true
        )
    }
    .padding()
    .background(Color.surfaceSecondary)
}

