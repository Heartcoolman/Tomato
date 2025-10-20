//
//  SettingsView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    @State private var showingResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 时长设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("时长设置")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.darkGray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        DurationStepper(
                            title: "工作时长",
                            icon: "💼",
                            value: $settingsStore.workDurationMinutes,
                            range: 1...60
                        )
                        
                        Divider().padding(.leading, 48)
                        
                        DurationStepper(
                            title: "短休息时长",
                            icon: "☕️",
                            value: $settingsStore.shortBreakDurationMinutes,
                            range: 1...30
                        )
                        
                        Divider().padding(.leading, 48)
                        
                        DurationStepper(
                            title: "长休息时长",
                            icon: "🌴",
                            value: $settingsStore.longBreakDurationMinutes,
                            range: 1...60
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // 偏好设置
                VStack(alignment: .leading, spacing: 16) {
                    Text("偏好设置")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.darkGray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        PreferenceToggle(
                            title: "自动切换模式",
                            icon: "arrow.right.arrow.left.circle.fill",
                            description: "完成后自动切换到下一个阶段",
                            isOn: $settingsStore.autoSwitch
                        )
                        
                        Divider().padding(.leading, 48)
                        
                        PreferenceToggle(
                            title: "自动开始",
                            icon: "play.circle.fill",
                            description: "切换后自动开始计时",
                            isOn: $settingsStore.autoStart
                        )
                        
                        Divider().padding(.leading, 48)
                        
                        PreferenceToggle(
                            title: "通知提醒",
                            icon: "bell.circle.fill",
                            description: "完成时发送通知",
                            isOn: $settingsStore.notificationsEnabled
                        )
                        
                        Divider().padding(.leading, 48)
                        
                        PreferenceToggle(
                            title: "蜂鸣音效",
                            icon: "speaker.wave.2.circle.fill",
                            description: "完成时播放声音",
                            isOn: $settingsStore.soundEnabled
                        )
                        
                        Divider().padding(.leading, 48)
                        
                        PreferenceToggle(
                            title: "触觉反馈",
                            icon: "hand.tap.fill",
                            description: "操作时提供震动反馈",
                            isOn: $settingsStore.hapticsEnabled
                        )
                        
                        Divider().padding(.leading, 48)
                        
                        PreferenceToggle(
                            title: "保持屏幕常亮",
                            icon: "sun.max.circle.fill",
                            description: "计时时禁用自动锁屏",
                            isOn: $settingsStore.keepScreenOn
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // 重置按钮
                Button {
                    showingResetAlert = true
                } label: {
                    Text("恢复默认设置")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .accessibleButton(label: "恢复默认设置", hint: "将所有设置恢复到初始值")
                
                // 关于信息
                VStack(spacing: 8) {
                    Text("番茄工作法计时器")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("版本 1.0.0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("每 4 个工作番茄后自动进入长休息")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color.lightYellow.ignoresSafeArea())
        .alert("恢复默认设置", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("恢复", role: .destructive) {
                settingsStore.resetToDefaults()
            }
        } message: {
            Text("这将恢复所有设置到默认值。此操作无法撤销。")
        }
    }
}

struct DurationStepper: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.darkGray)
                    .font(.body)
            }
            
            Spacer()
            
            Stepper(value: $value, in: range) {
                Text("\(value) 分钟")
                    .foregroundColor(.tomatoRed)
                    .fontWeight(.medium)
                    .frame(minWidth: 80, alignment: .trailing)
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) 分钟")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                if value < range.upperBound {
                    value += 1
                }
            case .decrement:
                if value > range.lowerBound {
                    value -= 1
                }
            @unknown default:
                break
            }
        }
    }
}

struct PreferenceToggle: View {
    let title: String
    let icon: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.tomatoRed)
                    .frame(width: 32)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .foregroundColor(.darkGray)
                        .font(.body)
                    
                    Text(description)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(description)
    }
}

#Preview {
    SettingsView(settingsStore: SettingsStore())
}

