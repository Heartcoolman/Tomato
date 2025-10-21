//
//  AchievementView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct AchievementView: View {
    @ObservedObject var gameStore: GameStore
    @State private var selectedFilter: AchievementFilter = .all
    
    enum AchievementFilter: String, CaseIterable {
        case all = "全部"
        case unlocked = "已解锁"
        case locked = "未解锁"
    }
    
    var filteredAchievements: [Achievement] {
        switch selectedFilter {
        case .all:
            return gameStore.achievements
        case .unlocked:
            return gameStore.unlockedAchievements
        case .locked:
            return gameStore.lockedAchievements
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 统计卡片
                statsCard
                
                // 筛选器
                filterPicker
                
                // 成就网格
                achievementGrid
            }
            .padding()
        }
        .background(Color.lightYellow.ignoresSafeArea())
    }
    
    private var statsCard: some View {
        HStack(spacing: 20) {
            StatItem(
                icon: "trophy.fill",
                title: "已解锁",
                value: "\(gameStore.unlockedAchievements.count)",
                color: .yellow
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                icon: "lock.fill",
                title: "未解锁",
                value: "\(gameStore.lockedAchievements.count)",
                color: .gray
            )
            
            Divider()
                .frame(height: 40)
            
            StatItem(
                icon: "percent",
                title: "完成度",
                value: "\(completionPercentage)%",
                color: .tomatoRed
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var completionPercentage: Int {
        guard !gameStore.achievements.isEmpty else { return 0 }
        return Int(Double(gameStore.unlockedAchievements.count) / Double(gameStore.achievements.count) * 100)
    }
    
    private var filterPicker: some View {
        Picker("筛选", selection: $selectedFilter) {
            ForEach(AchievementFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var achievementGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(filteredAchievements) { achievement in
                AchievementCardView(achievement: achievement)
            }
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.darkGray)
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.darkGray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        AchievementView(gameStore: GameStore())
            .navigationTitle("成就")
    }
}

