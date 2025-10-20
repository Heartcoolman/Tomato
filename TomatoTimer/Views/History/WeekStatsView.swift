//
//  WeekStatsView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct WeekStatsView: View {
    @ObservedObject var statsStore: StatsStore
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 40) {
                WeekStatItem(
                    title: "本周番茄",
                    value: "\(statsStore.thisWeekPomodoroCount)",
                    icon: "🍅"
                )
                
                WeekStatItem(
                    title: "本周分钟",
                    value: "\(statsStore.thisWeekTotalMinutes)",
                    icon: "⏱️"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tomatoRed.opacity(0.1))
        )
    }
}

struct WeekStatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 40))
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.tomatoRed)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.darkGray)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    WeekStatsView(statsStore: StatsStore())
        .padding()
        .background(Color.lightYellow)
}

