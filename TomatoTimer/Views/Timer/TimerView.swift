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
    @ObservedObject var gameStore: GameStore
    @ObservedObject var petStore: PetStore
    
    @State private var showingCompletionAlert = false
    @State private var showGameCenter = false
    @State private var showCoinAnimation = false
    @State private var coinAnimationAmount = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 顶部栏：番茄币 + 宠物 widget
                    topBar
                    
                    // 模式选择器
                    HStack {
                    ForEach(TimerMode.allCases) { mode in
                        ModeButton(
                            mode: mode,
                            isSelected: timerEngine.currentMode == mode,
                            isRunning: timerEngine.state == .running,
                            action: {
                                if timerEngine.state != .running {
                                    timerEngine.switchMode(to: mode)
                                }
                            }
                        )
                    }
                }
                .disabled(timerEngine.state == .running)
                .padding(.horizontal)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: timerEngine.currentMode)
                .scaleEffect(timerEngine.state == .running ? 0.98 : 1.0)
                .opacity(timerEngine.state == .running ? 0.7 : 1.0)
                
                // 圆环和倒计时
                ZStack {
                    CircularProgressView(progress: timerEngine.progress, isRunning: timerEngine.state == .running)
                        .frame(width: 300, height: 300)
                    
                    VStack(spacing: 8) {
                        PulsingTimeView(
                            timeString: timeString(from: timerEngine.remainingTime),
                            remainingTime: timerEngine.remainingTime,
                            state: timerEngine.state,
                            isRunning: timerEngine.state == .running
                        )
                        
                        Text(timerEngine.currentMode.displayName)
                            .font(.title3)
                            .foregroundColor(.darkGray.opacity(0.7))
                            .opacity(timerEngine.state == .completed ? 0.8 : 0.7)
                            .scaleEffect(timerEngine.state == .running ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: timerEngine.state)
                    }
                }
                .padding()
                
                // 控制按钮
                controlButtons
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                
                // 设置开关
                settingsToggles
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                
                // 今日统计
                TodayStatsView(statsStore: statsStore)
                    .padding(.horizontal)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                }
                .padding(.vertical)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: timerEngine.state)
            .background(
            Color.lightYellow
                .ignoresSafeArea()
                .overlay(
                    // 完成状态时的庆祝背景
                    Group {
                        if timerEngine.state == .completed {
                            CelebrationBackgroundView()
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                )
        )
        .onChange(of: timerEngine.state) { oldState, newState in
            if newState == .completed && oldState != .completed {
                showingCompletionAlert = true
                // 添加完成时的触觉反馈增强
                if settingsStore.hapticsEnabled {
                    HapticManager.shared.playSuccess()
                }
            }
        }
        .alert("完成！", isPresented: $showingCompletionAlert) {
            Button("好的") {
                showingCompletionAlert = false
            }
        } message: {
            Text("\(timerEngine.currentMode.displayName)时间结束")
        }
        .onChange(of: gameStore.coinBalance) { oldValue, newValue in
            if newValue > oldValue {
                coinAnimationAmount = newValue - oldValue
                showCoinAnimation = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCoinAnimation = false
                }
            }
        }
        .sheet(isPresented: $showGameCenter) {
            GameCenterView(gameStore: gameStore)
        }
        
        // 金币飞入动画
        if showCoinAnimation {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CoinAnimationView(amount: coinAnimationAmount)
                        .padding()
                }
            }
        }
        
        // 成就解锁动画
        if let achievement = gameStore.showAchievementUnlock {
            AchievementUnlockView(achievement: achievement) {
                gameStore.dismissAchievementUnlock()
            }
        }
        
        // 宠物升级动画
        if petStore.showLevelUp {
            levelUpOverlay
        }
        
        // 宠物进化动画
        if petStore.showEvolution {
            evolutionOverlay
        }
        
        // 宠物庆祝动画
        if petStore.showCelebration {
            celebrationOverlay
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // 番茄币 widget
            CoinWidget(gameStore: gameStore)
            
            Spacer()
            
            // 游戏中心按钮
            if timerEngine.state == .idle || timerEngine.state == .paused {
                Button(action: { showGameCenter = true }) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Circle().fill(Color.blue))
                }
            }
            
            // 宠物浮动 widget
            if petStore.hasPet() {
                PetFloatingWidget(petStore: petStore)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Overlays
    private var levelUpOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("🎊")
                    .font(.system(size: 80))
                
                Text("升级了！")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                if let pet = petStore.currentPet {
                    Text("等级 \(pet.level)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.yellow)
                }
                
                Button(action: {
                    petStore.dismissLevelUp()
                }) {
                    Text("太棒了！")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.tomatoRed))
                }
            }
        }
        .onAppear {
            HapticManager.shared.playSuccess()
        }
    }
    
    private var evolutionOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("✨")
                    .font(.system(size: 80))
                
                Text("进化了！")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                if let pet = petStore.currentPet {
                    VStack(spacing: 12) {
                        Text(pet.type.emoji)
                            .font(.system(size: 100))
                        
                        Text(pet.evolutionStage.displayName)
                            .font(.title2.bold())
                            .foregroundColor(.yellow)
                    }
                }
                
                Button(action: {
                    petStore.dismissEvolution()
                }) {
                    Text("继续")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.tomatoRed))
                }
            }
        }
        .onAppear {
            HapticManager.shared.playSuccess()
        }
    }
    
    private var celebrationOverlay: some View {
        FloatingCoinsEffect(count: 10)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    petStore.dismissCelebration()
                }
            }
    }
    
    private var controlButtons: some View {
        VStack(spacing: 16) {
            // 开始/暂停 和 重置
            HStack(spacing: 20) {
                AnimatedButton(
                    action: {
                        if timerEngine.state == .running {
                            timerEngine.pause()
                        } else {
                            timerEngine.start()
                        }
                    },
                    label: {
                        HStack {
                            Image(systemName: timerEngine.state == .running ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text(timerEngine.state == .running ? "暂停" : "开始")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    },
                    style: .primary,
                    isRunning: timerEngine.state == .running
                )
                .accessibleButton(
                    label: timerEngine.state == .running ? "暂停计时器" : "开始计时器",
                    hint: timerEngine.state == .running ? "暂停当前计时" : "开始倒计时"
                )
                .keyboardShortcut(" ", modifiers: [])
                
                AnimatedButton(
                    action: {
                        timerEngine.reset()
                    },
                    label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text("重置")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    },
                    style: .secondary
                )
                .accessibleButton(label: "重置计时器", hint: "将计时器重置到初始状态")
                .keyboardShortcut("r", modifiers: [])
            }
            .padding(.horizontal)
            
            // +5 分钟 和 跳过
            if timerEngine.state != .idle {
                HStack(spacing: 20) {
                    AnimatedButton(
                        action: {
                            timerEngine.addFiveMinutes()
                        },
                        label: {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("加 5 分钟")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        },
                        style: .outline
                    )
                    .accessibleButton(label: "增加 5 分钟", hint: "在当前时间基础上增加 5 分钟")
                    
                    AnimatedButton(
                        action: {
                            timerEngine.skipToNext()
                        },
                        label: {
                            HStack {
                                Image(systemName: "forward.end.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("跳过")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        },
                        style: .outlineSecondary
                    )
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
            HStack {
                Text("设置")
                    .font(.headline)
                    .foregroundColor(.darkGray)
                
                Spacer()
                
                // 快速操作按钮
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "moon.fill",
                        title: "专注模式",
                        isActive: settingsStore.notificationsEnabled && settingsStore.soundEnabled
                    ) {
                        toggleFocusMode()
                    }
                    
                    QuickActionButton(
                        icon: "bolt.fill",
                        title: "快速开始",
                        isActive: false
                    ) {
                        quickStart()
                    }
                    
                    QuickActionButton(
                        icon: "speaker.wave.2.fill",
                        title: "测试声音",
                        isActive: settingsStore.soundEnabled
                    ) {
                        testSound()
                    }
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                AnimatedToggleRow(
                    icon: "bell.fill",
                    title: "通知提醒",
                    isOn: $settingsStore.notificationsEnabled,
                    color: .orange
                )
                
                Divider().padding(.leading, 48)
                
                AnimatedToggleRow(
                    icon: "speaker.wave.2.fill",
                    title: "蜂鸣音效",
                    isOn: $settingsStore.soundEnabled,
                    color: .red
                )
                
                Divider().padding(.leading, 48)
                
                AnimatedToggleRow(
                    icon: "hand.tap.fill",
                    title: "触觉反馈",
                    isOn: $settingsStore.hapticsEnabled,
                    color: .blue
                )
                
                Divider().padding(.leading, 48)
                
                AnimatedToggleRow(
                    icon: "arrow.right.arrow.left",
                    title: "自动切换",
                    isOn: $settingsStore.autoSwitch,
                    color: .green
                )
                
                Divider().padding(.leading, 48)
                
                AnimatedToggleRow(
                    icon: "sun.max.fill",
                    title: "保持屏幕常亮",
                    isOn: $settingsStore.keepScreenOn,
                    color: .yellow
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal)
        }
    }
    
    private func toggleFocusMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            settingsStore.notificationsEnabled.toggle()
            settingsStore.soundEnabled.toggle()
        }
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playSelection()
        }
    }
    
    private func quickStart() {
        if timerEngine.state == .idle {
            timerEngine.start()
        }
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playImpact()
        }
    }
    
    private func testSound() {
        // 测试声音功能
        SoundManager.shared.playTestSound()
        
        // 触觉反馈
        if settingsStore.hapticsEnabled {
            HapticManager.shared.playImpact()
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isActive ? .white : .darkGray)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isActive ? Color.tomatoRed : Color.gray.opacity(0.1))
                            .scaleEffect(pulseScale)
                            .shadow(color: isActive ? Color.tomatoRed.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                    )
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isActive ? .tomatoRed : .darkGray.opacity(0.7))
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
                if pressing {
                    pulseScale = 1.1
                } else {
                    pulseScale = 1.0
                }
            }
        }, perform: {})
        .onAppear {
            if isActive {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
            }
        }
        .onChange(of: isActive) { _, newIsActive in
            if newIsActive {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    pulseScale = 1.0
                }
            }
        }
        .accessibilityLabel(title)
        .accessibilityValue(isActive ? "激活" : "未激活")
    }
}

struct AnimatedToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let color: Color
    
    @State private var isPressed = false
    @State private var glowScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
                .scaleEffect(glowScale)
                .animation(.easeInOut(duration: 0.3), value: glowScale)
            
            Text(title)
                .foregroundColor(.darkGray)
            
            Spacer()
            
            // 自定义开关
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isOn ? color.opacity(0.05) : Color.clear)
                .animation(.easeInOut(duration: 0.3), value: isOn)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            
            isOn.toggle()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onChange(of: isOn) { _, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    glowScale = 1.1
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    glowScale = 1.0
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(isOn ? "开启" : "关闭")")
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

struct CelebrationBackgroundView: View {
    @State private var particles: [CelebrationParticle] = []
    @State private var confettiPapers: [ConfettiPaper] = []
    @State private var animationTrigger = false
    @State private var starBursts: [StarBurst] = []
    @State private var rippleWaves: [RippleWave] = []
    
    var body: some View {
        ZStack {
            backgroundGradient
            rippleWavesView
            starBurstsView
            confettiPapersView
            particlesView
        }
        .onAppear {
            generateCelebrationElements()
            startCelebrationAnimation()
        }
    }
    
    private var backgroundGradient: some View {
            LinearGradient(
                colors: [
                    Color.lightYellow,
                    Color.lightYellow.opacity(0.8),
                    Color.orange.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
    }
            
    private var rippleWavesView: some View {
            ForEach(rippleWaves.indices, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.tomatoRed.opacity(rippleWaves[index].opacity),
                                Color.orange.opacity(rippleWaves[index].opacity * 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: rippleWaves[index].size, height: rippleWaves[index].size)
                    .position(rippleWaves[index].position)
                    .opacity(rippleWaves[index].opacity)
        }
            }
            
    private var starBurstsView: some View {
            ForEach(starBursts.indices, id: \.self) { index in
            starBurstGroup(at: index)
        }
    }
    
    private func starBurstGroup(at index: Int) -> some View {
                ForEach(0..<starBursts[index].starCount, id: \.self) { starIndex in
                    StarShape()
                        .fill(
                            LinearGradient(
                                colors: starBursts[index].colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: starBursts[index].starSize, height: starBursts[index].starSize)
                        .position(starBursts[index].positions[starIndex])
                        .opacity(starBursts[index].opacity)
                .rotationEffect(Angle.degrees(starBursts[index].rotations[starIndex]))
                        .scaleEffect(starBursts[index].scales[starIndex])
                }
            }
            
    private var confettiPapersView: some View {
            ForEach(confettiPapers.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: confettiPapers[index].cornerRadius)
                    .fill(confettiPapers[index].color)
                    .frame(width: confettiPapers[index].width, height: confettiPapers[index].height)
                    .position(confettiPapers[index].position)
                .rotationEffect(Angle.degrees(confettiPapers[index].rotation))
                    .opacity(confettiPapers[index].opacity)
                    .blur(radius: confettiPapers[index].blur)
        }
            }
            
    private var particlesView: some View {
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                particles[index].color.opacity(0.8),
                                particles[index].color.opacity(0.4),
                                particles[index].color.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: particles[index].size / 2
                        )
                    )
                    .frame(width: particles[index].size, height: particles[index].size)
                    .position(particles[index].position)
                    .opacity(particles[index].opacity)
                    .scaleEffect(particles[index].scale)
                    .blur(radius: particles[index].blur)
                    .shadow(color: particles[index].color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
    
    private func generateCelebrationElements() {
        // 生成涟漪波纹
        rippleWaves = (0..<3).map { index in
            RippleWave(
                position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
                size: CGFloat(100 + index * 150),
                opacity: 0.6 - Double(index) * 0.2
            )
        }
        
        // 生成星星爆炸
        starBursts = (0..<5).map { _ in
            StarBurst(
                center: CGPoint(
                    x: CGFloat.random(in: 100...UIScreen.main.bounds.width - 100),
                    y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200)
                ),
                starCount: 8,
                starSize: CGFloat.random(in: 8...15),
                colors: [
                    Color.tomatoRed,
                    Color.orange,
                    Color.yellow,
                    Color.pink
                ].shuffled()
            )
        }
        
        // 生成彩色纸屑
        confettiPapers = (0..<30).map { _ in
            ConfettiPaper(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -50
                ),
                width: CGFloat.random(in: 8...20),
                height: CGFloat.random(in: 15...30),
                color: [
                    Color.tomatoRed,
                    Color.orange,
                    Color.yellow,
                    Color.green,
                    Color.blue,
                    Color.pink
                ].randomElement() ?? .tomatoRed,
                cornerRadius: CGFloat.random(in: 0...4)
            )
        }
        
        // 生成增强的粒子
        particles = (0..<25).map { _ in
            CelebrationParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                    y: UIScreen.main.bounds.height + 50
                ),
                size: CGFloat.random(in: 8...25),
                opacity: Double.random(in: 0.4...0.8),
                scale: 1.0,
                blur: CGFloat.random(in: 0...2),
                color: [
                    Color.tomatoRed,
                    Color.orange,
                    Color.yellow,
                    Color.pink
                ].randomElement() ?? .tomatoRed
            )
        }
    }
    
    private func startCelebrationAnimation() {
        // 动画涟漪波纹
        for (index, wave) in rippleWaves.enumerated() {
            withAnimation(
                .easeOut(duration: 2.0)
                .delay(Double(index) * 0.3)
            ) {
                rippleWaves[index].size = wave.size + 200
                rippleWaves[index].opacity = 0
            }
        }
        
        // 动画星星爆炸
        for (burstIndex, burst) in starBursts.enumerated() {
            let delay = Double.random(in: 0...0.8)
            
            withAnimation(
                .easeOut(duration: 1.5)
                .delay(delay)
            ) {
                starBursts[burstIndex].opacity = 0
                
                for starIndex in 0..<burst.starCount {
                    starBursts[burstIndex].scales[starIndex] = 0.3
                    starBursts[burstIndex].rotations[starIndex] += 360
                }
            }
        }
        
        // 动画彩色纸屑
        for (index, confetti) in confettiPapers.enumerated() {
            withAnimation(
                .linear(duration: Double.random(in: 2.5...4.0))
                .delay(Double.random(in: 0...1.0))
            ) {
                confettiPapers[index].position = CGPoint(
                    x: confetti.position.x + CGFloat.random(in: -150...150),
                    y: UIScreen.main.bounds.height + 100
                )
                confettiPapers[index].rotation += CGFloat.random(in: 360...720)
                confettiPapers[index].opacity = 0
            }
        }
        
        // 动画粒子
        for index in particles.indices {
            withAnimation(
                .easeOut(duration: Double.random(in: 1.5...2.5))
                .delay(Double.random(in: 0...0.5))
            ) {
                particles[index].position = CGPoint(
                    x: particles[index].position.x + CGFloat.random(in: -150...150),
                    y: -50
                )
                particles[index].opacity = 0
                particles[index].scale = 1.8
                particles[index].blur = particles[index].blur + 3
            }
        }
    }
}

struct StarBurst {
    let center: CGPoint
    let starCount: Int
    let starSize: CGFloat
    let colors: [Color]
    
    var positions: [CGPoint] = []
    var scales: [CGFloat] = []
    var rotations: [CGFloat] = []
    var opacity: Double = 1.0
    
    init(center: CGPoint, starCount: Int, starSize: CGFloat, colors: [Color]) {
        self.center = center
        self.starCount = starCount
        self.starSize = starSize
        self.colors = colors
        
        // 计算星星位置（围绕中心点）
        positions = (0..<starCount).map { index in
            let angle = Double(index) * (360.0 / Double(starCount)) * (.pi / 180.0)
            let distance = CGFloat.random(in: 20...60)
            return CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
        }
        
        scales = Array(repeating: 1.0, count: starCount)
        rotations = (0..<starCount).map { _ in CGFloat.random(in: 0...360) }
    }
}

struct ConfettiPaper {
    var position: CGPoint
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let cornerRadius: CGFloat
    var rotation: CGFloat = 0
    var opacity: Double = 1.0
    var blur: CGFloat = 0
}

struct RippleWave {
    let position: CGPoint
    var size: CGFloat
    var opacity: Double
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
            
            path.move(to: CGPoint(x: width * 0.5, y: 0))
            path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.4))
            path.addLine(to: CGPoint(x: width, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.6))
            path.addLine(to: CGPoint(x: width * 0.5, y: height))
            path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.6))
            path.addLine(to: CGPoint(x: 0, y: height * 0.5))
            path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.4))
            path.closeSubpath()
        
        return path
    }
}

struct ModeButton: View {
    let mode: TimerMode
    let isSelected: Bool
    let isRunning: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowScale: CGFloat = 1.0
    @State private var iconOffset: CGFloat = 0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // 背景圆圈
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 60, height: 60)
                        .shadow(color: shadowColor, radius: isSelected ? 8 : 4, x: 0, y: 2)
                        .scaleEffect(isPressed ? 0.95 : glowScale)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                        .animation(.easeInOut(duration: 0.3), value: glowScale)
                    
                    // 图标
                    Image(systemName: modeIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(iconColor)
                        .offset(y: iconOffset)
                        .animation(.easeInOut(duration: 0.3), value: iconOffset)
                }
                
                // 标签
                Text(mode.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(textColor)
                    .animation(.easeInOut(duration: 0.3), value: textColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(containerBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: containerShadowColor, radius: isSelected ? 6 : 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isRunning ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isRunning)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            if isSelected {
                startGlowAnimation()
            }
        }
        .onChange(of: isSelected) { _, newIsSelected in
            if newIsSelected {
                startGlowAnimation()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    iconOffset = -2
                }
                
                // 重置图标位置
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        iconOffset = 0
                    }
                }
            } else {
                stopGlowAnimation()
            }
        }
    }
    
    private var modeIcon: String {
        switch mode {
        case .work:
            return "briefcase.fill"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "couch.fill"
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            switch mode {
            case .work:
                return Color.tomatoRed
            case .shortBreak:
                return Color.orange
            case .longBreak:
                return Color.blue
            }
        } else {
            return Color.white
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return .white
        } else {
            switch mode {
            case .work:
                return Color.tomatoRed
            case .shortBreak:
                return Color.orange
            case .longBreak:
                return Color.blue
            }
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .darkGray
        } else {
            return .darkGray.opacity(0.7)
        }
    }
    
    private var containerBackgroundColor: Color {
        if isSelected {
            return Color.white
        } else {
            return Color.white.opacity(0.8)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            switch mode {
            case .work:
                return Color.tomatoRed
            case .shortBreak:
                return Color.orange
            case .longBreak:
                return Color.blue
            }
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private var shadowColor: Color {
        if isSelected {
            switch mode {
            case .work:
                return Color.tomatoRed.opacity(0.3)
            case .shortBreak:
                return Color.orange.opacity(0.3)
            case .longBreak:
                return Color.blue.opacity(0.3)
            }
        } else {
            return Color.black.opacity(0.1)
        }
    }
    
    private var containerShadowColor: Color {
        if isSelected {
            switch mode {
            case .work:
                return Color.tomatoRed.opacity(0.2)
            case .shortBreak:
                return Color.orange.opacity(0.2)
            case .longBreak:
                return Color.blue.opacity(0.2)
            }
        } else {
            return Color.black.opacity(0.05)
        }
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowScale = 1.05
        }
    }
    
    private func stopGlowAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            glowScale = 1.0
        }
    }
}

struct CelebrationParticle {
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
    var blur: CGFloat
    var color: Color = .tomatoRed
}

enum AnimatedButtonStyle {
    case primary
    case secondary
    case outline
    case outlineSecondary
}

struct AnimatedButton<Label: View>: View {
    let action: () -> Void
    let label: Label
    let style: AnimatedButtonStyle
    let isRunning: Bool
    
    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    @State private var glowIntensity: Double = 0
    
    init(action: @escaping () -> Void, label: () -> Label, style: AnimatedButtonStyle, isRunning: Bool = false) {
        self.action = action
        self.label = label()
        self.style = style
        self.isRunning = isRunning
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // 背景和边框
                backgroundView
                
                // 涟漪效果
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity)
                    .animation(.easeOut(duration: 0.6), value: rippleScale)
                    .animation(.easeOut(duration: 0.6), value: rippleOpacity)
                
                // 按钮内容
                label
                    .foregroundColor(textColor)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                    .shadow(
                        color: shadowColor,
                        radius: isPressed ? 2 : (isRunning ? 8 : 4),
                        x: 0,
                        y: isPressed ? 1 : 2
                    )
                    .scaleEffect(isPressed ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
                    .animation(.easeInOut(duration: 0.3), value: isRunning)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
                if pressing {
                    triggerRipple()
                }
            }
        }, perform: {})
        .onAppear {
            if isRunning && style == .primary {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glowIntensity = 0.3
                }
            }
        }
    }
    
    private var backgroundView: some View {
        Group {
            if style == .primary && isRunning {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.tomatoRed,
                                Color(red: 0.8, green: 0.2, blue: 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(glowIntensity)
            } else {
                EmptyView()
            }
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.tomatoRed
        case .secondary:
            return Color.darkGray.opacity(0.1)
        case .outline, .outlineSecondary:
            return Color.white
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .secondary:
            return Color.clear
        case .outline:
            return Color.tomatoRed
        case .outlineSecondary:
            return Color.darkGray.opacity(0.3)
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outline:
            return 2
        case .outlineSecondary:
            return 1
        default:
            return 0
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .darkGray
        case .outline:
            return .tomatoRed
        case .outlineSecondary:
            return .darkGray
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return Color.tomatoRed.opacity(isRunning ? 0.3 : 0.2)
        case .secondary:
            return Color.black.opacity(0.1)
        case .outline:
            return Color.tomatoRed.opacity(0.2)
        case .outlineSecondary:
            return Color.black.opacity(0.05)
        }
    }
    
    private func triggerRipple() {
        rippleScale = 0
        rippleOpacity = 0.6
        
        withAnimation(.easeOut(duration: 0.6)) {
            rippleScale = 1.5
            rippleOpacity = 0
        }
    }
}

struct PulsingTimeView: View {
    let timeString: String
    let remainingTime: TimeInterval
    let state: TimerState
    let isRunning: Bool
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0
    @State private var urgentPulse: Bool = false
    @State private var timeColor: Color = .darkGray
    
    var body: some View {
        Text(timeString)
            .font(.system(size: 64, weight: .light, design: .rounded))
            .foregroundColor(timeColor)
            .monospacedDigit()
            .scaleEffect(pulseScale)
            .shadow(color: timeColor.opacity(glowOpacity), radius: 10, x: 0, y: 0)
            .accessibilityLabel("剩余时间")
            .accessibilityValue(remainingTime.accessibilityTimeDescription)
            .onAppear {
                startAnimations()
            }
            .onChange(of: isRunning) { _, newIsRunning in
                if newIsRunning {
                    startAnimations()
                } else {
                    stopAnimations()
                }
            }
            .onChange(of: remainingTime) { _, newTime in
                updateTimeColor(for: newTime)
                checkUrgentPulse(for: newTime)
            }
            .onChange(of: state) { _, newState in
                if newState == .completed {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        pulseScale = 1.2
                        timeColor = .tomatoRed
                        glowOpacity = 0.8
                    }
                    
                    // 完成后的脉冲动画
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        pulseScale = 1.3
                        glowOpacity = 0.4
                    }
                }
            }
    }
    
    private func startAnimations() {
        if state == .completed { return }
        
        // 正常运行时的呼吸效果
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
            glowOpacity = 0.1
        }
    }
    
    private func stopAnimations() {
        withAnimation(.easeInOut(duration: 0.3)) {
            pulseScale = 1.0
            glowOpacity = 0
        }
    }
    
    private func updateTimeColor(for time: TimeInterval) {
        let minutes = Int(time) / 60
        
        withAnimation(.easeInOut(duration: 0.5)) {
            if minutes <= 1 && state == .running {
                timeColor = .tomatoRed
            } else if minutes <= 3 && state == .running {
                timeColor = .orange
            } else if state == .completed {
                timeColor = .tomatoRed
            } else {
                timeColor = .darkGray
            }
        }
    }
    
    private func checkUrgentPulse(for time: TimeInterval) {
        let seconds = Int(time)
        let isUrgent = seconds <= 10 && seconds > 0 && state == .running
        
        if isUrgent && !urgentPulse {
            urgentPulse = true
            startUrgentPulse()
        } else if !isUrgent && urgentPulse {
            urgentPulse = false
            stopUrgentPulse()
        }
    }
    
    private func startUrgentPulse() {
        // 最后10秒的紧急脉冲
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
            glowOpacity = 0.6
        }
    }
    
    private func stopUrgentPulse() {
        // 恢复正常呼吸效果
        if isRunning {
            withAnimation(.easeInOut(duration: 0.5)) {
                pulseScale = 1.05
                glowOpacity = 0.1
            }
        }
    }
}

#Preview {
    let coordinator = AppStateCoordinator.shared
    
    return TimerView(
        timerEngine: coordinator.getTimerEngine(),
        settingsStore: coordinator.getSettingsStore(),
        statsStore: coordinator.getStatsStore(),
        gameStore: coordinator.getGameStore(),
        petStore: coordinator.getPetStore()
    )
}

