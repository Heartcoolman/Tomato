//
//  GameCenterView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct GameCenterView: View {
    @ObservedObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedGame: GameType? = nil
    @State private var showGame = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题
                    VStack(spacing: 8) {
                        Text("🎮")
                            .font(.system(size: 60))
                        
                        Text("游戏中心")
                            .font(.title.bold())
                            .foregroundColor(.darkGray)
                        
                        Text("放松一下，玩玩小游戏吧！")
                            .font(.subheadline)
                            .foregroundColor(.darkGray.opacity(0.7))
                    }
                    .padding(.top)
                    
                    // 游戏列表
                    ForEach(GameType.allCases) { gameType in
                        GameCard(
                            gameType: gameType,
                            gameStore: gameStore
                        ) {
                            selectedGame = gameType
                            showGame = true
                        }
                    }
                }
                .padding()
            }
            .background(Color.lightYellow.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showGame) {
                if let gameType = selectedGame {
                    gameView(for: gameType)
                }
            }
        }
    }
    
    @ViewBuilder
    private func gameView(for gameType: GameType) -> some View {
        switch gameType {
        case .fruitCatch:
            FruitCatchGame(gameStore: gameStore)
        case .tomato2048:
            Tomato2048Game(gameStore: gameStore)
        case .memoryCard:
            MemoryCardGame(gameStore: gameStore)
        }
    }
}

struct GameCard: View {
    let gameType: GameType
    @ObservedObject var gameStore: GameStore
    let action: () -> Void
    
    var remainingPlays: Int {
        gameStore.remainingPlaysToday(gameType)
    }
    
    var highScore: Int {
        gameStore.gameStats.highScores[gameType.rawValue] ?? 0
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // 图标
                    Image(systemName: gameType.icon)
                        .font(.system(size: 40))
                        .foregroundColor(.tomatoRed)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.tomatoRed.opacity(0.1))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameType.rawValue)
                            .font(.headline)
                            .foregroundColor(.darkGray)
                        
                        Text(gameType.description)
                            .font(.caption)
                            .foregroundColor(.darkGray.opacity(0.7))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                // 统计信息
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("今日剩余")
                            .font(.caption)
                            .foregroundColor(.darkGray.opacity(0.6))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "play.circle.fill")
                                .font(.caption)
                            Text("\(remainingPlays)/\(gameType.dailyLimit)")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(remainingPlays > 0 ? .green : .red)
                    }
                    
                    Spacer()
                    
                    if highScore > 0 {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("最高分")
                                .font(.caption)
                                .foregroundColor(.darkGray.opacity(0.6))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.caption)
                                Text("\(highScore)")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(remainingPlays == 0)
        .opacity(remainingPlays == 0 ? 0.6 : 1.0)
    }
}

#Preview {
    GameCenterView(gameStore: GameStore())
}

