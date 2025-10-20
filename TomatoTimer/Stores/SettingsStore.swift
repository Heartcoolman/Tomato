//
//  SettingsStore.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

@MainActor
class SettingsStore: ObservableObject {
    @AppStorage("workDuration") var workDuration: Double = 25 * 60
    @AppStorage("shortBreakDuration") var shortBreakDuration: Double = 5 * 60
    @AppStorage("longBreakDuration") var longBreakDuration: Double = 15 * 60
    
    @AppStorage("autoSwitch") var autoSwitch: Bool = true
    @AppStorage("autoStart") var autoStart: Bool = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("keepScreenOn") var keepScreenOn: Bool = true
    
    var workDurationMinutes: Int {
        get { Int(workDuration / 60) }
        set { workDuration = Double(newValue * 60) }
    }
    
    var shortBreakDurationMinutes: Int {
        get { Int(shortBreakDuration / 60) }
        set { shortBreakDuration = Double(newValue * 60) }
    }
    
    var longBreakDurationMinutes: Int {
        get { Int(longBreakDuration / 60) }
        set { longBreakDuration = Double(newValue * 60) }
    }
    
    func resetToDefaults() {
        workDuration = 25 * 60
        shortBreakDuration = 5 * 60
        longBreakDuration = 15 * 60
        autoSwitch = true
        autoStart = false
        notificationsEnabled = true
        soundEnabled = true
        hapticsEnabled = true
        keepScreenOn = true
    }
}

