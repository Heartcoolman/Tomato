//
//  PetStore.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI
import Combine

@MainActor
class PetStore: ObservableObject {
    // MARK: - Published Properties
    @Published var currentPet: VirtualPet? = nil
    @Published var showLevelUp: Bool = false
    @Published var showEvolution: Bool = false
    @Published var showCelebration: Bool = false
    
    // MARK: - Private Properties
    private let petKey = "currentPet"
    private var updateTimer: AnyCancellable?
    private let hungerIncreasePerHour: Double = 5.0
    private let happinessDecreasePerTwoHours: Double = 3.0
    
    // MARK: - Initialization
    init() {
        loadPet()
        startAutoUpdate()
    }
    
    // MARK: - Pet Management
    func createPet(type: PetType, name: String) {
        let pet = VirtualPet(type: type, name: name)
        currentPet = pet
        savePet()
    }
    
    func hasPet() -> Bool {
        return currentPet != nil
    }
    
    // MARK: - Status Updates
    private func startAutoUpdate() {
        // 每分钟更新一次宠物状态
        updateTimer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePetStatus()
            }
    }
    
    func updatePetStatus() {
        guard var pet = currentPet else { return }
        
        let now = Date()
        let timeElapsed = now.timeIntervalSince(pet.lastUpdateTime)
        let hoursElapsed = timeElapsed / 3600.0
        
        // 更新饥饿度
        let hungerIncrease = hungerIncreasePerHour * hoursElapsed * pet.hungerRateMultiplier
        pet.hunger = min(100, pet.hunger + hungerIncrease)
        
        // 更新快乐度
        if hoursElapsed >= 2 {
            let happinessDecrease = happinessDecreasePerTwoHours * (hoursElapsed / 2.0)
            pet.happiness = max(0, pet.happiness - happinessDecrease)
        }
        
        // 饥饿影响健康
        if pet.hunger > 80 {
            let healthDecrease = 2.0 * hoursElapsed
            pet.health = max(0, pet.health - healthDecrease)
        }
        
        // 饥饿影响快乐
        if pet.hunger > 70 {
            let happinessDecrease = 1.0 * hoursElapsed
            pet.happiness = max(0, pet.happiness - happinessDecrease)
        }
        
        // 自动恢复精力（如果有技能）
        if pet.hasAutoEnergyRestore {
            let energyRestore = 5.0 * hoursElapsed
            pet.energy = min(100, pet.energy + energyRestore)
        }
        
        // 健康恢复（如果条件好）
        if pet.health < 100 && pet.hunger < 50 && pet.happiness > 60 {
            let healthRestore = 1.0 * hoursElapsed
            pet.health = min(100, pet.health + healthRestore)
        }
        
        // 更新年龄
        let calendar = Calendar.current
        let daysElapsed = calendar.dateComponents([.day], from: pet.createdAt, to: now).day ?? 0
        pet.age = daysElapsed
        
        pet.lastUpdateTime = now
        currentPet = pet
        savePet()
    }
    
    // MARK: - Interactions
    func feedPet(gameStore: GameStore) -> Bool {
        guard var pet = currentPet else { return false }
        
        let cost = 15
        guard gameStore.spendCoins(amount: cost, reason: .feedPet, description: "喂养\(pet.name)") else {
            return false
        }
        
        pet.hunger = max(0, pet.hunger - 30)
        pet.happiness = min(100, pet.happiness + 5)
        pet.lastFeedTime = Date()
        
        addExperience(amount: 5)
        
        currentPet = pet
        savePet()
        return true
    }
    
    func playWithPet(gameStore: GameStore) -> Bool {
        guard var pet = currentPet else { return false }
        
        let cost = 10
        guard gameStore.spendCoins(amount: cost, reason: .buyItem, description: "与\(pet.name)玩耍") else {
            return false
        }
        
        pet.happiness = min(100, pet.happiness + 15)
        pet.energy = max(0, pet.energy - 10)
        pet.lastPlayTime = Date()
        
        addExperience(amount: 5)
        
        currentPet = pet
        savePet()
        return true
    }
    
    func patPet() -> Bool {
        guard var pet = currentPet else { return false }
        
        // 检查冷却时间（5分钟）
        if let lastPat = pet.lastPatTime {
            let elapsed = Date().timeIntervalSince(lastPat)
            if elapsed < 300 {
                return false
            }
        }
        
        pet.happiness = min(100, pet.happiness + 3)
        pet.lastPatTime = Date()
        
        currentPet = pet
        savePet()
        return true
    }
    
    func healPet(gameStore: GameStore) -> Bool {
        guard var pet = currentPet else { return false }
        
        let cost = 50
        guard gameStore.spendCoins(amount: cost, reason: .heal, description: "治疗\(pet.name)") else {
            return false
        }
        
        pet.health = min(100, pet.health + 50)
        
        currentPet = pet
        savePet()
        return true
    }
    
    // MARK: - Experience & Leveling
    func addExperience(amount: Int) {
        guard var pet = currentPet else { return }
        
        pet.experience += amount
        
        // 检查升级
        while pet.experience >= pet.expToNextLevel && pet.level < 100 {
            pet.experience -= pet.expToNextLevel
            pet.level += 1
            
            showLevelUp = true
            
            // 检查新技能解锁（直接在本地副本上操作）
            unlockSkillsForLevel(&pet, level: pet.level)
            
            // 检查进化
            let newStage = EvolutionStage.fromLevel(pet.level)
            if newStage != pet.evolutionStage {
                pet.evolutionStage = newStage
                showEvolution = true
            }
        }
        
        currentPet = pet
        savePet()
    }
    
    private func unlockSkillsForLevel(_ pet: inout VirtualPet, level: Int) {
        // 直接修改传入的pet引用，避免数据覆盖问题
        for skill in PetSkill.allSkills {
            if skill.unlockLevel == level && !pet.unlockedSkills.contains(skill.id) {
                pet.unlockedSkills.append(skill.id)
            }
        }
    }
    
    func dismissLevelUp() {
        showLevelUp = false
    }
    
    func dismissEvolution() {
        showEvolution = false
    }
    
    func dismissCelebration() {
        showCelebration = false
    }
    
    func triggerCelebration() {
        guard let pet = currentPet else { return }
        if pet.hasCelebrationSkill {
            showCelebration = true
        }
    }
    
    // MARK: - Pet Appearance
    func purchaseSkin(skinId: String, cost: Int, gameStore: GameStore) -> Bool {
        guard var pet = currentPet else { return false }
        
        guard gameStore.spendCoins(amount: cost, reason: .buyItem, description: "购买皮肤:\(skinId)") else {
            return false
        }
        
        pet.appearance.skinId = skinId
        currentPet = pet
        savePet()
        return true
    }
    
    // MARK: - Persistence
    private func savePet() {
        guard let pet = currentPet else { return }
        
        if let encoded = try? JSONEncoder().encode(pet) {
            UserDefaults.standard.set(encoded, forKey: petKey)
        }
    }
    
    private func loadPet() {
        guard let data = UserDefaults.standard.data(forKey: petKey),
              let pet = try? JSONDecoder().decode(VirtualPet.self, from: data) else {
            return
        }
        
        currentPet = pet
        updatePetStatus()
    }
    
    // MARK: - Debug/Reset
    func resetPet() {
        currentPet = nil
        UserDefaults.standard.removeObject(forKey: petKey)
    }
}

