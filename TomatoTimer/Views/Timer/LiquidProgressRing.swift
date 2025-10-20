//
//  LiquidProgressRing.swift
//  TomatoTimer
//
//  iPadOS 26 Liquid Glass Progress Ring
//  Professional timer display with fluid animations
//

import SwiftUI

struct LiquidProgressRing: View {
    let progress: Double // 0.0 ~ 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    let isRunning: Bool
    let mode: TimerMode
    
    @State private var animatedProgress: Double = 0
    @State private var glowIntensity: Double = 0.3
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    init(
        progress: Double,
        size: CGFloat = DesignTokens.Layout.timerRingSize,
        lineWidth: CGFloat = 24,
        isRunning: Bool = false,
        mode: TimerMode = .work
    ) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.isRunning = isRunning
        self.mode = mode
    }
    
    var body: some View {
        ZStack {
            // Background ring with glass effect
            backgroundRing
            
            // Progress ring with Liquid Glass effect
            progressRing
            
            // Inner highlight for depth
            innerHighlight
            
            // Glow effect
            if isRunning || progress > 0.9 {
                glowEffect
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            startAnimations()
        }
        .onChange(of: progress) { _, newProgress in
            updateProgress(to: newProgress)
        }
        .onChange(of: isRunning) { _, running in
            if running {
                startRunningAnimations()
            } else {
                stopRunningAnimations()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("计时进度")
        .accessibilityValue("已完成 \(Int(progress * 100))%")
    }
    
    // MARK: - Ring Components
    
    private var backgroundRing: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.neutralSuperLight.opacity(0.3),
                        Color.neutralSuperLight.opacity(0.15)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )
            .shadow(
                color: DesignTokens.Shadow.subtle.color,
                radius: DesignTokens.Shadow.subtle.radius,
                x: DesignTokens.Shadow.subtle.x,
                y: DesignTokens.Shadow.subtle.y
            )
    }
    
    private var progressRing: some View {
        Circle()
            .trim(from: 0, to: animatedProgress)
            .stroke(
                progressGradient,
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .rotation3DEffect(
                .degrees(reduceMotion ? 0 : rotationAngle),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(pulseScale)
    }
    
    private var innerHighlight: some View {
        Circle()
            .trim(from: 0, to: min(0.15, animatedProgress))
            .stroke(
                Color.white.opacity(0.6),
                style: StrokeStyle(
                    lineWidth: lineWidth * 0.4,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .opacity(animatedProgress > 0 ? 1 : 0)
    }
    
    private var glowEffect: some View {
        Circle()
            .trim(from: 0, to: animatedProgress)
            .stroke(
                glowGradient,
                style: StrokeStyle(
                    lineWidth: lineWidth * 1.5,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .blur(radius: 12)
            .opacity(glowIntensity)
    }
    
    // MARK: - Gradients
    
    private var progressGradient: AngularGradient {
        let colors = modeColors
        return AngularGradient(
            gradient: Gradient(colors: [
                colors[0],
                colors[1],
                colors[0].opacity(0.8),
                colors[1]
            ]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }
    
    private var glowGradient: AngularGradient {
        let colors = modeColors
        return AngularGradient(
            gradient: Gradient(colors: [
                colors[0].opacity(glowIntensity),
                colors[1].opacity(glowIntensity * 0.7),
                colors[0].opacity(glowIntensity * 0.5)
            ]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }
    
    private var modeColors: [Color] {
        switch mode {
        case .work:
            return Color.workModeGradient
        case .shortBreak:
            return Color.shortBreakModeGradient
        case .longBreak:
            return Color.longBreakModeGradient
        }
    }
    
    // MARK: - Animations
    
    private func startAnimations() {
        withAnimation(.fluidProgress) {
            animatedProgress = progress
        }
        
        if isRunning {
            startRunningAnimations()
        }
    }
    
    private func updateProgress(to newProgress: Double) {
        withAnimation(.fluidProgress) {
            animatedProgress = newProgress
        }
        
        // Enhance glow near completion
        if newProgress > 0.9 {
            withAnimation(.liquidGlass) {
                glowIntensity = 0.6
            }
        } else if glowIntensity > 0.3 {
            withAnimation(.liquidGlass) {
                glowIntensity = 0.3
            }
        }
    }
    
    private func startRunningAnimations() {
        guard !reduceMotion else { return }
        
        // Subtle pulse
        withAnimation(.continuousPulse) {
            pulseScale = 1.015
        }
        
        // Subtle rotation for depth
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotationAngle = 5
        }
        
        // Glow pulse
        withAnimation(.continuousGlow) {
            glowIntensity = 0.45
        }
    }
    
    private func stopRunningAnimations() {
        withAnimation(.liquidGlass) {
            pulseScale = 1.0
            rotationAngle = 0
            glowIntensity = 0.3
        }
    }
}

// MARK: - Preview

#Preview("Work Mode - Running") {
    VStack(spacing: 40) {
        LiquidProgressRing(
            progress: 0.65,
            isRunning: true,
            mode: .work
        )
        
        LiquidProgressRing(
            progress: 0.35,
            size: 300,
            isRunning: false,
            mode: .shortBreak
        )
    }
    .padding()
    .background(Color.surfaceSecondary)
}

#Preview("Near Completion") {
    LiquidProgressRing(
        progress: 0.95,
        isRunning: true,
        mode: .work
    )
    .padding()
    .background(Color.surfaceSecondary)
}

