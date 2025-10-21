//
//  PetDetailView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct PetDetailView: View {
    let pet: VirtualPet
    @ObservedObject var petStore: PetStore
    @ObservedObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 宠物信息卡
                    petInfoCard
                    
                    // 技能列表
                    skillsSection
                    
                    // 详细属性
                    detailedStats
                }
                .padding()
            }
            .background(Color.lightYellow.ignoresSafeArea())
            .navigationTitle(pet.name)
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
    
    private var petInfoCard: some View {
        VStack(spacing: 16) {
            PetAnimationView(pet: pet, size: 150)
            
            VStack(spacing: 8) {
                Text(pet.type.rawValue)
                    .font(.title3.bold())
                    .foregroundColor(.darkGray)
                
                HStack(spacing: 16) {
                    Label("Lv.\(pet.level)", systemImage: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(.tomatoRed)
                    
                    Label("\(pet.age)天", systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // 进化阶段
            HStack(spacing: 8) {
                ForEach(0..<4) { stage in
                    evolutionStageIndicator(stage: stage, currentStage: pet.evolutionStage.rawValue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
    
    private func evolutionStageIndicator(stage: Int, currentStage: Int) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(stage <= currentStage ? pet.type.color : Color.gray.opacity(0.3))
                .frame(width: 12, height: 12)
            
            if let evolutionStage = EvolutionStage(rawValue: stage) {
                Text(evolutionStage.displayName)
                    .font(.caption2)
                    .foregroundColor(stage <= currentStage ? .darkGray : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("技能")
                .font(.headline)
                .foregroundColor(.darkGray)
            
            if pet.activeSkills.isEmpty {
                emptySkillsView
            } else {
                ForEach(pet.activeSkills) { skill in
                    SkillCard(skill: skill)
                }
            }
            
            // 未解锁技能预览
            let upcomingSkills = PetSkill.allSkills.filter { skill in
                skill.unlockLevel > pet.level && skill.unlockLevel <= pet.level + 10
            }
            
            if !upcomingSkills.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("即将解锁")
                        .font(.subheadline.bold())
                        .foregroundColor(.darkGray.opacity(0.7))
                    
                    ForEach(upcomingSkills) { skill in
                        UpcomingSkillCard(skill: skill)
                    }
                }
            }
        }
    }
    
    private var emptySkillsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无技能")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("宠物升级后会解锁新技能")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
    
    private var detailedStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("详细属性")
                .font(.headline)
                .foregroundColor(.darkGray)
            
            VStack(spacing: 8) {
                DetailStatRow(title: "健康度", value: "\(Int(pet.health))%")
                DetailStatRow(title: "快乐度", value: "\(Int(pet.happiness))%")
                DetailStatRow(title: "饱食度", value: "\(Int(100 - pet.hunger))%")
                DetailStatRow(title: "精力", value: "\(Int(pet.energy))%")
                DetailStatRow(title: "经验", value: "\(pet.experience)/\(pet.expToNextLevel)")
                DetailStatRow(title: "番茄币加成", value: "+\(Int((pet.coinBonusMultiplier - 1.0) * 100))%")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
        }
    }
}

struct SkillCard: View {
    let skill: PetSkill
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(skill.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.darkGray)
                
                Text(skill.description)
                    .font(.caption)
                    .foregroundColor(.darkGray.opacity(0.7))
                
                Text(skill.effect.displayText)
                    .font(.caption)
                    .foregroundColor(.tomatoRed)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct UpcomingSkillCard: View {
    let skill: PetSkill
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(skill.name)
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                Text("Lv.\(skill.unlockLevel) 解锁")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct DetailStatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.darkGray.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.darkGray)
                .monospacedDigit()
        }
    }
}

#Preview {
    PetDetailView(
        pet: VirtualPet(type: .tomatoCat, name: "测试猫"),
        petStore: PetStore(),
        gameStore: GameStore()
    )
}

