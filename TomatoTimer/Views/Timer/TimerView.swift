//
//  TimerView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var timerEngine: TimerEngine
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var statsStore: StatsStore
    
    @State private var showingCompletionAlert = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // 模式选择器
                Picker("模式", selection: $timerEngine.currentMode) {
                    ForEach(TimerMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(timerEngine.state == .running)
                .onChange(of: timerEngine.currentMode) { _, newMode in
                    if timerEngine.state != .running {
                        timerEngine.switchMode(to: newMode)
                    }
                }
                .padding(.horizontal)
                
                // 圆环和倒计时
                ZStack {
                    CircularProgressView(progress: timerEngine.progress)
                        .frame(width: 300, height: 300)
                    
                    VStack(spacing: 8) {
                        Text(timeString(from: timerEngine.remainingTime))
                            .font(.system(size: 64, weight: .light, design: .rounded))
                            .foregroundColor(.darkGray)
                            .monospacedDigit()
                            .accessibilityLabel("剩余时间")
                            .accessibilityValue(timerEngine.remainingTime.accessibilityTimeDescription)
                        
                        Text(timerEngine.currentMode.displayName)
                            .font(.title3)
                            .foregroundColor(.darkGray.opacity(0.7))
                    }
                }
                .padding()
                
                // 控制按钮
                controlButtons
                
                // 设置开关
                settingsToggles
                
                // 今日统计
                TodayStatsView(statsStore: statsStore)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.lightYellow.ignoresSafeArea())
        .onChange(of: timerEngine.state) { oldState, newState in
            if newState == .completed && oldState != .completed {
                showingCompletionAlert = true
            }
        }
        .alert("完成！", isPresented: $showingCompletionAlert) {
            Button("好的") {
                showingCompletionAlert = false
            }
        } message: {
            Text("\(timerEngine.currentMode.displayName)时间结束")
        }
    }
    
    private var controlButtons: some View {
        VStack(spacing: 16) {
            // 开始/暂停 和 重置
            HStack(spacing: 20) {
                Button {
                    if timerEngine.state == .running {
                        timerEngine.pause()
                    } else {
                        timerEngine.start()
                    }
                } label: {
                    HStack {
                        Image(systemName: timerEngine.state == .running ? "pause.fill" : "play.fill")
                        Text(timerEngine.state == .running ? "暂停" : "开始")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tomatoRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .accessibleButton(
                    label: timerEngine.state == .running ? "暂停计时器" : "开始计时器",
                    hint: timerEngine.state == .running ? "暂停当前计时" : "开始倒计时"
                )
                .keyboardShortcut(" ", modifiers: [])
                
                Button {
                    timerEngine.reset()
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("重置")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.darkGray.opacity(0.1))
                    .foregroundColor(.darkGray)
                    .cornerRadius(12)
                }
                .accessibleButton(label: "重置计时器", hint: "将计时器重置到初始状态")
                .keyboardShortcut("r", modifiers: [])
            }
            .padding(.horizontal)
            
            // +5 分钟 和 跳过
            if timerEngine.state != .idle {
                HStack(spacing: 20) {
                    Button {
                        timerEngine.addFiveMinutes()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("加 5 分钟")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.tomatoRed)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.tomatoRed, lineWidth: 2)
                        )
                    }
                    .accessibleButton(label: "增加 5 分钟", hint: "在当前时间基础上增加 5 分钟")
                    
                    Button {
                        timerEngine.skipToNext()
                    } label: {
                        HStack {
                            Image(systemName: "forward.end.fill")
                            Text("跳过")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.darkGray)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.darkGray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .accessibleButton(label: "跳过当前阶段", hint: "完成当前阶段并切换到下一个")
                    .keyboardShortcut("n", modifiers: [])
                }
                .padding(.horizontal)
            }
            
            // 时长调整快捷键（隐藏）
            Button("") { timerEngine.adjustCurrentModeDuration(by: 1) }
                .keyboardShortcut(.upArrow, modifiers: [])
                .hidden()
            
            Button("") { timerEngine.adjustCurrentModeDuration(by: -1) }
                .keyboardShortcut(.downArrow, modifiers: [])
                .hidden()
            
            // 模式切换快捷键（隐藏）
            Button("") { timerEngine.switchMode(to: .work) }
                .keyboardShortcut("1", modifiers: [])
                .hidden()
            
            Button("") { timerEngine.switchMode(to: .shortBreak) }
                .keyboardShortcut("2", modifiers: [])
                .hidden()
            
            Button("") { timerEngine.switchMode(to: .longBreak) }
                .keyboardShortcut("3", modifiers: [])
                .hidden()
        }
    }
    
    private var settingsToggles: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("设置")
                .font(.headline)
                .foregroundColor(.darkGray)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ToggleRow(
                    icon: "bell.fill",
                    title: "通知提醒",
                    isOn: $settingsStore.notificationsEnabled
                )
                
                Divider().padding(.leading, 48)
                
                ToggleRow(
                    icon: "speaker.wave.2.fill",
                    title: "蜂鸣音效",
                    isOn: $settingsStore.soundEnabled
                )
                
                Divider().padding(.leading, 48)
                
                ToggleRow(
                    icon: "hand.tap.fill",
                    title: "触觉反馈",
                    isOn: $settingsStore.hapticsEnabled
                )
                
                Divider().padding(.leading, 48)
                
                ToggleRow(
                    icon: "arrow.right.arrow.left",
                    title: "自动切换",
                    isOn: $settingsStore.autoSwitch
                )
                
                Divider().padding(.leading, 48)
                
                ToggleRow(
                    icon: "sun.max.fill",
                    title: "保持屏幕常亮",
                    isOn: $settingsStore.keepScreenOn
                )
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.tomatoRed)
                    .frame(width: 24)
                Text(title)
                    .foregroundColor(.darkGray)
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let coordinator = AppStateCoordinator.shared
    
    return TimerView(
        timerEngine: coordinator.getTimerEngine(),
        settingsStore: coordinator.getSettingsStore(),
        statsStore: coordinator.getStatsStore()
    )
}

