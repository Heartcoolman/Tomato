//
//  CoinWidget.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct CoinWidget: View {
    @ObservedObject var gameStore: GameStore
    @State private var showHistory = false
    @State private var animateCoins = false
    
    var body: some View {
        Button(action: {
            showHistory = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    .scaleEffect(animateCoins ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateCoins)
                
                Text("\(gameStore.coinBalance)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.8),
                                Color.red.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showHistory) {
            CoinHistoryView(gameStore: gameStore)
        }
        .onChange(of: gameStore.coinBalance) { oldValue, newValue in
            if newValue > oldValue {
                triggerCoinAnimation()
            }
        }
    }
    
    private func triggerCoinAnimation() {
        animateCoins = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animateCoins = false
        }
    }
}

#Preview {
    CoinWidget(gameStore: GameStore())
}

