//
//  MemoryCardGame.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct MemoryCardGame: View {
    @ObservedObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss
    
    @State private var cards: [MemoryCard] = []
    @State private var flippedIndices: Set<Int> = []
    @State private var matchedIndices: Set<Int> = []
    @State private var score = 0
    @State private var timeRemaining = 90
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var timer: Timer? = nil
    @State private var isChecking = false
    
    let emojis = ["🍅", "🥕", "🥒", "🌽", "🍓", "🍇", "🍊", "🍋"]
    let gridColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
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
            Text("🃏")
                .font(.system(size: 80))
            
            Text("记忆翻牌")
                .font(.title.bold())
                .foregroundColor(.darkGray)
            
            Text("翻开匹配的卡片，考验你的记忆力！")
                .font(.subheadline)
                .foregroundColor(.darkGray.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("规则")
                    .font(.headline)
                    .foregroundColor(.darkGray)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• 每次翻开两张卡片")
                    Text("• 匹配成功得10分")
                    Text("• 在90秒内完成")
                }
                .font(.subheadline)
                .foregroundColor(.darkGray.opacity(0.7))
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
        VStack(spacing: 20) {
            // 顶部状态
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
            .padding(.horizontal)
            
            // 进度
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("\(matchedIndices.count / 2)/\(emojis.count)")
                    .font(.headline)
                    .foregroundColor(.darkGray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(Color.white)
            )
            
            // 卡片网格
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(cards.indices, id: \.self) { index in
                    CardView(
                        card: cards[index],
                        isFlipped: flippedIndices.contains(index) || matchedIndices.contains(index),
                        isMatched: matchedIndices.contains(index)
                    )
                    .onTapGesture {
                        flipCard(at: index)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    private var gameOverScreen: some View {
        VStack(spacing: 24) {
            Text(matchedIndices.count == cards.count ? "🎉" : "⏰")
                .font(.system(size: 80))
            
            Text(matchedIndices.count == cards.count ? "完美！" : "时间到")
                .font(.title.bold())
                .foregroundColor(.darkGray)
            
            VStack(spacing: 12) {
                Text("配对成功")
                    .font(.subheadline)
                    .foregroundColor(.darkGray.opacity(0.7))
                
                Text("\(matchedIndices.count / 2)/\(emojis.count)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.tomatoRed)
            }
            
            let pairsMatched = matchedIndices.count / 2
            let coinsEarned = GameType.memoryCard.coinFormula(pairsMatched)
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
            
            HStack(spacing: 12) {
                Button(action: startGame) {
                    Text("再玩一次")
                        .font(.headline)
                        .foregroundColor(.tomatoRed)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .stroke(Color.tomatoRed, lineWidth: 2)
                        )
                }
                
                Button(action: { dismiss() }) {
                    Text("完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.tomatoRed)
                        )
                }
            }
        }
        .padding()
        .onAppear {
            saveGameRecord()
        }
    }
    
    private func startGame() {
        // 创建卡片对
        var cardPairs: [MemoryCard] = []
        for (index, emoji) in emojis.enumerated() {
            cardPairs.append(MemoryCard(id: index * 2, emoji: emoji))
            cardPairs.append(MemoryCard(id: index * 2 + 1, emoji: emoji))
        }
        cards = cardPairs.shuffled()
        
        flippedIndices = []
        matchedIndices = []
        score = 0
        timeRemaining = 90
        gameStarted = true
        gameOver = false
        
        // 启动计时器
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endGame()
            }
        }
    }
    
    private func stopGame() {
        timer?.invalidate()
        timer = nil
    }
    
    private func endGame() {
        stopGame()
        gameOver = true
        HapticManager.shared.playSuccess()
    }
    
    private func flipCard(at index: Int) {
        guard !isChecking,
              !matchedIndices.contains(index),
              !flippedIndices.contains(index),
              flippedIndices.count < 2 else {
            return
        }
        
        flippedIndices.insert(index)
        HapticManager.shared.playImpact()
        
        if flippedIndices.count == 2 {
            checkForMatch()
        }
    }
    
    private func checkForMatch() {
        isChecking = true
        let indices = Array(flippedIndices)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if cards[indices[0]].emoji == cards[indices[1]].emoji {
                // 匹配成功
                matchedIndices.insert(indices[0])
                matchedIndices.insert(indices[1])
                score += 10
                HapticManager.shared.playSuccess()
                
                // 检查是否全部匹配
                if matchedIndices.count == cards.count {
                    endGame()
                }
            } else {
                // 不匹配，翻回去
                HapticManager.shared.playError()
            }
            
            flippedIndices.removeAll()
            isChecking = false
        }
    }
    
    private func saveGameRecord() {
        let pairsMatched = matchedIndices.count / 2
        let coinsEarned = GameType.memoryCard.coinFormula(pairsMatched)
        let record = GameRecord(
            gameType: .memoryCard,
            score: pairsMatched,
            coinsEarned: coinsEarned,
            duration: 90 - Double(timeRemaining)
        )
        gameStore.recordGamePlay(record)
    }
}

struct MemoryCard: Identifiable {
    let id: Int
    let emoji: String
}

struct CardView: View {
    let card: MemoryCard
    let isFlipped: Bool
    let isMatched: Bool
    
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            if isFlipped {
                // 正面
                RoundedRectangle(cornerRadius: 12)
                    .fill(isMatched ? Color.green.opacity(0.3) : Color.white)
                    .overlay(
                        Text(card.emoji)
                            .font(.system(size: 40))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isMatched ? Color.green : Color.tomatoRed, lineWidth: 2)
                    )
            } else {
                // 背面
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.tomatoRed, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Text("🍅")
                            .font(.system(size: 30))
                    )
            }
        }
        .frame(height: 80)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 0, y: 1, z: 0)
        )
        .onChange(of: isFlipped) { _, newValue in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                rotation = newValue ? 180 : 0
            }
        }
    }
}

#Preview {
    MemoryCardGame(gameStore: GameStore())
}

