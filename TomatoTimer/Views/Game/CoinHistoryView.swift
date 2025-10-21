//
//  CoinHistoryView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct CoinHistoryView: View {
    @ObservedObject var gameStore: GameStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 余额卡片
                    balanceCard
                    
                    // 交易记录
                    transactionsList
                }
                .padding()
            }
            .background(Color.lightYellow.ignoresSafeArea())
            .navigationTitle("番茄币")
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
    
    private var balanceCard: some View {
        VStack(spacing: 12) {
            Text("当前余额")
                .font(.subheadline)
                .foregroundColor(.darkGray.opacity(0.7))
            
            HStack(spacing: 8) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
                
                Text("\(gameStore.coinBalance)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.darkGray)
                    .monospacedDigit()
            }
            
            Text("累计赚取: \(gameStore.totalCoinsEarned) 币")
                .font(.caption)
                .foregroundColor(.darkGray.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var transactionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("交易记录")
                .font(.headline)
                .foregroundColor(.darkGray)
            
            if gameStore.transactions.isEmpty {
                emptyState
            } else {
                ForEach(gameStore.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无交易记录")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct TransactionRow: View {
    let transaction: CoinTransaction
    
    var body: some View {
        HStack {
            // 图标
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(transaction.amount > 0 ? .green : .red)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(transaction.amount > 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
            
            // 描述和时间
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .foregroundColor(.darkGray)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 金额
            Text(transaction.amount > 0 ? "+\(transaction.amount)" : "\(transaction.amount)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(transaction.amount > 0 ? .green : .red)
                .monospacedDigit()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
    
    private var iconName: String {
        switch transaction.reason {
        case .completedPomodoro:
            return "checkmark.circle.fill"
        case .streak:
            return "flame.fill"
        case .achievement:
            return "trophy.fill"
        case .feedPet:
            return "leaf.fill"
        case .buyItem:
            return "cart.fill"
        case .playGame:
            return "gamecontroller.fill"
        case .pat:
            return "hand.wave.fill"
        case .heal:
            return "heart.fill"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    CoinHistoryView(gameStore: GameStore())
}

