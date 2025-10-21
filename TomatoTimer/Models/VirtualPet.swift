//
//  VirtualPet.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

struct VirtualPet: Codable {
    var id: UUID
    var type: PetType
    var name: String
    var level: Int  // 1-100级
    var experience: Int
    var happiness: Double  // 0-100 快乐度
    var hunger: Double  // 0-100 饥饿度（值越高越饿）
    var health: Double  // 0-100 健康度
    var energy: Double  // 0-100 精力
    var age: Int  // 天数
    var createdAt: Date
    var lastFeedTime: Date?
    var lastPlayTime: Date?
    var lastPatTime: Date?
    var lastUpdateTime: Date
    var evolutionStage: EvolutionStage
    var unlockedSkills: [String]  // 已解锁技能ID列表
    var appearance: PetAppearance
    
    init(
        id: UUID = UUID(),
        type: PetType,
        name: String,
        level: Int = 1,
        experience: Int = 0
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.level = level
        self.experience = experience
        self.happiness = 80.0
        self.hunger = 20.0
        self.health = 100.0
        self.energy = 100.0
        self.age = 0
        self.createdAt = Date()
        self.lastUpdateTime = Date()
        self.evolutionStage = .baby
        self.unlockedSkills = []
        self.appearance = PetAppearance()
    }
    
    var expToNextLevel: Int {
        return level * 100
    }
    
    var isSick: Bool {
        return health < 20
    }
    
    var isHungry: Bool {
        return hunger > 70
    }
    
    var isTired: Bool {
        return energy < 30
    }
    
    var mood: PetMood {
        if isSick {
            return .sick
        } else if hunger > 80 {
            return .starving
        } else if happiness > 80 {
            return .happy
        } else if happiness < 30 {
            return .sad
        } else if energy < 20 {
            return .sleepy
        } else {
            return .normal
        }
    }
    
    var activeSkills: [PetSkill] {
        return PetSkill.allSkills.filter { unlockedSkills.contains($0.id) }
    }
    
    var coinBonusMultiplier: Double {
        let bonusSkills = activeSkills.filter {
            if case .coinBonus = $0.effect {
                return true
            }
            return false
        }
        
        var totalBonus = 1.0
        for skill in bonusSkills {
            if case .coinBonus(let bonus) = skill.effect {
                totalBonus += bonus
            }
        }
        return totalBonus
    }
    
    var hungerRateMultiplier: Double {
        let hungerSkills = activeSkills.filter {
            if case .hungerReduction = $0.effect {
                return true
            }
            return false
        }
        
        var totalReduction = 1.0
        for skill in hungerSkills {
            if case .hungerReduction(let reduction) = skill.effect {
                totalReduction -= reduction
            }
        }
        return max(0.1, totalReduction)
    }
    
    var hasAutoEnergyRestore: Bool {
        return activeSkills.contains { skill in
            if case .autoEnergyRestore = skill.effect {
                return true
            }
            return false
        }
    }
    
    var hasCelebrationSkill: Bool {
        return activeSkills.contains { skill in
            if case .celebration = skill.effect {
                return true
            }
            return false
        }
    }
}

enum PetMood: String {
    case happy = "开心"
    case normal = "正常"
    case sad = "难过"
    case hungry = "饥饿"
    case starving = "非常饿"
    case sick = "生病"
    case sleepy = "困倦"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .normal: return "😐"
        case .sad: return "😢"
        case .hungry: return "😋"
        case .starving: return "😫"
        case .sick: return "🤒"
        case .sleepy: return "😴"
        }
    }
}

