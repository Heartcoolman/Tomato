//
//  AchievementUnlockView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct AchievementUnlockView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = -180
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 24) {
                // 标题
                Text("🎉 成就解锁 🎉")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                // 成就卡片
                VStack(spacing: 20) {
                    // 图标
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        achievement.tier.color.opacity(0.5),
                                        achievement.tier.color.opacity(0.0)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: achievement.icon)
                            .font(.system(size: 60))
                            .foregroundColor(achievement.tier.color)
                            .rotationEffect(.degrees(rotation))
                    }
                    
                    // 成就信息
                    VStack(spacing: 8) {
                        Text(achievement.title)
                            .font(.title2.bold())
                            .foregroundColor(.darkGray)
                        
                        Text(achievement.description)
                            .font(.subheadline)
                            .foregroundColor(.darkGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    
                    // 等级标签
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(achievement.tier.color)
                        Text(achievement.tier.rawValue)
                            .font(.headline)
                            .foregroundColor(achievement.tier.color)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(achievement.tier.color.opacity(0.2))
                    )
                    
                    // 奖励
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        
                        Text("+\(achievement.reward)")
                            .font(.title2.bold())
                            .foregroundColor(.darkGray)
                            .monospacedDigit()
                        
                        Text("番茄币")
                            .font(.subheadline)
                            .foregroundColor(.darkGray.opacity(0.7))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow.opacity(0.2))
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: achievement.tier.color.opacity(0.3), radius: 20, x: 0, y: 10)
                )
                .scaleEffect(scale)
                .opacity(opacity)
                
                // 关闭按钮
                Button(action: dismiss) {
                    Text("太棒了！")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(achievement.tier.color)
                        )
                }
                .opacity(opacity)
            }
            .padding()
            
            // 烟花效果
            if showConfetti {
                ConfettiView()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                rotation = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
                HapticManager.shared.playSuccess()
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confetti) { piece in
                Text(piece.emoji)
                    .font(.system(size: piece.size))
                    .position(piece.position)
                    .rotationEffect(.degrees(piece.rotation))
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        let emojis = ["🎉", "✨", "🎊", "⭐️", "💫", "🌟"]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        confetti = (0..<30).map { index in
            let startX = CGFloat.random(in: 0...screenWidth)
            let startY = CGFloat.random(in: -100...0)
            let endY = screenHeight + 100
            let delay = Double.random(in: 0...0.5)
            
            var piece = ConfettiPiece(
                id: UUID(),
                emoji: emojis.randomElement() ?? "✨",
                position: CGPoint(x: startX, y: startY),
                size: CGFloat.random(in: 20...40),
                rotation: 0,
                opacity: 1.0
            )
            
            withAnimation(
                .linear(duration: Double.random(in: 2...4))
                .delay(delay)
            ) {
                piece.position.y = endY
                piece.rotation = Double.random(in: 360...720)
                piece.opacity = 0
            }
            
            return piece
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    let emoji: String
    var position: CGPoint
    let size: CGFloat
    var rotation: Double
    var opacity: Double
}

#Preview {
    ZStack {
        Color.lightYellow.ignoresSafeArea()
        
        AchievementUnlockView(
            achievement: Achievement(
                id: "test",
                title: "初试锋芒",
                description: "完成第1个番茄钟",
                icon: "star.fill",
                tier: .bronze,
                unlockCondition: .completePomodoroCount(1),
                reward: 20,
                isUnlocked: true
            ),
            onDismiss: {}
        )
    }
}

