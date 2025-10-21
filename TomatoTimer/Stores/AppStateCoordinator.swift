//
//  AppStateCoordinator.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI
import Combine

@MainActor
class AppStateCoordinator: ObservableObject {
    static let shared = AppStateCoordinator()
    
    @Published private(set) var sharedTimerEngine: TimerEngine
    
    private var settingsStore: SettingsStore
    private var statsStore: StatsStore
    private var gameStore: GameStore
    private var petStore: PetStore
    
    private init() {
        self.settingsStore = SettingsStore()
        self.statsStore = StatsStore()
        self.gameStore = GameStore()
        self.petStore = PetStore()
        
        // 创建共享的计时器引擎
        self.sharedTimerEngine = TimerEngine(
            settingsStore: settingsStore,
            statsStore: statsStore,
            gameStore: gameStore,
            petStore: petStore
        )
    }
    
    func getSettingsStore() -> SettingsStore {
        settingsStore
    }
    
    func getStatsStore() -> StatsStore {
        statsStore
    }
    
    func getTimerEngine() -> TimerEngine {
        sharedTimerEngine
    }
    
    func getGameStore() -> GameStore {
        gameStore
    }
    
    func getPetStore() -> PetStore {
        petStore
    }
}

