//
//  FruitCatchGame.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct FruitCatchGame: View {
    @ObservedObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss
    
    @State private var score = 0
    @State private var timeRemaining = 60
    @State private var basketPosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var fallingItems: [FallingItem] = []
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var timer: Timer? = nil
    @State private var spawnTimer: Timer? = nil
    
    let basketWidth: CGFloat = 80
    let itemSize: CGFloat = 40
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightYellow.ignoresSafeArea()
                
                if !gameStarted {
                    startScreen
                } else if gameOver {
                    gameOverScreen
                } else {
                    gameScreen
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("退出") {
                        stopGame()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var startScreen: some View {
        VStack(spacing: 24) {
            Text("🧺")
                .font(.system(size: 80))
            
            Text("番茄接水果")
                .font(.title.bold())
                .foregroundColor(.darkGray)
            
            Text("拖动篮子接住番茄，避开炸弹！")
                .font(.subheadline)
                .foregroundColor(.darkGray.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                HStack {
                    Text("🍅")
                    Text("+10 分")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("💣")
                    Text("-20 分")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
            )
            
            Button(action: startGame) {
                Text("开始游戏")
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
    
    private var gameScreen: some View {
        ZStack {
            // UI 层
            VStack {
                // 顶部状态栏
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(score)")
                            .font(.title2.bold())
                            .foregroundColor(.darkGray)
                            .monospacedDigit()
                    }
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.tomatoRed)
                        Text("\(timeRemaining)")
                            .font(.title2.bold())
                            .foregroundColor(.darkGray)
                            .monospacedDigit()
                    }
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                }
                .padding()
                
                Spacer()
                
                // 篮子
                Text("🧺")
                    .font(.system(size: basketWidth))
                    .position(x: basketPosition, y: 40)
            }
            
            // 掉落物品层
            ForEach(fallingItems) { item in
                Text(item.emoji)
                    .font(.system(size: itemSize))
                    .position(item.position)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newPosition = value.location.x
                    basketPosition = max(basketWidth / 2, min(UIScreen.main.bounds.width - basketWidth / 2, newPosition))
                }
        )
    }
    
    private var gameOverScreen: some View {
        VStack(spacing: 24) {
            Text(score >= 100 ? "🎉" : "😊")
                .font(.system(size: 80))
            
            Text("游戏结束")
                .font(.title.bold())
                .foregroundColor(.darkGray)
            
            VStack(spacing: 12) {
                Text("得分")
                    .font(.subheadline)
                    .foregroundColor(.darkGray.opacity(0.7))
                
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.tomatoRed)
                    .monospacedDigit()
            }
            
            let coinsEarned = GameType.fruitCatch.coinFormula(score)
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                Text("+\(coinsEarned)")
                    .font(.title.bold())
                    .foregroundColor(.darkGray)
                    .monospacedDigit()
                Text("番茄币")
                    .font(.headline)
                    .foregroundColor(.darkGray.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.2))
            )
            
            Button(action: {
                dismiss()
            }) {
                Text("完成")
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
        .onAppear {
            saveGameRecord()
        }
    }
    
    private func startGame() {
        gameStarted = true
        score = 0
        timeRemaining = 60
        fallingItems = []
        
        // 倒计时定时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endGame()
            }
        }
        
        // 生成物品定时器
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            spawnItem()
        }
    }
    
    private func stopGame() {
        timer?.invalidate()
        spawnTimer?.invalidate()
        timer = nil
        spawnTimer = nil
    }
    
    private func endGame() {
        stopGame()
        gameOver = true
        HapticManager.shared.playSuccess()
    }
    
    private func spawnItem() {
        let isBomb = Double.random(in: 0...1) < 0.2 // 20% 概率是炸弹
        let x = CGFloat.random(in: 40...(UIScreen.main.bounds.width - 40))
        
        let item = FallingItem(
            id: UUID(),
            emoji: isBomb ? "💣" : "🍅",
            isBomb: isBomb,
            position: CGPoint(x: x, y: -50)
        )
        
        fallingItems.append(item)
        
        // 动画下落
        withAnimation(.linear(duration: 3.0)) {
            if let index = fallingItems.firstIndex(where: { $0.id == item.id }) {
                fallingItems[index].position.y = UIScreen.main.bounds.height - 100
            }
        }
        
        // 检测碰撞
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            checkCollision(item: item)
            fallingItems.removeAll { $0.id == item.id }
        }
    }
    
    private func checkCollision(item: FallingItem) {
        let basketLeft = basketPosition - basketWidth / 2
        let basketRight = basketPosition + basketWidth / 2
        let basketTop = UIScreen.main.bounds.height - 140
        
        if item.position.x >= basketLeft &&
           item.position.x <= basketRight &&
           item.position.y >= basketTop {
            if item.isBomb {
                score = max(0, score - 20)
                HapticManager.shared.playError()
            } else {
                score += 10
                HapticManager.shared.playImpact()
            }
        }
    }
    
    private func saveGameRecord() {
        let coinsEarned = GameType.fruitCatch.coinFormula(score)
        let record = GameRecord(
            gameType: .fruitCatch,
            score: score,
            coinsEarned: coinsEarned,
            duration: 60
        )
        // 记录游戏结果，如果超出每日限制则不给奖励
        _ = gameStore.recordGamePlay(record)
    }
}

struct FallingItem: Identifiable {
    let id: UUID
    let emoji: String
    let isBomb: Bool
    var position: CGPoint
}

#Preview {
    FruitCatchGame(gameStore: GameStore())
}

