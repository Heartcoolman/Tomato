//
//  TimerViewNew.swift
//  TomatoTimer
//
//  Professional Timer View with iPadOS 26 Design
//

import SwiftUI

struct TimerViewNew: View {
    @ObservedObject var timerEngine: TimerEngine
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var statsStore: StatsStore
    
    @State private var showingCompletionAlert = false
    @State private var showingSettings = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 900 {
                // Wide layout - Three column
                wideLayout
            } else {
                // Compact layout - Single column
                compactLayout
            }
        }
        .background(backgroundView)
        .onChange(of: timerEngine.state) { oldState, newState in
            handleStateChange(from: oldState, to: newState)
        }
        .alert("Completed!", isPresented: $showingCompletionAlert) {
            Button("OK") {
                showingCompletionAlert = false
            }
        } message: {
            Text("\(timerEngine.currentMode.displayName) session completed")
        }
    }
    
    // MARK: - Wide Layout (iPad)
    
    private var wideLayout: some View {
        HStack(spacing: 0) {
            // Left: Mode selector
            VStack {
                Spacer()
                
                MinimalModeSelector(
                    timerEngine: timerEngine,
                    isDisabled: timerEngine.state == .running
                )
                .frame(maxWidth: 300)
                .padding(DesignTokens.Spacing.lg)
                
                Spacer()
            }
            .frame(width: 320)
            
            // Center: Timer
            VStack(spacing: DesignTokens.Spacing.xxxl) {
                Spacer()
                
                // Timer ring and display
                ZStack {
                    LiquidProgressRing(
                        progress: timerEngine.progress,
                        size: DesignTokens.Layout.timerRingSize,
                        isRunning: timerEngine.state == .running,
                        mode: timerEngine.currentMode
                    )
                    
                    ProfessionalTimeDisplay(
                        timeString: timeString(from: timerEngine.remainingTime),
                        remainingTime: timerEngine.remainingTime,
                        state: timerEngine.state,
                        mode: timerEngine.currentMode
                    )
                }
                
                // Control panel
                ProfessionalControlPanel(
                    timerEngine: timerEngine,
                    settingsStore: settingsStore
                )
                .frame(maxWidth: 500)
                .padding(.horizontal, DesignTokens.Spacing.xxxl)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // Right: Stats card
            VStack {
                Spacer()
                
                FloatingStatsCard(statsStore: statsStore)
                    .padding(DesignTokens.Spacing.lg)
                
                Spacer()
            }
            .frame(width: 360)
        }
    }
    
    // MARK: - Compact Layout (iPhone)
    
    private var compactLayout: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xxxl) {
                // Mode selector
                MinimalModeSelector(
                    timerEngine: timerEngine,
                    isDisabled: timerEngine.state == .running
                )
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.xl)
                
                // Timer ring and display
                ZStack {
                    LiquidProgressRing(
                        progress: timerEngine.progress,
                        size: DesignTokens.Layout.timerRingSizeCompact,
                        lineWidth: 20,
                        isRunning: timerEngine.state == .running,
                        mode: timerEngine.currentMode
                    )
                    
                    ProfessionalTimeDisplay(
                        timeString: timeString(from: timerEngine.remainingTime),
                        remainingTime: timerEngine.remainingTime,
                        state: timerEngine.state,
                        mode: timerEngine.currentMode
                    )
                }
                .padding(.vertical, DesignTokens.Spacing.lg)
                
                // Control panel
                ProfessionalControlPanel(
                    timerEngine: timerEngine,
                    settingsStore: settingsStore
                )
                .padding(.horizontal, DesignTokens.Spacing.lg)
                
                // Stats card
                FloatingStatsCard(statsStore: statsStore)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                
                // Quick settings (collapsible)
                quickSettings
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Quick Settings
    
    private var quickSettings: some View {
        GlassCard {
            VStack(spacing: DesignTokens.Spacing.md) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: DesignTokens.IconSize.medium))
                        .foregroundColor(.primary)
                    
                    Text("Quick Settings")
                        .font(DesignTokens.Typography.title3)
                        .foregroundColor(.neutralGray)
                    
                    Spacer()
                }
                
                Divider()
                
                // Essential toggles
                QuickToggle(
                    icon: "bell.fill",
                    title: "Notifications",
                    isOn: $settingsStore.notificationsEnabled,
                    color: .primary
                )
                
                QuickToggle(
                    icon: "speaker.wave.2.fill",
                    title: "Sound",
                    isOn: $settingsStore.soundEnabled,
                    color: .secondary
                )
                
                QuickToggle(
                    icon: "arrow.right.arrow.left.circle.fill",
                    title: "Auto Switch",
                    isOn: $settingsStore.autoSwitch,
                    color: .success
                )
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundView: some View {
        ZStack {
            // Base gradient
            Color.backgroundGradient
                .ignoresSafeArea()
            
            // Completion celebration
            if timerEngine.state == .completed {
                CompletionCelebration(mode: timerEngine.currentMode)
                    .transition(DesignTokens.Transition.blurReplace)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func handleStateChange(from oldState: TimerState, to newState: TimerState) {
        if newState == .completed && oldState != .completed {
            showingCompletionAlert = true
            
            if settingsStore.hapticsEnabled {
                HapticManager.shared.playSuccess()
            }
            
            if settingsStore.soundEnabled {
                SoundManager.shared.playCompletionSound()
            }
        }
    }
}

// MARK: - Quick Toggle

struct QuickToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: DesignTokens.IconSize.medium))
                    .foregroundColor(color)
                    .frame(width: DesignTokens.IconSize.large)
                
                Text(title)
                    .font(DesignTokens.Typography.body)
                    .foregroundColor(.neutralGray)
            }
        }
        .tint(color)
    }
}

// MARK: - Completion Celebration

struct CompletionCelebration: View {
    let mode: TimerMode
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Subtle gradient overlay
            RadialGradient(
                colors: [
                    celebrationColor.opacity(0.15),
                    celebrationColor.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 500
            )
            .ignoresSafeArea()
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.celebration) {
                opacity = 1
                scale = 1.2
            }
        }
    }
    
    private var celebrationColor: Color {
        switch mode {
        case .work:
            return Color.workMode
        case .shortBreak:
            return Color.shortBreakMode
        case .longBreak:
            return Color.longBreakMode
        }
    }
}

// MARK: - Preview

#Preview("Wide Layout") {
    TimerViewNew(
        timerEngine: TimerEngine(
            settingsStore: SettingsStore(),
            statsStore: StatsStore()
        ),
        settingsStore: SettingsStore(),
        statsStore: StatsStore()
    )
    .frame(width: 1200, height: 800)
}

#Preview("Compact Layout") {
    TimerViewNew(
        timerEngine: TimerEngine(
            settingsStore: SettingsStore(),
            statsStore: StatsStore()
        ),
        settingsStore: SettingsStore(),
        statsStore: StatsStore()
    )
    .frame(width: 400, height: 800)
}

