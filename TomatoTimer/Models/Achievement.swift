//
//  Achievement.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let tier: AchievementTier
    let unlockCondition: UnlockCondition
    let reward: Int  // 番茄币奖励
    var isUnlocked: Bool
    var unlockedAt: Date?
    var progress: Double  // 0-1
    
    init(
        id: String,
        title: String,
        description: String,
        icon: String,
        tier: AchievementTier,
        unlockCondition: UnlockCondition,
        reward: Int,
        isUnlocked: Bool = false,
        unlockedAt: Date? = nil,
        progress: Double = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.tier = tier
        self.unlockCondition = unlockCondition
        self.reward = reward
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.progress = progress
    }
}

enum AchievementTier: String, Codable {
    case bronze = "青铜"
    case silver = "白银"
    case gold = "金"
    case platinum = "铂金"
    case diamond = "钻石"
    
    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.9, green: 0.9, blue: 0.98)
        case .diamond: return Color(red: 0.7, green: 0.9, blue: 1.0)
        }
    }
}

enum UnlockCondition: Codable, Equatable {
    case completePomodoroCount(Int)
    case streakDays(Int)
    case totalMinutes(Int)
    case levelUpPet(Int)
    case earnCoins(Int)
    case playGames(Int)
    
    var description: String {
        switch self {
        case .completePomodoroCount(let count):
            return "完成\(count)个番茄钟"
        case .streakDays(let days):
            return "连续打卡\(days)天"
        case .totalMinutes(let minutes):
            return "累计工作\(minutes)分钟"
        case .levelUpPet(let level):
            return "宠物达到\(level)级"
        case .earnCoins(let coins):
            return "累计赚取\(coins)番茄币"
        case .playGames(let count):
            return "玩\(count)次小游戏"
        }
    }
    
    var targetValue: Int {
        switch self {
        case .completePomodoroCount(let count): return count
        case .streakDays(let days): return days
        case .totalMinutes(let minutes): return minutes
        case .levelUpPet(let level): return level
        case .earnCoins(let coins): return coins
        case .playGames(let count): return count
        }
    }
}

extension Achievement {
    static let allAchievements: [Achievement] = [
        // 番茄钟完成成就
        Achievement(
            id: "first_blood",
            title: "初试锋芒",
            description: "完成第1个番茄钟",
            icon: "star.fill",
            tier: .bronze,
            unlockCondition: .completePomodoroCount(1),
            reward: 20
        ),
        Achievement(
            id: "getting_started",
            title: "渐入佳境",
            description: "完成10个番茄钟",
            icon: "flame.fill",
            tier: .bronze,
            unlockCondition: .completePomodoroCount(10),
            reward: 50
        ),
        Achievement(
            id: "half_century",
            title: "半百勇士",
            description: "完成50个番茄钟",
            icon: "bolt.fill",
            tier: .silver,
            unlockCondition: .completePomodoroCount(50),
            reward: 80
        ),
        Achievement(
            id: "century",
            title: "百炼成钢",
            description: "完成100个番茄钟",
            icon: "crown.fill",
            tier: .gold,
            unlockCondition: .completePomodoroCount(100),
            reward: 100
        ),
        Achievement(
            id: "master",
            title: "时间大师",
            description: "完成500个番茄钟",
            icon: "sparkles",
            tier: .platinum,
            unlockCondition: .completePomodoroCount(500),
            reward: 200
        ),
        Achievement(
            id: "legend",
            title: "传奇人物",
            description: "完成1000个番茄钟",
            icon: "diamond.fill",
            tier: .diamond,
            unlockCondition: .completePomodoroCount(1000),
            reward: 500
        ),
        
        // 连续打卡成就
        Achievement(
            id: "three_days",
            title: "三日之约",
            description: "连续打卡3天",
            icon: "calendar",
            tier: .bronze,
            unlockCondition: .streakDays(3),
            reward: 30
        ),
        Achievement(
            id: "week_warrior",
            title: "周战士",
            description: "连续打卡7天",
            icon: "flag.fill",
            tier: .silver,
            unlockCondition: .streakDays(7),
            reward: 50
        ),
        Achievement(
            id: "month_master",
            title: "月度冠军",
            description: "连续打卡30天",
            icon: "trophy.fill",
            tier: .gold,
            unlockCondition: .streakDays(30),
            reward: 150
        ),
        Achievement(
            id: "persistent",
            title: "坚持不懈",
            description: "连续打卡100天",
            icon: "medal.fill",
            tier: .platinum,
            unlockCondition: .streakDays(100),
            reward: 300
        ),
        
        // 总时长成就
        Achievement(
            id: "ten_hours",
            title: "十小时修炼",
            description: "累计工作600分钟",
            icon: "clock.fill",
            tier: .bronze,
            unlockCondition: .totalMinutes(600),
            reward: 40
        ),
        Achievement(
            id: "hundred_hours",
            title: "百小时大师",
            description: "累计工作6000分钟",
            icon: "hourglass",
            tier: .gold,
            unlockCondition: .totalMinutes(6000),
            reward: 120
        ),
        
        // 宠物等级成就
        Achievement(
            id: "pet_level_10",
            title: "初级训练师",
            description: "宠物达到10级",
            icon: "pawprint.fill",
            tier: .bronze,
            unlockCondition: .levelUpPet(10),
            reward: 50
        ),
        Achievement(
            id: "pet_level_30",
            title: "中级训练师",
            description: "宠物达到30级",
            icon: "hare.fill",
            tier: .silver,
            unlockCondition: .levelUpPet(30),
            reward: 100
        ),
        Achievement(
            id: "pet_level_50",
            title: "高级训练师",
            description: "宠物达到50级",
            icon: "bird.fill",
            tier: .gold,
            unlockCondition: .levelUpPet(50),
            reward: 150
        ),
        Achievement(
            id: "pet_max_level",
            title: "终极训练师",
            description: "宠物达到100级",
            icon: "tortoise.fill",
            tier: .diamond,
            unlockCondition: .levelUpPet(100),
            reward: 500
        ),
        
        // 番茄币成就
        Achievement(
            id: "first_hundred_coins",
            title: "小富翁",
            description: "累计赚取100番茄币",
            icon: "dollarsign.circle.fill",
            tier: .bronze,
            unlockCondition: .earnCoins(100),
            reward: 20
        ),
        Achievement(
            id: "thousand_coins",
            title: "富商",
            description: "累计赚取1000番茄币",
            icon: "banknote.fill",
            tier: .silver,
            unlockCondition: .earnCoins(1000),
            reward: 50
        ),
        Achievement(
            id: "ten_thousand_coins",
            title: "富甲一方",
            description: "累计赚取10000番茄币",
            icon: "creditcard.fill",
            tier: .platinum,
            unlockCondition: .earnCoins(10000),
            reward: 200
        ),
        
        // 游戏成就
        Achievement(
            id: "first_game",
            title: "游戏新手",
            description: "玩1次小游戏",
            icon: "gamecontroller.fill",
            tier: .bronze,
            unlockCondition: .playGames(1),
            reward: 10
        ),
        Achievement(
            id: "game_enthusiast",
            title: "游戏爱好者",
            description: "玩20次小游戏",
            icon: "arcade.stick",
            tier: .silver,
            unlockCondition: .playGames(20),
            reward: 40
        ),
        Achievement(
            id: "game_master",
            title: "游戏大师",
            description: "玩100次小游戏",
            icon: "arcade.stick.console.fill",
            tier: .gold,
            unlockCondition: .playGames(100),
            reward: 100
        )
    ]
}

