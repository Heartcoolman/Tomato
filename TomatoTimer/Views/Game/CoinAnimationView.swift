//
//  CoinAnimationView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct CoinAnimationView: View {
    let amount: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0
    var onComplete: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.yellow)
            
            Text("+\(amount)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.orange)
                .shadow(color: .orange.opacity(0.5), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(scale)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                offset = -100
                opacity = 0
                scale = 1.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
        }
    }
}

struct FloatingCoinsEffect: View {
    let count: Int
    @State private var coins: [CoinParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(coins) { coin in
                CoinParticle(particle: coin)
            }
        }
        .onAppear {
            generateCoins()
        }
    }
    
    private func generateCoins() {
        coins = (0..<count).map { index in
            CoinParticle(
                id: UUID(),
                offset: CGSize(
                    width: CGFloat.random(in: -50...50),
                    height: CGFloat.random(in: -80...(-30))
                ),
                rotation: Double.random(in: 0...360),
                delay: Double(index) * 0.1
            )
        }
    }
}

struct CoinParticle: View, Identifiable {
    let id: UUID
    let offset: CGSize
    let rotation: Double
    let delay: Double
    
    @State private var currentOffset: CGSize = .zero
    @State private var currentRotation: Double = 0
    @State private var opacity: Double = 1.0
    
    init(particle: CoinParticle) {
        self.id = particle.id
        self.offset = particle.offset
        self.rotation = particle.rotation
        self.delay = particle.delay
    }
    
    init(id: UUID, offset: CGSize, rotation: Double, delay: Double) {
        self.id = id
        self.offset = offset
        self.rotation = rotation
        self.delay = delay
    }
    
    var body: some View {
        Image(systemName: "dollarsign.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.yellow)
            .offset(currentOffset)
            .rotationEffect(.degrees(currentRotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 0.8)
                    .delay(delay)
                ) {
                    currentOffset = offset
                    currentRotation = rotation
                    opacity = 0
                }
            }
    }
}

#Preview {
    ZStack {
        Color.lightYellow.ignoresSafeArea()
        
        VStack(spacing: 40) {
            CoinAnimationView(amount: 10)
            FloatingCoinsEffect(count: 5)
        }
    }
}

