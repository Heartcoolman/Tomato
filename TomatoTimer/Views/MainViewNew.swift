//
//  MainViewNew.swift
//  TomatoTimer
//
//  Modern navigation with Dock System
//  玻璃态UI设计
//

import SwiftUI

struct MainViewNew: View {
    @StateObject private var coordinator = AppStateCoordinator.shared
    @State private var selectedItem: DockItem = .timer
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var timerEngine: TimerEngine {
        coordinator.getTimerEngine()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区
            TabView(selection: $selectedItem) {
                ForEach(DockItem.allCases) { item in
                    detailView(for: item)
                        .tag(item)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.liquidGlass, value: selectedItem)
            
            // Dock导航栏
            if horizontalSizeClass == .regular {
                DockNavigationBar(selectedItem: $selectedItem)
            } else {
                CompactDockNavigationBar(selectedItem: $selectedItem)
            }
        }
        .background(dynamicBackground)
        .ignoresSafeArea(edges: .bottom)
    }
    
    // MARK: - Detail View
    
    @ViewBuilder
    private func detailView(for item: DockItem) -> some View {
        switch item {
        case .timer:
            TimerViewNew(
                timerEngine: timerEngine,
                settingsStore: coordinator.getSettingsStore(),
                statsStore: coordinator.getStatsStore()
            )
            
        case .reader:
            ReaderMainView()
            
        case .pet:
            NavigationStack {
            PetView(
                petStore: coordinator.getPetStore(),
                gameStore: coordinator.getGameStore()
            )
                .navigationTitle(item.rawValue)
                .navigationBarTitleDisplayMode(.inline)
            }
            
        case .achievements:
            NavigationStack {
            AchievementView(gameStore: coordinator.getGameStore())
                    .navigationTitle(item.rawValue)
                    .navigationBarTitleDisplayMode(.inline)
            }
            
        case .history:
            NavigationStack {
            HistoryViewNew(statsStore: coordinator.getStatsStore())
                    .navigationTitle(item.rawValue)
                    .navigationBarTitleDisplayMode(.inline)
            }
            
        case .settings:
            NavigationStack {
            SettingsViewNew(settingsStore: coordinator.getSettingsStore())
                    .navigationTitle(item.rawValue)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - Dynamic Background
    
    private var dynamicBackground: some View {
        ZStack {
            // 基础渐变背景
            LinearGradient(
                colors: [
                    Color.surfaceSecondary,
                    Color.surfaceTertiary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 根据选中项添加微妙的颜色叠加
            backgroundOverlay
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private var backgroundOverlay: some View {
        switch selectedItem {
        case .timer:
            RadialGradient(
                colors: [
                    Color.modernBlue1.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            
        case .reader:
            RadialGradient(
                colors: [
                    Color.modernPurple1.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            
        case .pet:
            RadialGradient(
                colors: [
                    Color.modernPink1.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            
        case .achievements:
            RadialGradient(
                colors: [
                    Color.gold1.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            
        case .history:
            RadialGradient(
                colors: [
                    Color.modernGreen1.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
            
        case .settings:
            RadialGradient(
                colors: [
                    Color.neutralMid.opacity(0.03),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 600
            )
        }
    }
}

// MARK: - Preview

#Preview("iPad Landscape") {
    MainViewNew()
        .frame(width: 1200, height: 800)
}

#Preview("iPad Portrait") {
    MainViewNew()
        .frame(width: 800, height: 1200)
}

