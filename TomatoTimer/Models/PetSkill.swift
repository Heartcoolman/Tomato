//
//  PetSkill.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

struct PetSkill: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let effect: SkillEffect
    let unlockLevel: Int
    
    var isPassive: Bool {
        switch effect {
        case .coinBonus, .hungerReduction, .autoEnergyRestore:
            return true
        case .celebration, .unlockGame:
            return false
        }
    }
}

enum SkillEffect: Codable, Equatable {
    case coinBonus(Double)  // 番茄币奖励加成百分比
    case hungerReduction(Double)  // 饥饿度下降速度减少百分比
    case autoEnergyRestore  // 自动恢复精力
    case celebration  // 完成番茄钟时庆祝动画
    case unlockGame(String)  // 解锁专属小游戏
    
    var displayText: String {
        switch self {
        case .coinBonus(let percent):
            return "番茄币 +\(Int(percent * 100))%"
        case .hungerReduction(let percent):
            return "饥饿速度 -\(Int(percent * 100))%"
        case .autoEnergyRestore:
            return "自动恢复精力"
        case .celebration:
            return "完成庆祝动画"
        case .unlockGame(let gameName):
            return "解锁\(gameName)"
        }
    }
}

extension PetSkill {
    static let allSkills: [PetSkill] = [
        PetSkill(
            id: "coin_boost_1",
            name: "勤劳小帮手",
            description: "完成番茄钟时获得的番茄币增加10%",
            effect: .coinBonus(0.1),
            unlockLevel: 5
        ),
        PetSkill(
            id: "energy_restore",
            name: "活力满满",
            description: "精力自动缓慢恢复",
            effect: .autoEnergyRestore,
            unlockLevel: 15
        ),
        PetSkill(
            id: "hunger_slow",
            name: "节食专家",
            description: "饥饿度下降速度减少50%",
            effect: .hungerReduction(0.5),
            unlockLevel: 30
        ),
        PetSkill(
            id: "celebration",
            name: "欢乐庆典",
            description: "完成番茄钟时会跳舞庆祝",
            effect: .celebration,
            unlockLevel: 50
        ),
        PetSkill(
            id: "coin_boost_2",
            name: "财富大师",
            description: "完成番茄钟时获得的番茄币增加20%",
            effect: .coinBonus(0.2),
            unlockLevel: 70
        ),
        PetSkill(
            id: "unlock_special_game",
            name: "游戏达人",
            description: "解锁专属迷你游戏",
            effect: .unlockGame("番茄冒险"),
            unlockLevel: 80
        )
    ]
}

