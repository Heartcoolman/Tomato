//
//  TomatoCoin.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

struct CoinTransaction: Codable, Identifiable {
    let id: UUID
    let date: Date
    let amount: Int  // 正数为收入，负数为支出
    let reason: CoinReason
    let description: String
    
    init(id: UUID = UUID(), date: Date = Date(), amount: Int, reason: CoinReason, description: String) {
        self.id = id
        self.date = date
        self.amount = amount
        self.reason = reason
        self.description = description
    }
}

enum CoinReason: String, Codable {
    case completedPomodoro = "完成番茄钟"
    case streak = "连续打卡奖励"
    case achievement = "成就解锁"
    case feedPet = "喂养宠物"
    case buyItem = "购买道具"
    case playGame = "游戏奖励"
    case pat = "抚摸宠物"
    case heal = "治疗宠物"
}

