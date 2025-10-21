//
//  MiniGame.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

struct GameRecord: Codable, Identifiable {
    let id: UUID
    let gameType: GameType
    let score: Int
    let coinsEarned: Int
    let playedAt: Date
    let duration: TimeInterval
    
    init(
        id: UUID = UUID(),
        gameType: GameType,
        score: Int,
        coinsEarned: Int,
        playedAt: Date = Date(),
        duration: TimeInterval
    ) {
        self.id = id
        self.gameType = gameType
        self.score = score
        self.coinsEarned = coinsEarned
        self.playedAt = playedAt
        self.duration = duration
    }
}

enum GameType: String, Codable, CaseIterable, Identifiable {
    case fruitCatch = "番茄接水果"
    case tomato2048 = "2048番茄版"
    case memoryCard = "记忆翻牌"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .fruitCatch: return "basket.fill"
        case .tomato2048: return "square.grid.3x3.fill"
        case .memoryCard: return "square.on.square"
        }
    }
    
    var description: String {
        switch self {
        case .fruitCatch:
            return "拖动篮子接住掉落的番茄，避开炸弹！"
        case .tomato2048:
            return "经典2048玩法，合并番茄达到目标！"
        case .memoryCard:
            return "翻开匹配的番茄卡片，考验记忆力！"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .fruitCatch: return 60
        case .tomato2048: return 0  // 无时间限制
        case .memoryCard: return 90
        }
    }
    
    var coinFormula: (Int) -> Int {
        switch self {
        case .fruitCatch:
            return { score in score / 10 }  // 得分÷10
        case .tomato2048:
            return { score in score >= 2048 ? 100 : score / 50 }
        case .memoryCard:
            return { score in score * 5 }  // 每对×5
        }
    }
    
    var dailyLimit: Int {
        return 5  // 每个游戏每天最多玩5次
    }
}

struct GameStats: Codable {
    var totalGamesPlayed: Int
    var gamePlayCounts: [String: Int]  // GameType.rawValue -> count
    var highScores: [String: Int]  // GameType.rawValue -> high score
    var lastPlayDates: [String: Date]  // GameType.rawValue -> last play date
    var dailyPlayCounts: [String: Int]  // GameType.rawValue -> today's count
    var lastResetDate: Date
    
    init() {
        self.totalGamesPlayed = 0
        self.gamePlayCounts = [:]
        self.highScores = [:]
        self.lastPlayDates = [:]
        self.dailyPlayCounts = [:]
        self.lastResetDate = Date()
    }
    
    mutating func recordGame(_ record: GameRecord) {
        totalGamesPlayed += 1
        
        let gameKey = record.gameType.rawValue
        gamePlayCounts[gameKey, default: 0] += 1
        dailyPlayCounts[gameKey, default: 0] += 1
        lastPlayDates[gameKey] = record.playedAt
        
        if record.score > (highScores[gameKey] ?? 0) {
            highScores[gameKey] = record.score
        }
    }
    
    mutating func resetDailyCountsIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastResetDate) {
            dailyPlayCounts = [:]
            lastResetDate = Date()
        }
    }
    
    func canPlayToday(_ gameType: GameType) -> Bool {
        let count = dailyPlayCounts[gameType.rawValue] ?? 0
        return count < gameType.dailyLimit
    }
    
    func remainingPlaysToday(_ gameType: GameType) -> Int {
        let count = dailyPlayCounts[gameType.rawValue] ?? 0
        return max(0, gameType.dailyLimit - count)
    }
}

