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
    
    @Published private(set) var activeTimerEngine: TimerEngine?
    @Published private(set) var activeSceneID: String?
    
    private var settingsStore: SettingsStore
    private var statsStore: StatsStore
    
    private init() {
        self.settingsStore = SettingsStore()
        self.statsStore = StatsStore()
        
        // 设置通知观察者
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSceneActivation),
            name: NSNotification.Name("SceneDidBecomeActive"),
            object: nil
        )
    }
    
    func getSettingsStore() -> SettingsStore {
        settingsStore
    }
    
    func getStatsStore() -> StatsStore {
        statsStore
    }
    
    func registerScene(id: String) -> TimerEngine {
        if activeTimerEngine == nil {
            // 第一个窗口，创建计时器
            let engine = TimerEngine(settingsStore: settingsStore, statsStore: statsStore)
            activeTimerEngine = engine
            activeSceneID = id
            return engine
        } else if activeSceneID == id {
            // 同一个窗口重新激活
            return activeTimerEngine!
        } else {
            // 其他窗口，返回只读引用
            return activeTimerEngine!
        }
    }
    
    func isActiveScene(id: String) -> Bool {
        return activeSceneID == id
    }
    
    func updateActiveScene(id: String) {
        activeSceneID = id
    }
    
    @objc private func handleSceneActivation(_ notification: Notification) {
        if let sceneID = notification.userInfo?["sceneID"] as? String {
            updateActiveScene(id: sceneID)
        }
    }
}

