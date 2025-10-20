//
//  TodayStatsView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct TodayStatsView: View {
    @ObservedObject var statsStore: StatsStore
    
    var body: some View {
        VStack(spacing: 16) {
            Text("今日统计")
                .font(.headline)
                .foregroundColor(.darkGray)
            
            HStack(spacing: 40) {
                TodayStatItem(
                    icon: "🍅",
                    value: "\(statsStore.todayPomodoroCount)",
                    label: "完成番茄"
                )
                
                TodayStatItem(
                    icon: "⏱️",
                    value: "\(statsStore.todayTotalMinutes)",
                    label: "总分钟数"
                )
                
                TodayStatItem(
                    icon: "🔥",
                    value: "\(statsStore.currentStreak)",
                    label: "连续天数"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct TodayStatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 32))
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.tomatoRed)
            Text(label)
                .font(.caption)
                .foregroundColor(.darkGray.opacity(0.7))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview {
    TodayStatsView(statsStore: StatsStore())
        .padding()
        .background(Color.lightYellow)
}

