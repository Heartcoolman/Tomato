//
//  PetAnimationView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct PetAnimationView: View {
    let pet: VirtualPet
    let size: CGFloat
    
    @State private var breatheScale: CGFloat = 1.0
    @State private var bounceOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // 背景光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pet.type.color.opacity(0.3),
                            pet.type.color.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(breatheScale)
            
            // 宠物主体
            petBody
                .scaleEffect(breatheScale)
                .offset(y: bounceOffset)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private var petBody: some View {
        ZStack {
            // 主体
            Text(pet.type.emoji)
                .font(.system(size: size * 0.6))
            
            // 状态装饰
            if pet.isSick {
                sickOverlay
            } else if pet.isHungry {
                hungryOverlay
            } else if pet.mood == .happy {
                happyOverlay
            }
        }
    }
    
    private var sickOverlay: some View {
        VStack {
            Text("🤒")
                .font(.system(size: size * 0.25))
                .offset(x: size * 0.25, y: -size * 0.25)
        }
    }
    
    private var hungryOverlay: some View {
        VStack {
            Text("💭")
                .font(.system(size: size * 0.2))
            Text("🍅")
                .font(.system(size: size * 0.15))
        }
        .offset(x: size * 0.3, y: -size * 0.3)
    }
    
    private var happyOverlay: some View {
        VStack {
            ForEach(0..<3, id: \.self) { index in
                Text("✨")
                    .font(.system(size: size * 0.15))
                    .offset(
                        x: cos(Double(index) * 2 * .pi / 3) * size * 0.4,
                        y: sin(Double(index) * 2 * .pi / 3) * size * 0.4
                    )
                    .opacity(breatheScale > 1.0 ? 1.0 : 0.5)
            }
        }
    }
    
    private func startAnimations() {
        // 呼吸动画
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            breatheScale = 1.05
        }
        
        // 根据心情添加额外动画
        if pet.mood == .happy {
            // 开心时跳跃
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
            ) {
                bounceOffset = -10
            }
        } else if pet.mood == .sleepy {
            // 困倦时摇晃
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                rotation = 5
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        PetAnimationView(
            pet: VirtualPet(type: .tomatoCat, name: "测试猫"),
            size: 200
        )
        
        PetAnimationView(
            pet: VirtualPet(type: .tomatoDog, name: "测试狗"),
            size: 150
        )
    }
    .padding()
}

