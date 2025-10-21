//
//  MainView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case timer = "计时器"
    case pet = "宠物"
    case achievements = "成就"
    case history = "历史"
    case settings = "设置"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .timer: return "timer"
        case .pet: return "pawprint.fill"
        case .achievements: return "trophy.fill"
        case .history: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainView: View {
    @StateObject private var coordinator = AppStateCoordinator.shared
    @State private var selectedItem: NavigationItem = .timer
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var timerEngine: TimerEngine {
        coordinator.getTimerEngine()
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(NavigationItem.allCases, id: \.self) { item in
                Button {
                    selectedItem = item
                } label: {
                    HStack {
                        Label(item.rawValue, systemImage: item.icon)
                            .foregroundColor(.darkGray)
                        Spacer()
                        if selectedItem == item {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.tomatoRed)
                                .font(.caption)
                        }
                    }
                }
                .listRowBackground(
                    selectedItem == item ?
                    Color.tomatoRed.opacity(0.1) :
                    Color.clear
                )
            }
            .navigationTitle("番茄计时器")
            .listStyle(.sidebar)
            .background(Color.lightYellow)
            .scrollContentBackground(.hidden)
        } detail: {
            NavigationStack {
                detailView
                    .navigationTitle(selectedItem.rawValue)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .tint(.tomatoRed)
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .timer:
            TimerView(
                timerEngine: timerEngine,
                settingsStore: coordinator.getSettingsStore(),
                statsStore: coordinator.getStatsStore(),
                gameStore: coordinator.getGameStore(),
                petStore: coordinator.getPetStore()
            )
        case .pet:
            PetView(
                petStore: coordinator.getPetStore(),
                gameStore: coordinator.getGameStore()
            )
        case .achievements:
            AchievementView(gameStore: coordinator.getGameStore())
        case .history:
            HistoryView(statsStore: coordinator.getStatsStore())
        case .settings:
            SettingsView(settingsStore: coordinator.getSettingsStore())
        }
    }
}

#Preview {
    MainView()
}

