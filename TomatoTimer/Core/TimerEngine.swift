//
//  TimerEngine.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation
import Combine
import UIKit

@MainActor
class TimerEngine: ObservableObject {
    // MARK: - Published Properties
    @Published var state: TimerState = .idle
    @Published var currentMode: TimerMode = .work
    @Published var remainingTime: TimeInterval = 25 * 60
    @Published var workSessionsCount: Int = 0
    
    // MARK: - Private Properties
    private var targetEndDate: Date?
    private var timerCancellable: AnyCancellable?
    private var totalDuration: TimeInterval = 25 * 60
    
    private let settingsStore: SettingsStore
    private let statsStore: StatsStore
    
    // MARK: - Initialization
    init(settingsStore: SettingsStore, statsStore: StatsStore) {
        self.settingsStore = settingsStore
        self.statsStore = statsStore
        
        // 从持久化存储恢复状态
        restoreState()
    }
    
    // MARK: - Public Methods
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return max(0, min(1, 1 - (remainingTime / totalDuration)))
    }
    
    func start() {
        guard state != .running else { return }
        
        targetEndDate = Date().addingTimeInterval(remainingTime)
        state = .running
        startTicking()
        
        // 禁用自动锁屏
        if settingsStore.keepScreenOn {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        
        saveState()
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playImpact()
        }
    }
    
    func pause() {
        guard state == .running else { return }
        
        state = .paused
        stopTicking()
        
        // 恢复自动锁屏
        UIApplication.shared.isIdleTimerDisabled = false
        
        saveState()
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playImpact()
        }
    }
    
    func reset() {
        stopTicking()
        state = .idle
        remainingTime = getDuration(for: currentMode)
        totalDuration = remainingTime
        targetEndDate = nil
        
        // 恢复自动锁屏
        UIApplication.shared.isIdleTimerDisabled = false
        
        saveState()
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playSelection()
        }
    }
    
    func addFiveMinutes() {
        guard state == .running || state == .paused else { return }
        
        remainingTime += 5 * 60
        totalDuration += 5 * 60
        
        if let target = targetEndDate {
            targetEndDate = target.addingTimeInterval(5 * 60)
        }
        
        saveState()
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playSelection()
        }
    }
    
    func skipToNext() {
        completeCurrentSession()
        switchToNextMode()
        reset()
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playSelection()
        }
    }
    
    func switchMode(to mode: TimerMode) {
        let wasRunning = state == .running
        reset()
        currentMode = mode
        remainingTime = getDuration(for: mode)
        totalDuration = remainingTime
        saveState()
        
        if wasRunning && settingsStore.autoSwitch {
            start()
        }
    }
    
    func adjustCurrentModeDuration(by minutes: Int) {
        let newDuration = totalDuration + TimeInterval(minutes * 60)
        guard newDuration > 0 else { return }
        
        let adjustment = TimeInterval(minutes * 60)
        remainingTime += adjustment
        totalDuration = newDuration
        
        if let target = targetEndDate {
            targetEndDate = target.addingTimeInterval(adjustment)
        }
        
        // 更新设置
        switch currentMode {
        case .work:
            settingsStore.workDuration = totalDuration
        case .shortBreak:
            settingsStore.shortBreakDuration = totalDuration
        case .longBreak:
            settingsStore.longBreakDuration = totalDuration
        }
        
        saveState()
    }
    
    // MARK: - Private Methods
    private func startTicking() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func stopTicking() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func tick() {
        guard let target = targetEndDate else {
            stopTicking()
            return
        }
        
        remainingTime = max(0, target.timeIntervalSinceNow)
        
        if remainingTime <= 0 {
            handleCompletion()
        }
    }
    
    private func handleCompletion() {
        stopTicking()
        state = .completed
        targetEndDate = nil
        
        // 恢复自动锁屏
        UIApplication.shared.isIdleTimerDisabled = false
        
        // 保存完成的会话
        completeCurrentSession()
        
        // 播放声音
        if settingsStore.soundEnabled {
            SoundManager.shared.playCompletionSound()
        }
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playSuccess()
        }
        
        // 发送通知
        if settingsStore.notificationsEnabled {
            NotificationManager.shared.sendCompletionNotification(for: currentMode)
        }
        
        saveState()
        
        // 自动切换到下一模式
        if settingsStore.autoSwitch {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 秒延迟
                switchToNextMode()
                reset()
                if settingsStore.autoStart {
                    start()
                }
            }
        }
    }
    
    private func completeCurrentSession() {
        // 只记录工作模式的完成
        if currentMode == .work {
            workSessionsCount += 1
        }
        
        let session = PomodoroSession(
            date: Date(),
            mode: currentMode,
            duration: totalDuration
        )
        statsStore.addSession(session)
    }
    
    private func switchToNextMode() {
        switch currentMode {
        case .work:
            // 每 4 个番茄后进入长休息
            if workSessionsCount % 4 == 0 && workSessionsCount > 0 {
                currentMode = .longBreak
            } else {
                currentMode = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentMode = .work
        }
    }
    
    private func getDuration(for mode: TimerMode) -> TimeInterval {
        switch mode {
        case .work:
            return settingsStore.workDuration
        case .shortBreak:
            return settingsStore.shortBreakDuration
        case .longBreak:
            return settingsStore.longBreakDuration
        }
    }
    
    // MARK: - Persistence
    private func saveState() {
        let stateData: [String: Any] = [
            "state": state.rawValue,
            "mode": currentMode.rawValue,
            "remainingTime": remainingTime,
            "totalDuration": totalDuration,
            "workSessionsCount": workSessionsCount,
            "targetEndDate": targetEndDate?.timeIntervalSince1970 ?? 0
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: stateData) {
            UserDefaults.standard.set(data, forKey: "timerState")
        }
    }
    
    private func restoreState() {
        guard let data = UserDefaults.standard.data(forKey: "timerState"),
              let stateData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        if let stateString = stateData["state"] as? String,
           let savedState = TimerState(rawValue: stateString) {
            state = savedState
        }
        
        if let modeString = stateData["mode"] as? String,
           let savedMode = TimerMode(rawValue: modeString) {
            currentMode = savedMode
        }
        
        if let time = stateData["remainingTime"] as? TimeInterval {
            remainingTime = time
        }
        
        if let duration = stateData["totalDuration"] as? TimeInterval {
            totalDuration = duration
        }
        
        if let count = stateData["workSessionsCount"] as? Int {
            workSessionsCount = count
        }
        
        if let targetTimestamp = stateData["targetEndDate"] as? TimeInterval,
           targetTimestamp > 0 {
            let savedTarget = Date(timeIntervalSince1970: targetTimestamp)
            
            // 检查是否还有效（如果应用被杀死后重启）
            if savedTarget > Date() {
                targetEndDate = savedTarget
                remainingTime = savedTarget.timeIntervalSinceNow
                
                // 如果之前在运行，恢复运行状态
                if state == .running {
                    startTicking()
                }
            } else {
                // 时间已过期，重置
                reset()
            }
        }
    }
}

