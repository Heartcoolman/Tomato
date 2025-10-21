//
//  GameStore.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI

@MainActor
class GameStore: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var coinBalance: Int = 0
    @Published private(set) var totalCoinsEarned: Int = 0
    @Published private(set) var transactions: [CoinTransaction] = []
    @Published private(set) var achievements: [Achievement] = Achievement.allAchievements
    @Published private(set) var gameStats: GameStats = GameStats()
    @Published var showAchievementUnlock: Achievement? = nil
    
    // MARK: - Private Properties
    private let balanceKey = "coinBalance"
    private let totalEarnedKey = "totalCoinsEarned"
    private let transactionsKey = "coinTransactions"
    private let achievementsKey = "achievements"
    private let gameStatsKey = "gameStats"
    
    // MARK: - Initialization
    init() {
        loadData()
    }
    
    // MARK: - Coin Management
    func rewardCoins(for mode: TimerMode, petBonusMultiplier: Double = 1.0) {
        let baseAmount: Int
        switch mode {
        case .work:
            baseAmount = 10
        case .shortBreak:
            baseAmount = 3
        case .longBreak:
            baseAmount = 5
        }
        
        let finalAmount = Int(Double(baseAmount) * petBonusMultiplier)
        addCoins(amount: finalAmount, reason: .completedPomodoro, description: "完成\(mode.displayName)")
    }
    
    func rewardStreakBonus(days: Int) {
        let amount: Int
        if days == 3 {
            amount = 30
        } else if days == 7 {
            amount = 50
        } else if days == 30 {
            amount = 150
        } else if days == 100 {
            amount = 300
        } else {
            return
        }
        
        addCoins(amount: amount, reason: .streak, description: "连续打卡\(days)天奖励")
    }
    
    func addCoins(amount: Int, reason: CoinReason, description: String) {
        coinBalance += amount
        if amount > 0 {
            totalCoinsEarned += amount
        }
        
        let transaction = CoinTransaction(
            amount: amount,
            reason: reason,
            description: description
        )
        transactions.insert(transaction, at: 0)
        
        // 限制交易记录数量
        if transactions.count > 100 {
            transactions = Array(transactions.prefix(100))
        }
        
        saveData()
        
        // 检查番茄币相关成就
        checkAchievements()
    }
    
    func spendCoins(amount: Int, reason: CoinReason, description: String) -> Bool {
        guard coinBalance >= amount else {
            return false
        }
        
        addCoins(amount: -amount, reason: reason, description: description)
        return true
    }
    
    // MARK: - Achievement Management
    func checkAchievements(pomodoroCount: Int = 0, streakDays: Int = 0, totalMinutes: Int = 0, petLevel: Int = 0) {
        var newlyUnlocked: [Achievement] = []
        
        for index in achievements.indices {
            guard !achievements[index].isUnlocked else { continue }
            
            let condition = achievements[index].unlockCondition
            var currentValue = 0
            var shouldUnlock = false
            
            switch condition {
            case .completePomodoroCount(let target):
                currentValue = pomodoroCount
                shouldUnlock = pomodoroCount >= target
            case .streakDays(let target):
                currentValue = streakDays
                shouldUnlock = streakDays >= target
            case .totalMinutes(let target):
                currentValue = totalMinutes
                shouldUnlock = totalMinutes >= target
            case .levelUpPet(let target):
                currentValue = petLevel
                shouldUnlock = petLevel >= target
            case .earnCoins(let target):
                currentValue = totalCoinsEarned
                shouldUnlock = totalCoinsEarned >= target
            case .playGames(let target):
                currentValue = gameStats.totalGamesPlayed
                shouldUnlock = gameStats.totalGamesPlayed >= target
            }
            
            // 更新进度
            let targetValue = condition.targetValue
            achievements[index].progress = min(1.0, Double(currentValue) / Double(targetValue))
            
            if shouldUnlock {
                achievements[index].isUnlocked = true
                achievements[index].unlockedAt = Date()
                newlyUnlocked.append(achievements[index])
                
                // 奖励番茄币
                addCoins(
                    amount: achievements[index].reward,
                    reason: .achievement,
                    description: "解锁成就：\(achievements[index].title)"
                )
            }
        }
        
        saveData()
        
        // 显示解锁动画（一次显示一个）
        if let firstUnlocked = newlyUnlocked.first {
            showAchievementUnlock = firstUnlocked
        }
    }
    
    func dismissAchievementUnlock() {
        showAchievementUnlock = nil
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    // MARK: - Game Stats Management
    func recordGamePlay(_ record: GameRecord) -> Bool {
        gameStats.resetDailyCountsIfNeeded()
        
        // 检查是否超出每日限制
        guard gameStats.canPlayToday(record.gameType) else {
            // 已达到每日限制，不记录也不给奖励
            return false
        }
        
        gameStats.recordGame(record)
        
        addCoins(
            amount: record.coinsEarned,
            reason: .playGame,
            description: "\(record.gameType.rawValue)得分\(record.score)"
        )
        
        saveData()
        checkAchievements()
        return true
    }
    
    func canPlayGame(_ gameType: GameType) -> Bool {
        gameStats.resetDailyCountsIfNeeded()
        return gameStats.canPlayToday(gameType)
    }
    
    func remainingPlaysToday(_ gameType: GameType) -> Int {
        gameStats.resetDailyCountsIfNeeded()
        return gameStats.remainingPlaysToday(gameType)
    }
    
    // MARK: - Persistence
    private func saveData() {
        UserDefaults.standard.set(coinBalance, forKey: balanceKey)
        UserDefaults.standard.set(totalCoinsEarned, forKey: totalEarnedKey)
        
        if let transactionsData = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(transactionsData, forKey: transactionsKey)
        }
        
        if let achievementsData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(achievementsData, forKey: achievementsKey)
        }
        
        if let gameStatsData = try? JSONEncoder().encode(gameStats) {
            UserDefaults.standard.set(gameStatsData, forKey: gameStatsKey)
        }
    }
    
    private func loadData() {
        coinBalance = UserDefaults.standard.integer(forKey: balanceKey)
        totalCoinsEarned = UserDefaults.standard.integer(forKey: totalEarnedKey)
        
        if let transactionsData = UserDefaults.standard.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([CoinTransaction].self, from: transactionsData) {
            transactions = decoded
        }
        
        if let achievementsData = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
            achievements = decoded
        }
        
        if let gameStatsData = UserDefaults.standard.data(forKey: gameStatsKey),
           let decoded = try? JSONDecoder().decode(GameStats.self, from: gameStatsData) {
            gameStats = decoded
        }
    }
    
    // MARK: - Debug/Reset
    func resetAllData() {
        coinBalance = 0
        totalCoinsEarned = 0
        transactions = []
        achievements = Achievement.allAchievements
        gameStats = GameStats()
        saveData()
    }
}

