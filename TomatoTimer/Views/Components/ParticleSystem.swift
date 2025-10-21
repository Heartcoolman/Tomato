//
//  ParticleSystem.swift
//  TomatoTimer
//
//  Particle Animation System
//

import SwiftUI

/// 粒子类型
enum ParticleType {
    case star       // 星星
    case heart      // 爱心
    case coin       // 金币
    case sparkle    // 火花
    case confetti   // 彩纸
    
    var icon: String {
        switch self {
        case .star:
            return "star.fill"
        case .heart:
            return "heart.fill"
        case .coin:
            return "dollarsign.circle.fill"
        case .sparkle:
            return "sparkle"
        case .confetti:
            return "diamond.fill"
        }
    }
    
    var defaultColors: [Color] {
        switch self {
        case .star:
            return [.yellow, .orange]
        case .heart:
            return [.red, .pink]
        case .coin:
            return [.gold1, .gold2]
        case .sparkle:
            return [.white, .yellow]
        case .confetti:
            return [.modernPink1, .modernOrange1, .modernYellow1, .modernGreen1, .modernBlue1]
        }
    }
}

/// 粒子模型
struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var size: CGFloat
    var rotation: Double
    var opacity: Double
    var color: Color
    var scale: CGFloat
}

/// 粒子发射器
struct ParticleEmitter: View {
    let type: ParticleType
    let count: Int
    let origin: CGPoint
    let colors: [Color]?
    
    @State private var particles: [Particle] = []
    @State private var isActive = false
    
    init(
        type: ParticleType,
        count: Int = 20,
        origin: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
        colors: [Color]? = nil
    ) {
        self.type = type
        self.count = count
        self.origin = origin
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: type.icon)
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .rotationEffect(.degrees(particle.rotation))
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .position(particle.position)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        let particleColors = colors ?? type.defaultColors
        
        particles = (0..<count).map { index in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 100...300)
            let velocity = CGPoint(
                x: cos(angle) * speed,
                y: sin(angle) * speed
            )
            
            return Particle(
                position: origin,
                velocity: velocity,
                size: CGFloat.random(in: 16...32),
                rotation: Double.random(in: 0...360),
                opacity: 1.0,
                color: particleColors.randomElement() ?? .white,
                scale: 1.0
            )
        }
    }
    
    private func animateParticles() {
        isActive = true
        
        for index in particles.indices {
            withAnimation(.easeOut(duration: Double.random(in: 1.0...2.0))) {
                // 移动粒子
                particles[index].position = CGPoint(
                    x: origin.x + particles[index].velocity.x * 0.01,
                    y: origin.y + particles[index].velocity.y * 0.01
                )
                
                // 旋转
                particles[index].rotation += Double.random(in: 360...720)
                
                // 缩放
                particles[index].scale = CGFloat.random(in: 0.5...1.5)
                
                // 淡出
                particles[index].opacity = 0
            }
        }
    }
}

// MARK: - Burst Particle Effect

/// 爆发粒子效果（从中心向外）
struct BurstParticleEffect: View {
    let type: ParticleType
    let count: Int
    let onComplete: () -> Void
    
    @State private var particles: [Particle] = []
    
    init(
        type: ParticleType = .star,
        count: Int = 15,
        onComplete: @escaping () -> Void = {}
    ) {
        self.type = type
        self.count = count
        self.onComplete = onComplete
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Image(systemName: type.icon)
                        .font(.system(size: particle.size, weight: .bold))
                        .foregroundColor(particle.color)
                        .rotationEffect(.degrees(particle.rotation))
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .position(particle.position)
                }
            }
            .onAppear {
                generateBurstParticles(in: geometry.size)
                animateBurst()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onComplete()
                }
            }
        }
    }
    
    private func generateBurstParticles(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let particleColors = type.defaultColors
        
        particles = (0..<count).map { index in
            let angle = (Double(index) / Double(count)) * 2 * .pi
            let distance = CGFloat.random(in: 50...150)
            
            return Particle(
                position: center,
                velocity: CGPoint(
                    x: cos(angle) * distance,
                    y: sin(angle) * distance
                ),
                size: CGFloat.random(in: 20...36),
                rotation: 0,
                opacity: 1.0,
                color: particleColors.randomElement() ?? .yellow,
                scale: 0.5
            )
        }
    }
    
    private func animateBurst() {
        for index in particles.indices {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.02)) {
                particles[index].position = CGPoint(
                    x: particles[index].position.x + particles[index].velocity.x,
                    y: particles[index].position.y + particles[index].velocity.y
                )
                particles[index].scale = 1.2
                particles[index].rotation = Double.random(in: 360...720)
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                particles[index].opacity = 0
                particles[index].scale = 0.3
            }
        }
    }
}

// MARK: - Floating Particles

/// 漂浮粒子（持续动画）
struct FloatingParticles: View {
    let type: ParticleType
    let count: Int
    
    @State private var particles: [Particle] = []
    
    init(type: ParticleType = .sparkle, count: Int = 10) {
        self.type = type
        self.count = count
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Image(systemName: type.icon)
                        .font(.system(size: particle.size))
                        .foregroundColor(particle.color)
                        .rotationEffect(.degrees(particle.rotation))
                        .opacity(particle.opacity)
                        .position(particle.position)
                }
            }
            .onAppear {
                generateFloatingParticles(in: geometry.size)
                startFloatingAnimation()
            }
        }
    }
    
    private func generateFloatingParticles(in size: CGSize) {
        let particleColors = type.defaultColors
        
        particles = (0..<count).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: size.height + 50
                ),
                velocity: .zero,
                size: CGFloat.random(in: 12...24),
                rotation: Double.random(in: 0...360),
                opacity: Double.random(in: 0.3...0.7),
                color: particleColors.randomElement() ?? .white,
                scale: 1.0
            )
        }
    }
    
    private func startFloatingAnimation() {
        for index in particles.indices {
            withAnimation(
                .linear(duration: Double.random(in: 3.0...5.0))
                .repeatForever(autoreverses: false)
            ) {
                particles[index].position.y = -100
            }
            
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                particles[index].rotation += 180
            }
        }
    }
}

// MARK: - Trail Particle Effect

/// 轨迹粒子效果（跟随路径）
struct TrailParticleEffect: View {
    let from: CGPoint
    let to: CGPoint
    let type: ParticleType
    let onComplete: () -> Void
    
    @State private var progress: CGFloat = 0
    @State private var particles: [Particle] = []
    
    init(
        from: CGPoint,
        to: CGPoint,
        type: ParticleType = .sparkle,
        onComplete: @escaping () -> Void = {}
    ) {
        self.from = from
        self.to = to
        self.type = type
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Image(systemName: type.icon)
                    .font(.system(size: particle.size))
                    .foregroundColor(particle.color)
                    .opacity(particle.opacity)
                    .position(particle.position)
            }
        }
        .onAppear {
            generateTrailParticles()
            animateTrail()
        }
    }
    
    private func generateTrailParticles() {
        let particleColors = type.defaultColors
        let particleCount = 10
        
        particles = (0..<particleCount).map { index in
            let progress = CGFloat(index) / CGFloat(particleCount)
            let position = CGPoint(
                x: from.x + (to.x - from.x) * progress,
                y: from.y + (to.y - from.y) * progress
            )
            
            return Particle(
                position: from,
                velocity: .zero,
                size: CGFloat.random(in: 16...24),
                rotation: 0,
                opacity: 1.0,
                color: particleColors.randomElement() ?? .white,
                scale: 1.0
            )
        }
    }
    
    private func animateTrail() {
        for index in particles.indices {
            let delay = Double(index) * 0.05
            let progress = CGFloat(index) / CGFloat(particles.count)
            let targetPosition = CGPoint(
                x: from.x + (to.x - from.x) * progress,
                y: from.y + (to.y - from.y) * progress
            )
            
            withAnimation(.easeOut(duration: 0.8).delay(delay)) {
                particles[index].position = targetPosition
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(delay + 0.5)) {
                particles[index].opacity = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.surfaceSecondary
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            Text("粒子系统演示")
                .font(.title.bold())
            
            BurstParticleEffect(type: .star, count: 20) {
                print("Burst complete")
            }
            .frame(height: 200)
            
            FloatingParticles(type: .sparkle, count: 15)
                .frame(height: 200)
        }
    }
}

