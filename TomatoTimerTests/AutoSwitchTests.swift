//
//  AutoSwitchTests.swift
//  TomatoTimerTests
//
//  Created by AI Assistant
//

import XCTest
@testable import TomatoTimer

@MainActor
final class AutoSwitchTests: XCTestCase {
    var timerEngine: TimerEngine!
    var settingsStore: SettingsStore!
    var statsStore: StatsStore!
    
    override func setUp() async throws {
        settingsStore = SettingsStore()
        statsStore = StatsStore()
        let gameStore = GameStore()
        let petStore = PetStore()
        timerEngine = TimerEngine(
            settingsStore: settingsStore,
            statsStore: statsStore,
            gameStore: gameStore,
            petStore: petStore
        )
        
        // 启用自动切换
        settingsStore.autoSwitch = true
    }
    
    override func tearDown() {
        timerEngine = nil
        settingsStore = nil
        statsStore = nil
    }
    
    func testWorkToShortBreakSwitch() {
        // 开始工作模式
        XCTAssertEqual(timerEngine.currentMode, .work)
        
        // 模拟完成，跳到下一个
        timerEngine.skipToNext()
        
        // 应该切换到短休息
        XCTAssertEqual(timerEngine.currentMode, .shortBreak)
        XCTAssertEqual(timerEngine.workSessionsCount, 1)
    }
    
    func testShortBreakToWorkSwitch() {
        // 切换到短休息
        timerEngine.switchMode(to: .shortBreak)
        
        // 跳到下一个
        timerEngine.skipToNext()
        
        // 应该切换回工作
        XCTAssertEqual(timerEngine.currentMode, .work)
    }
    
    func testLongBreakAfterFourSessions() {
        // 完成 3 个工作番茄
        for _ in 0..<3 {
            timerEngine.switchMode(to: .work)
            timerEngine.skipToNext() // 完成工作
            timerEngine.skipToNext() // 完成短休息
        }
        
        // 完成第 4 个工作番茄
        timerEngine.switchMode(to: .work)
        timerEngine.skipToNext()
        
        // 应该切换到长休息
        XCTAssertEqual(timerEngine.currentMode, .longBreak)
        XCTAssertEqual(timerEngine.workSessionsCount, 4)
    }
    
    func testLongBreakToWorkSwitch() {
        // 设置为长休息
        timerEngine.switchMode(to: .longBreak)
        
        // 跳到下一个
        timerEngine.skipToNext()
        
        // 应该切换回工作
        XCTAssertEqual(timerEngine.currentMode, .work)
    }
    
    func testWorkSessionCount() {
        XCTAssertEqual(timerEngine.workSessionsCount, 0)
        
        // 完成一个工作番茄
        timerEngine.switchMode(to: .work)
        timerEngine.skipToNext()
        
        XCTAssertEqual(timerEngine.workSessionsCount, 1)
        
        // 完成休息不应增加计数
        timerEngine.skipToNext()
        
        XCTAssertEqual(timerEngine.workSessionsCount, 1)
    }
}

