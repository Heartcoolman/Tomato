//
//  PetView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct PetView: View {
    @ObservedObject var petStore: PetStore
    @ObservedObject var gameStore: GameStore
    @State private var showCreatePet = false
    @State private var showDetail = false
    
    var body: some View {
        ZStack {
            Color.lightYellow.ignoresSafeArea()
            
            if let pet = petStore.currentPet {
                petMainView(pet: pet)
            } else {
                noPetView
            }
        }
        .sheet(isPresented: $showCreatePet) {
            CreatePetView(petStore: petStore)
        }
        .sheet(isPresented: $showDetail) {
            if let pet = petStore.currentPet {
                PetDetailView(pet: pet, petStore: petStore, gameStore: gameStore)
            }
        }
    }
    
    private func petMainView(pet: VirtualPet) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // 宠物展示区
                petDisplayCard(pet: pet)
                
                // 状态条
                statusBars(pet: pet)
                
                // 互动按钮
                interactionButtons(pet: pet)
                
                // 快速信息
                quickInfo(pet: pet)
            }
            .padding()
        }
    }
    
    private func petDisplayCard(pet: VirtualPet) -> some View {
        VStack(spacing: 16) {
            // 宠物头像/动画
            PetAnimationView(pet: pet, size: 200)
            
            // 名字和等级
            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.title2.bold())
                    .foregroundColor(.darkGray)
                
                HStack(spacing: 8) {
                    Text("Lv.\(pet.level)")
                        .font(.headline)
                        .foregroundColor(.tomatoRed)
                    
                    Text(pet.evolutionStage.displayName)
                        .font(.subheadline)
                        .foregroundColor(.darkGray.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                        )
                }
            }
            
            // 经验条
            VStack(spacing: 4) {
                HStack {
                    Text("经验")
                        .font(.caption)
                        .foregroundColor(.darkGray.opacity(0.6))
                    Spacer()
                    Text("\(pet.experience)/\(pet.expToNextLevel)")
                        .font(.caption.bold())
                        .foregroundColor(.tomatoRed)
                        .monospacedDigit()
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.tomatoRed, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (Double(pet.experience) / Double(pet.expToNextLevel)))
                    }
                }
                .frame(height: 8)
            }
            
            // 心情显示
            HStack(spacing: 8) {
                Text(pet.mood.emoji)
                    .font(.title2)
                Text(pet.mood.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.darkGray.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.5))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .onTapGesture {
            showDetail = true
        }
    }
    
    private func statusBars(pet: VirtualPet) -> some View {
        VStack(spacing: 12) {
            StatusBar(
                icon: "heart.fill",
                title: "健康",
                value: pet.health,
                color: .red
            )
            
            StatusBar(
                icon: "face.smiling.fill",
                title: "快乐",
                value: pet.happiness,
                color: .yellow
            )
            
            StatusBar(
                icon: "fork.knife",
                title: "饱食",
                value: 100 - pet.hunger,
                color: .green
            )
            
            StatusBar(
                icon: "bolt.fill",
                title: "精力",
                value: pet.energy,
                color: .blue
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func interactionButtons(pet: VirtualPet) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                InteractionButton(
                    icon: "leaf.fill",
                    title: "喂食",
                    cost: 15,
                    color: .green
                ) {
                    let success = petStore.feedPet(gameStore: gameStore)
                    if success {
                        HapticManager.shared.playSuccess()
                    } else {
                        HapticManager.shared.playError()
                    }
                }
                
                InteractionButton(
                    icon: "gamecontroller.fill",
                    title: "玩耍",
                    cost: 10,
                    color: .blue
                ) {
                    let success = petStore.playWithPet(gameStore: gameStore)
                    if success {
                        HapticManager.shared.playSuccess()
                    } else {
                        HapticManager.shared.playError()
                    }
                }
            }
            
            HStack(spacing: 12) {
                InteractionButton(
                    icon: "hand.wave.fill",
                    title: "抚摸",
                    cost: 0,
                    color: .pink,
                    isFree: true
                ) {
                    let success = petStore.patPet()
                    if success {
                        HapticManager.shared.playSuccess()
                    } else {
                        HapticManager.shared.playError()
                    }
                }
                
                InteractionButton(
                    icon: "cross.case.fill",
                    title: "治疗",
                    cost: 50,
                    color: .red,
                    isDisabled: !pet.isSick
                ) {
                    let success = petStore.healPet(gameStore: gameStore)
                    if success {
                        HapticManager.shared.playSuccess()
                    } else {
                        HapticManager.shared.playError()
                    }
                }
            }
        }
    }
    
    private func quickInfo(pet: VirtualPet) -> some View {
        VStack(spacing: 12) {
            HStack {
                InfoItem(icon: "calendar", title: "年龄", value: "\(pet.age)天")
                Spacer()
                InfoItem(icon: "sparkles", title: "阶段", value: pet.evolutionStage.displayName)
            }
            
            HStack {
                InfoItem(icon: "star.fill", title: "技能", value: "\(pet.unlockedSkills.count)")
                Spacer()
                InfoItem(icon: "birthday.cake.fill", title: "生日", value: formatBirthday(pet.createdAt))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var noPetView: some View {
        VStack(spacing: 24) {
            Image(systemName: "pawprint.circle")
                .font(.system(size: 80))
                .foregroundColor(.tomatoRed.opacity(0.5))
            
            Text("还没有宠物")
                .font(.title2.bold())
                .foregroundColor(.darkGray)
            
            Text("领养一只可爱的番茄宠物吧！")
                .font(.subheadline)
                .foregroundColor(.darkGray.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: {
                showCreatePet = true
            }) {
                Text("领养宠物")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.tomatoRed)
                    )
            }
        }
        .padding()
    }
    
    private func formatBirthday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

struct StatusBar: View {
    let icon: String
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.darkGray)
                }
                
                Spacer()
                
                Text("\(Int(value))%")
                    .font(.subheadline.bold())
                    .foregroundColor(color)
                    .monospacedDigit()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * (value / 100.0))
                }
            }
            .frame(height: 8)
        }
    }
}

struct InteractionButton: View {
    let icon: String
    let title: String
    let cost: Int
    let color: Color
    var isFree: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(isDisabled ? Color.gray : color)
                    )
                
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.darkGray)
                
                if !isFree {
                    HStack(spacing: 2) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 10))
                        Text("\(cost)")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

struct InfoItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.tomatoRed)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.darkGray.opacity(0.6))
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundColor(.darkGray)
            }
        }
    }
}

#Preview {
    PetView(petStore: PetStore(), gameStore: GameStore())
}

