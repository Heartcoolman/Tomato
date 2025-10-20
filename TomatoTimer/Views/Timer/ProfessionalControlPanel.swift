//
//  ProfessionalControlPanel.swift
//  TomatoTimer
//
//  Professional timer control panel
//

import SwiftUI

struct ProfessionalControlPanel: View {
    @ObservedObject var timerEngine: TimerEngine
    @ObservedObject var settingsStore: SettingsStore
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Primary controls
            primaryControls
            
            // Secondary controls (when timer is active)
            if timerEngine.state != .idle {
                secondaryControls
                    .transition(DesignTokens.Transition.fluid)
            }
        }
    }
    
    // MARK: - Primary Controls
    
    private var primaryControls: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Start/Pause button
            ProfessionalButton(
                icon: timerEngine.state == .running ? "pause.fill" : "play.fill",
                title: timerEngine.state == .running ? "Pause" : "Start",
                style: .primary,
                isActive: timerEngine.state == .running
            ) {
                if timerEngine.state == .running {
                    timerEngine.pause()
                } else {
                    timerEngine.start()
                }
                
                if settingsStore.hapticsEnabled {
                    HapticManager.shared.playImpact()
                }
            }
            .keyboardShortcut(.space, modifiers: [])
            
            // Reset button
            ProfessionalButton(
                icon: "arrow.counterclockwise",
                title: "Reset",
                style: .secondary
            ) {
                timerEngine.reset()
                
                if settingsStore.hapticsEnabled {
                    HapticManager.shared.playSelection()
                }
            }
            .keyboardShortcut("r", modifiers: [])
        }
    }
    
    // MARK: - Secondary Controls
    
    private var secondaryControls: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Add 5 minutes
            ProfessionalButton(
                icon: "plus.circle",
                title: "+5 min",
                style: .tertiary,
                compact: true
            ) {
                timerEngine.addFiveMinutes()
                
                if settingsStore.hapticsEnabled {
                    HapticManager.shared.playSelection()
                }
            }
            
            // Skip
            ProfessionalButton(
                icon: "forward.end.fill",
                title: "Skip",
                style: .tertiary,
                compact: true
            ) {
                timerEngine.skipToNext()
                
                if settingsStore.hapticsEnabled {
                    HapticManager.shared.playSelection()
                }
            }
            .keyboardShortcut("n", modifiers: [])
        }
    }
}

// MARK: - Professional Button

enum ProfessionalButtonStyle {
    case primary
    case secondary
    case tertiary
}

struct ProfessionalButton: View {
    let icon: String
    let title: String
    let style: ProfessionalButtonStyle
    let compact: Bool
    let isActive: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    init(
        icon: String,
        title: String,
        style: ProfessionalButtonStyle,
        compact: Bool = false,
        isActive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.style = style
        self.compact = compact
        self.isActive = isActive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(
                        size: compact ? 16 : 18,
                        weight: .semibold
                    ))
                
                Text(title)
                    .font(.system(
                        size: compact ? 14 : 16,
                        weight: .semibold
                    ))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: compact ? nil : .infinity)
            .padding(.vertical, compact ? 12 : 16)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .scaleEffect(isPressed ? 0.97 : (isHovered ? 1.02 : 1.0))
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: isPressed ? 2 : 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.professionalFast) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.professionalFast) {
                        isPressed = false
                    }
                }
        )
        .onHover { hovering in
            withAnimation(.hover) {
                isHovered = hovering
            }
        }
    }
    
    // MARK: - Styling
    
    private var background: some View {
        Group {
            switch style {
            case .primary:
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button)
                    .fill(
                        isActive ?
                        Color.primaryGradient :
                        LinearGradient(
                            colors: [Color.primary, Color.primaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            case .secondary:
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button)
                    .fill(.ultraThinMaterial)
            case .tertiary:
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.button)
                    .fill(Color.surfacePrimary)
            }
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .tertiary:
            return .neutralGray
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary:
            return .clear
        case .secondary:
            return Color.glassBorder
        case .tertiary:
            return Color.neutralSuperLight
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary:
            return 0
        case .secondary:
            return 0.5
        case .tertiary:
            return 1
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return Color.primary.opacity(0.3)
        case .secondary, .tertiary:
            return DesignTokens.Shadow.small.color
        }
    }
    
    private var shadowRadius: CGFloat {
        isPressed ? 4 : 8
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        ProfessionalControlPanel(
            timerEngine: TimerEngine(
                settingsStore: SettingsStore(),
                statsStore: StatsStore()
            ),
            settingsStore: SettingsStore()
        )
        
        HStack(spacing: 16) {
            ProfessionalButton(
                icon: "play.fill",
                title: "Start",
                style: .primary
            ) {}
            
            ProfessionalButton(
                icon: "pause.fill",
                title: "Pause",
                style: .secondary
            ) {}
        }
    }
    .padding()
    .background(Color.surfaceSecondary)
}

