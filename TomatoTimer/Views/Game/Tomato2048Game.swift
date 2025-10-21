//
//  Tomato2048Game.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct Tomato2048Game: View {
    @ObservedObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss
    
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var score = 0
    @State private var gameStarted = false
    @State private var gameOver = false
    @State private var won = false
    
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
                        if gameStarted && !gameOver {
                            endGame()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var startScreen: some View {
        VStack(spacing: 24) {
            Text("🍅")
                .font(.system(size: 80))
            
            Text("2048 番茄版")
                .font(.title.bold())
                .foregroundColor(.darkGray)
            
            Text("滑动合并相同数字，达到2048！")
                .font(.subheadline)
                .foregroundColor(.darkGray.opacity(0.7))
                .multilineTextAlignment(.center)
            
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
            // 分数
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("得分")
                        .font(.caption)
                        .foregroundColor(.darkGray.opacity(0.6))
                    Text("\(score)")
                        .font(.title.bold())
                        .foregroundColor(.tomatoRed)
                        .monospacedDigit()
                }
                
                Spacer()
                
                Button(action: startGame) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重新开始")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.tomatoRed))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(radius: 4)
            )
            
            // 游戏网格
            VStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { col in
                            TileView(value: grid[row][col])
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
            )
            
            Spacer()
        }
        .padding()
        .gesture(
            DragGesture()
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < 0 {
                            move(.left)
                        } else {
                            move(.right)
                        }
                    } else {
                        if verticalAmount < 0 {
                            move(.up)
                        } else {
                            move(.down)
                        }
                    }
                }
        )
    }
    
    private var gameOverScreen: some View {
        VStack(spacing: 24) {
            Text(won ? "🎉" : "😊")
                .font(.system(size: 80))
            
            Text(won ? "恭喜！" : "游戏结束")
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
            
            let coinsEarned = GameType.tomato2048.coinFormula(score)
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
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        gameStarted = true
        gameOver = false
        won = false
        addNewTile()
        addNewTile()
    }
    
    private func addNewTile() {
        var emptySpots: [(Int, Int)] = []
        for row in 0..<4 {
            for col in 0..<4 {
                if grid[row][col] == 0 {
                    emptySpots.append((row, col))
                }
            }
        }
        
        guard let spot = emptySpots.randomElement() else { return }
        grid[spot.0][spot.1] = Double.random(in: 0...1) < 0.9 ? 2 : 4
    }
    
    private func move(_ direction: Direction) {
        var moved = false
        var newGrid = grid
        
        switch direction {
        case .left:
            for row in 0..<4 {
                let result = mergeLine(Array(newGrid[row]))
                newGrid[row] = result.line
                if result.moved { moved = true }
                score += result.scoreGain
            }
        case .right:
            for row in 0..<4 {
                let reversed = Array(newGrid[row].reversed())
                let result = mergeLine(reversed)
                newGrid[row] = Array(result.line.reversed())
                if result.moved { moved = true }
                score += result.scoreGain
            }
        case .up:
            for col in 0..<4 {
                var column = [Int]()
                for row in 0..<4 {
                    column.append(newGrid[row][col])
                }
                let result = mergeLine(column)
                for row in 0..<4 {
                    newGrid[row][col] = result.line[row]
                }
                if result.moved { moved = true }
                score += result.scoreGain
            }
        case .down:
            for col in 0..<4 {
                var column = [Int]()
                for row in 0..<4 {
                    column.append(newGrid[row][col])
                }
                let reversed = Array(column.reversed())
                let result = mergeLine(reversed)
                let merged = Array(result.line.reversed())
                for row in 0..<4 {
                    newGrid[row][col] = merged[row]
                }
                if result.moved { moved = true }
                score += result.scoreGain
            }
        }
        
        if moved {
            grid = newGrid
            addNewTile()
            HapticManager.shared.playImpact()
            
            // 检查是否达到2048
            if grid.flatMap({ $0 }).contains(2048) && !won {
                won = true
            }
            
            // 检查游戏是否结束
            if !canMove() {
                endGame()
            }
        }
    }
    
    private func mergeLine(_ line: [Int]) -> (line: [Int], moved: Bool, scoreGain: Int) {
        var result = line.filter { $0 != 0 }
        var merged = [Int]()
        var moved = false
        var scoreGain = 0
        var i = 0
        
        while i < result.count {
            if i + 1 < result.count && result[i] == result[i + 1] {
                let value = result[i] * 2
                merged.append(value)
                scoreGain += value
                i += 2
                moved = true
            } else {
                merged.append(result[i])
                i += 1
            }
        }
        
        while merged.count < 4 {
            merged.append(0)
        }
        
        if merged != line {
            moved = true
        }
        
        return (merged, moved, scoreGain)
    }
    
    private func canMove() -> Bool {
        // 检查是否有空格
        for row in grid {
            if row.contains(0) {
                return true
            }
        }
        
        // 检查是否可以合并
        for row in 0..<4 {
            for col in 0..<3 {
                if grid[row][col] == grid[row][col + 1] {
                    return true
                }
            }
        }
        
        for col in 0..<4 {
            for row in 0..<3 {
                if grid[row][col] == grid[row + 1][col] {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func endGame() {
        gameOver = true
        HapticManager.shared.playSuccess()
    }
    
    private func saveGameRecord() {
        let coinsEarned = GameType.tomato2048.coinFormula(score)
        let record = GameRecord(
            gameType: .tomato2048,
            score: score,
            coinsEarned: coinsEarned,
            duration: 0
        )
        // 记录游戏结果，如果超出每日限制则不给奖励
        _ = gameStore.recordGamePlay(record)
    }
    
    enum Direction {
        case up, down, left, right
    }
}

struct TileView: View {
    let value: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor)
            
            if value > 0 {
                Text("\(value)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
            }
        }
        .frame(width: 70, height: 70)
    }
    
    private var tileColor: Color {
        switch value {
        case 0: return Color.white.opacity(0.5)
        case 2: return Color(red: 0.93, green: 0.89, blue: 0.85)
        case 4: return Color(red: 0.93, green: 0.88, blue: 0.78)
        case 8: return Color(red: 0.95, green: 0.69, blue: 0.47)
        case 16: return Color(red: 0.96, green: 0.58, blue: 0.39)
        case 32: return Color(red: 0.96, green: 0.49, blue: 0.37)
        case 64: return Color(red: 0.96, green: 0.37, blue: 0.23)
        case 128: return Color(red: 0.93, green: 0.81, blue: 0.45)
        case 256: return Color(red: 0.93, green: 0.80, blue: 0.38)
        case 512: return Color(red: 0.93, green: 0.78, blue: 0.31)
        case 1024: return Color(red: 0.93, green: 0.77, blue: 0.25)
        case 2048: return Color(red: 0.93, green: 0.76, blue: 0.18)
        default: return Color.black
        }
    }
    
    private var textColor: Color {
        value <= 4 ? .darkGray : .white
    }
    
    private var fontSize: CGFloat {
        switch value {
        case 0...64: return 28
        case 128...512: return 24
        case 1024...2048: return 20
        default: return 18
        }
    }
}

#Preview {
    Tomato2048Game(gameStore: GameStore())
}

