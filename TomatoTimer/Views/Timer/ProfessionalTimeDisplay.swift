//
//  ProfessionalTimeDisplay.swift
//  TomatoTimer
//
//  Professional monospaced time display
//

import SwiftUI

struct ProfessionalTimeDisplay: View {
    let timeString: String
    let remainingTime: TimeInterval
    let state: TimerState
    let mode: TimerMode
    
    @State private var glowOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var timeColor: Color = .neutralGray
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            // Time display
            Text(timeString)
                .font(DesignTokens.Typography.monoLarge)
                .foregroundColor(timeColor)
                .scaleEffect(pulseScale)
                .shadow(
                    color: timeColor.withGlow(intensity: glowOpacity),
                    radius: 20,
                    x: 0,
                    y: 0
                )
            
            // Mode label
            Text(mode.displayName)
                .font(DesignTokens.Typography.title3)
                .foregroundColor(.neutralMid)
                .opacity(DesignTokens.Opacity.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Remaining time")
        .accessibilityValue(accessibilityTimeString)
        .onAppear {
            updateAppearance()
        }
        .onChange(of: state) { _, newState in
            updateForState(newState)
        }
        .onChange(of: remainingTime) { _, newTime in
            updateTimeColor(for: newTime)
        }
    }
    
    // MARK: - Appearance Updates
    
    private func updateAppearance() {
        updateTimeColor(for: remainingTime)
        
        if state == .running && !reduceMotion {
            startPulse()
        }
    }
    
    private func updateForState(_ newState: TimerState) {
        switch newState {
        case .running:
            if !reduceMotion {
                startPulse()
            }
            
        case .completed:
            withAnimation(.celebration) {
                pulseScale = 1.1
                timeColor = modeColor
                glowOpacity = 0.6
            }
            
            // Celebration pulse
            if !reduceMotion {
                withAnimation(.celebrationBounce.repeatCount(3, autoreverses: true)) {
                    pulseScale = 1.15
                }
            }
            
        case .idle, .paused:
            stopPulse()
        }
    }
    
    private func updateTimeColor(for time: TimeInterval) {
        let minutes = Int(time) / 60
        
        withAnimation(.liquidGlass) {
            if minutes <= 1 && state == .running {
                timeColor = .error
                glowOpacity = 0.5
            } else if minutes <= 3 && state == .running {
                timeColor = .warning
                glowOpacity = 0.3
            } else {
                timeColor = modeColor
                glowOpacity = 0.2
            }
        }
    }
    
    private func startPulse() {
        withAnimation(.continuousPulse) {
            pulseScale = 1.02
            glowOpacity = 0.3
        }
    }
    
    private func stopPulse() {
        withAnimation(.liquidGlass) {
            pulseScale = 1.0
            glowOpacity = 0
        }
    }
    
    // MARK: - Helpers
    
    private var modeColor: Color {
        switch mode {
        case .work:
            return Color.workMode
        case .shortBreak:
            return Color.shortBreakMode
        case .longBreak:
            return Color.longBreakMode
        }
    }
    
    private var accessibilityTimeString: String {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        return "\(minutes) minutes and \(seconds) seconds remaining"
    }
}

// MARK: - Helper Extension

extension TimeInterval {
    var accessibilityTimeDescription: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return "\(minutes) minutes and \(seconds) seconds"
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        ProfessionalTimeDisplay(
            timeString: "25:00",
            remainingTime: 1500,
            state: .idle,
            mode: .work
        )
        
        ProfessionalTimeDisplay(
            timeString: "05:30",
            remainingTime: 330,
            state: .running,
            mode: .work
        )
        
        ProfessionalTimeDisplay(
            timeString: "00:45",
            remainingTime: 45,
            state: .running,
            mode: .work
        )
    }
    .padding()
    .background(Color.surfaceSecondary)
}

