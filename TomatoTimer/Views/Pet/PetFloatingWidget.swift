//
//  PetFloatingWidget.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct PetFloatingWidget: View {
    @ObservedObject var petStore: PetStore
    @State private var showQuickActions = false
    @State private var petScale: CGFloat = 1.0
    @State private var petRotation: Double = 0
    
    var body: some View {
        if let pet = petStore.currentPet {
            HStack(spacing: 12) {
                // 宠物小头像
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        showQuickActions.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        pet.type.color.opacity(0.3),
                                        pet.type.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Text(pet.type.emoji)
                            .font(.system(size: 32))
                            .scaleEffect(petScale)
                            .rotationEffect(.degrees(petRotation))
                        
                        // 状态指示器
                        if pet.isHungry {
                            Text("!")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.red))
                                .offset(x: 20, y: -20)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // 快速操作菜单
                if showQuickActions {
                    quickActionsMenu(pet: pet)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .padding(8)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
            .onAppear {
                startIdleAnimation()
                updatePetAnimation(pet: pet)
            }
            .onChange(of: pet.mood) { _, _ in
                updatePetAnimation(pet: pet)
            }
        }
    }
    
    private func quickActionsMenu(pet: VirtualPet) -> some View {
        HStack(spacing: 8) {
            QuickActionIcon(
                icon: "fork.knife",
                color: .green,
                value: Int(100 - pet.hunger)
            )
            
            QuickActionIcon(
                icon: "face.smiling.fill",
                color: .yellow,
                value: Int(pet.happiness)
            )
            
            QuickActionIcon(
                icon: "heart.fill",
                color: .red,
                value: Int(pet.health)
            )
        }
    }
    
    private func startIdleAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            petScale = 1.1
        }
    }
    
    private func updatePetAnimation(pet: VirtualPet) {
        if pet.mood == .happy {
            // 开心时旋转
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
            ) {
                petRotation = 10
            }
        } else if pet.isHungry {
            // 饥饿时摇晃
            withAnimation(
                .easeInOut(duration: 0.3)
                .repeatForever(autoreverses: true)
            ) {
                petRotation = -5
            }
        } else {
            petRotation = 0
        }
    }
}

struct QuickActionIcon: View {
    let icon: String
    let color: Color
    let value: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text("\(value)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.darkGray)
                .monospacedDigit()
        }
    }
}

#Preview {
    ZStack {
        Color.lightYellow.ignoresSafeArea()
        
        VStack {
            Spacer()
            HStack {
                PetFloatingWidget(petStore: {
                    let store = PetStore()
                    store.createPet(type: .tomatoCat, name: "测试猫")
                    return store
                }())
                Spacer()
            }
            .padding()
        }
    }
}

