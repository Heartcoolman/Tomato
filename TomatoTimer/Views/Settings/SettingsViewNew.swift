//
//  SettingsViewNew.swift
//  TomatoTimer
//
//  Modern settings view with card-based layout
//

import SwiftUI

struct SettingsViewNew: View {
    @ObservedObject var settingsStore: SettingsStore
    @State private var showingResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xxxl) {
                // Header
                header
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                    .padding(.top, DesignTokens.Spacing.xl)
                
                // Duration settings
                durationSection
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                
                // Preferences
                preferencesSection
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                
                // Reset button
                resetSection
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                
                // About
                aboutSection
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                    .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
        }
        .background(Color.backgroundGradient.ignoresSafeArea())
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                settingsStore.resetToDefaults()
            }
        } message: {
            Text("This will restore all settings to their default values. This action cannot be undone.")
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text("Settings")
                .font(DesignTokens.Typography.largeTitle)
                .foregroundColor(.neutralGray)
            
            Text("Customize your experience")
                .font(DesignTokens.Typography.caption)
                .foregroundColor(.neutralMid)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Duration Section
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Session Durations")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(.neutralGray)
            
            GlassCard(padding: 0) {
                VStack(spacing: 0) {
                    DurationSettingRow(
                        icon: "💼",
                        title: "Work Session",
                        value: $settingsStore.workDurationMinutes,
                        range: 1...60,
                        color: .workMode
                    )
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    DurationSettingRow(
                        icon: "☕️",
                        title: "Short Break",
                        value: $settingsStore.shortBreakDurationMinutes,
                        range: 1...30,
                        color: .shortBreakMode
                    )
                    
                    Divider()
                        .padding(.leading, 60)
                    
                    DurationSettingRow(
                        icon: "🌴",
                        title: "Long Break",
                        value: $settingsStore.longBreakDurationMinutes,
                        range: 1...60,
                        color: .longBreakMode
                    )
                }
            }
        }
    }
    
    // MARK: - Preferences Section
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Preferences")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(.neutralGray)
            
            VStack(spacing: DesignTokens.Spacing.md) {
                // Auto switch
                PreferenceCard(
                    icon: "arrow.right.arrow.left.circle.fill",
                    title: "Auto Switch",
                    description: "Automatically switch to next session when completed",
                    isOn: $settingsStore.autoSwitch,
                    color: .success
                )
                
                // Auto start
                PreferenceCard(
                    icon: "play.circle.fill",
                    title: "Auto Start",
                    description: "Automatically start timer after switching",
                    isOn: $settingsStore.autoStart,
                    color: .secondary
                )
                
                // Notifications
                PreferenceCard(
                    icon: "bell.circle.fill",
                    title: "Notifications",
                    description: "Show notifications when session completes",
                    isOn: $settingsStore.notificationsEnabled,
                    color: .primary
                )
                
                // Sound
                PreferenceCard(
                    icon: "speaker.wave.2.circle.fill",
                    title: "Sound Effects",
                    description: "Play sound when session completes",
                    isOn: $settingsStore.soundEnabled,
                    color: .warning
                )
                
                // Haptics
                PreferenceCard(
                    icon: "hand.tap.fill",
                    title: "Haptic Feedback",
                    description: "Provide haptic feedback for actions",
                    isOn: $settingsStore.hapticsEnabled,
                    color: .secondary
                )
                
                // Keep screen on
                PreferenceCard(
                    icon: "sun.max.circle.fill",
                    title: "Keep Screen On",
                    description: "Prevent screen from sleeping during sessions",
                    isOn: $settingsStore.keepScreenOn,
                    color: .warning
                )
            }
        }
    }
    
    // MARK: - Reset Section
    
    private var resetSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            ProfessionalButton(
                icon: "arrow.counterclockwise.circle.fill",
                title: "Reset to Defaults",
                style: .tertiary
            ) {
                showingResetAlert = true
            }
            
            Text("This will restore all settings to their original values")
                .font(.system(size: 12))
                .foregroundColor(.neutralMid)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        GlassCard {
            VStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "timer")
                    .font(.system(size: 48))
                    .foregroundColor(.primary)
                
                Text("Pomodoro Timer")
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(.neutralGray)
                
                Text("Version 2.0.0")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(.neutralMid)
                
                Divider()
                    .padding(.vertical, DesignTokens.Spacing.xs)
                
                Text("Built with iPadOS 26 Liquid Glass Design")
                    .font(.system(size: 11))
                    .foregroundColor(.neutralLight)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Duration Setting Row

struct DurationSettingRow: View {
    let icon: String
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let color: Color
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            Text(icon)
                .font(.system(size: 28))
                .frame(width: 44)
            
            // Title
            Text(title)
                .font(DesignTokens.Typography.body)
                .foregroundColor(.neutralGray)
            
            Spacer()
            
            // Stepper
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button {
                    if value > range.lowerBound {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(value > range.lowerBound ? color : .neutralLight)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(color)
                    .frame(width: 40)
                
                Button {
                    if value < range.upperBound {
                        value += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(value < range.upperBound ? color : .neutralLight)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(value >= range.upperBound)
            }
        }
        .padding(DesignTokens.Spacing.md)
    }
}

// MARK: - Preference Card

struct PreferenceCard: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        GlassCard(padding: DesignTokens.Spacing.md, useMaterial: false) {
            HStack(spacing: DesignTokens.Spacing.md) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: DesignTokens.IconSize.large))
                    .foregroundColor(color)
                    .frame(width: 44)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.neutralGray)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.neutralMid)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(color)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsViewNew(settingsStore: SettingsStore())
}

