//
//  AchievementCardView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct AchievementCardView: View {
    let achievement: Achievement
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(spacing: 12) {
                // 图标
                ZStack {
                    Circle()
                        .fill(
                            achievement.isUnlocked ?
                            LinearGradient(
                                colors: [
                                    achievement.tier.color.opacity(0.3),
                                    achievement.tier.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.2)],
                                startPoint: .center,
                                endPoint: .center
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    if achievement.isUnlocked {
                        Image(systemName: achievement.icon)
                            .font(.system(size: 32))
                            .foregroundColor(achievement.tier.color)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                
                // 标题
                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundColor(achievement.isUnlocked ? .darkGray : .gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 36)
                
                // 等级标签
                Text(achievement.tier.rawValue)
                    .font(.caption2)
                    .foregroundColor(achievement.isUnlocked ? achievement.tier.color : .gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(
                                achievement.isUnlocked ?
                                achievement.tier.color.opacity(0.2) :
                                Color.gray.opacity(0.1)
                            )
                    )
                
                // 进度条（未解锁时显示）
                if !achievement.isUnlocked && achievement.progress > 0 {
                    VStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.2))
                                
                                Capsule()
                                    .fill(Color.tomatoRed)
                                    .frame(width: geometry.size.width * achievement.progress)
                            }
                        }
                        .frame(height: 4)
                        
                        Text("\(Int(achievement.progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(
                        color: achievement.isUnlocked ?
                            achievement.tier.color.opacity(0.2) :
                            Color.black.opacity(0.05),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            AchievementDetailSheet(achievement: achievement)
        }
    }
}

struct AchievementDetailSheet: View {
    let achievement: Achievement
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 图标大展示
                ZStack {
                    Circle()
                        .fill(
                            achievement.isUnlocked ?
                            RadialGradient(
                                colors: [
                                    achievement.tier.color.opacity(0.3),
                                    achievement.tier.color.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            ) :
                            RadialGradient(
                                colors: [Color.gray.opacity(0.2)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 150, height: 150)
                    
                    if achievement.isUnlocked {
                        Image(systemName: achievement.icon)
                            .font(.system(size: 70))
                            .foregroundColor(achievement.tier.color)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
                .padding()
                
                // 标题和描述
                VStack(spacing: 12) {
                    Text(achievement.title)
                        .font(.title.bold())
                        .foregroundColor(.darkGray)
                    
                    Text(achievement.description)
                        .font(.subheadline)
                        .foregroundColor(.darkGray.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // 等级
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
                
                // 解锁条件
                VStack(spacing: 8) {
                    Text("解锁条件")
                        .font(.caption.bold())
                        .foregroundColor(.darkGray.opacity(0.6))
                    
                    Text(achievement.unlockCondition.description)
                        .font(.subheadline)
                        .foregroundColor(.darkGray)
                }
                
                // 奖励
                HStack(spacing: 8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    Text("\(achievement.reward) 番茄币")
                        .font(.headline)
                        .foregroundColor(.darkGray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                )
                
                // 解锁信息
                if achievement.isUnlocked, let unlockedAt = achievement.unlockedAt {
                    VStack(spacing: 4) {
                        Text("解锁于")
                            .font(.caption)
                            .foregroundColor(.darkGray.opacity(0.6))
                        Text(formatDate(unlockedAt))
                            .font(.subheadline)
                            .foregroundColor(.darkGray)
                    }
                } else if !achievement.isUnlocked && achievement.progress > 0 {
                    VStack(spacing: 8) {
                        Text("进度")
                            .font(.caption.bold())
                            .foregroundColor(.darkGray.opacity(0.6))
                        
                        ProgressView(value: achievement.progress)
                            .tint(.tomatoRed)
                            .frame(width: 200)
                        
                        Text("\(Int(achievement.progress * 100))%")
                            .font(.headline)
                            .foregroundColor(.tomatoRed)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.lightYellow.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 16) {
            AchievementCardView(
                achievement: Achievement(
                    id: "test1",
                    title: "初试锋芒",
                    description: "完成第1个番茄钟",
                    icon: "star.fill",
                    tier: .bronze,
                    unlockCondition: .completePomodoroCount(1),
                    reward: 20,
                    isUnlocked: true,
                    unlockedAt: Date()
                )
            )
            
            AchievementCardView(
                achievement: Achievement(
                    id: "test2",
                    title: "百炼成钢",
                    description: "完成100个番茄钟",
                    icon: "crown.fill",
                    tier: .gold,
                    unlockCondition: .completePomodoroCount(100),
                    reward: 100,
                    isUnlocked: false,
                    progress: 0.45
                )
            )
        }
    }
    .padding()
}

