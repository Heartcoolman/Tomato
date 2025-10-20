//
//  CircularProgressView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 ~ 1.0
    let lineWidth: CGFloat = 20
    let isRunning: Bool
    
    @State private var animationProgress: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowIntensity: Double = 0.3
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    init(progress: Double, isRunning: Bool = false) {
        self.progress = progress
        self.isRunning = isRunning
    }
    
    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // 进度圆环
            Circle()
                .trim(from: 0, to: animationProgress)
                .stroke(
                    LinearGradient(
                        colors: progressGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: progressShadowColor, radius: glowRadius, x: 0, y: 0)
                .scaleEffect(pulseScale)
                .animation(
                    reduceMotion ? .none :
                    isRunning ?
                    .easeInOut(duration: 0.1).repeatForever(autoreverses: false) :
                    .spring(response: 0.8, dampingFraction: 0.8),
                    value: animationProgress
                )
                .animation(
                    reduceMotion ? .none :
                    isRunning ?
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true) :
                    .easeInOut(duration: 0.3),
                    value: pulseScale
                )
                .animation(
                    reduceMotion ? .none :
                    .easeInOut(duration: 0.5),
                    value: glowIntensity
                )
            
            // 内圈装饰
            if progress > 0 {
                Circle()
                    .trim(from: 0, to: min(0.1, animationProgress))
                    .stroke(
                        Color.white.opacity(0.8),
                        style: StrokeStyle(lineWidth: lineWidth * 0.3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 0)
            }
        }
        .onAppear {
            animationProgress = progress
            if isRunning {
                startPulseAnimation()
            }
        }
        .onChange(of: progress) { _, newProgress in
            animationProgress = newProgress
            if isRunning && newProgress > 0.9 {
                // 接近完成时增强发光效果
                glowIntensity = 0.8
            } else {
                glowIntensity = 0.3
            }
        }
        .onChange(of: isRunning) { _, newIsRunning in
            if newIsRunning {
                startPulseAnimation()
            } else {
                pulseScale = 1.0
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("计时进度")
        .accessibilityValue("\(Int(progress * 100))%")
    }
    
    private var progressGradientColors: [Color] {
        let baseColor = Color.tomatoRed
        let highlightColor = Color(red: 0.9, green: 0.3, blue: 0.3) // 更亮的红色
        
        if progress > 0.9 {
            return [highlightColor, baseColor]
        } else {
            return [baseColor, Color(red: 0.8, green: 0.2, blue: 0.2)]
        }
    }
    
    private var progressShadowColor: Color {
        if progress > 0.9 {
            return Color.tomatoRed.opacity(glowIntensity)
        } else {
            return Color.tomatoRed.opacity(glowIntensity * 0.5)
        }
    }
    
    private var glowRadius: CGFloat {
        if progress > 0.9 {
            return 8 + (glowIntensity * 4)
        } else {
            return 4 + (glowIntensity * 2)
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.02
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        CircularProgressView(progress: 0.65, isRunning: false)
            .frame(width: 300, height: 300)
        
        CircularProgressView(progress: 0.95, isRunning: true)
            .frame(width: 200, height: 200)
    }
    .padding()
    .background(Color.lightYellow)
}

