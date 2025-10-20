//
//  TimerEngineTests.swift
//  TomatoTimerTests
//
//  Created by AI Assistant
//

import XCTest
@testable import TomatoTimer

@MainActor
final class TimerEngineTests: XCTestCase {
    var timerEngine: TimerEngine!
    var settingsStore: SettingsStore!
    var statsStore: StatsStore!
    
    override func setUp() async throws {
        settingsStore = SettingsStore()
        statsStore = StatsStore()
        timerEngine = TimerEngine(settingsStore: settingsStore, statsStore: statsStore)
    }
    
    override func tearDown() {
        timerEngine = nil
        settingsStore = nil
        statsStore = nil
    }
    
    func testInitialState() {
        XCTAssertEqual(timerEngine.state, .idle)
        XCTAssertEqual(timerEngine.currentMode, .work)
        XCTAssertEqual(timerEngine.remainingTime, 25 * 60, accuracy: 1.0)
        XCTAssertEqual(timerEngine.workSessionsCount, 0)
    }
    
    func testStartTimer() {
        timerEngine.start()
        
        XCTAssertEqual(timerEngine.state, .running)
        XCTAssertGreaterThan(timerEngine.remainingTime, 0)
    }
    
    func testPauseTimer() {
        timerEngine.start()
        let timeBeforePause = timerEngine.remainingTime
        
        // Wait a bit
        let expectation = expectation(description: "Wait for tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        timerEngine.pause()
        
        XCTAssertEqual(timerEngine.state, .paused)
        XCTAssertLessThan(timerEngine.remainingTime, timeBeforePause)
    }
    
    func testResetTimer() {
        timerEngine.start()
        
        // Wait a bit
        let expectation = expectation(description: "Wait for tick")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        timerEngine.reset()
        
        XCTAssertEqual(timerEngine.state, .idle)
        XCTAssertEqual(timerEngine.remainingTime, 25 * 60, accuracy: 1.0)
    }
    
    func testAddFiveMinutes() {
        timerEngine.start()
        let initialTime = timerEngine.remainingTime
        
        timerEngine.addFiveMinutes()
        
        XCTAssertEqual(timerEngine.remainingTime, initialTime + 5 * 60, accuracy: 1.0)
    }
    
    func testSwitchMode() {
        timerEngine.switchMode(to: .shortBreak)
        
        XCTAssertEqual(timerEngine.currentMode, .shortBreak)
        XCTAssertEqual(timerEngine.remainingTime, 5 * 60, accuracy: 1.0)
    }
    
    func testProgress() {
        timerEngine.start()
        
        let progress = timerEngine.progress
        XCTAssertGreaterThanOrEqual(progress, 0)
        XCTAssertLessThanOrEqual(progress, 1)
    }
    
    func testAdjustCurrentModeDuration() {
        let initialDuration = timerEngine.remainingTime
        
        timerEngine.adjustCurrentModeDuration(by: 5)
        
        XCTAssertEqual(timerEngine.remainingTime, initialDuration + 5 * 60, accuracy: 1.0)
    }
}

