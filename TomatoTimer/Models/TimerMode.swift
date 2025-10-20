//
//  TimerMode.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

enum TimerMode: String, Codable, CaseIterable, Identifiable {
    case work
    case shortBreak
    case longBreak
    
    var id: String { rawValue }
    
    var defaultDuration: TimeInterval {
        switch self {
        case .work:
            return 25 * 60
        case .shortBreak:
            return 5 * 60
        case .longBreak:
            return 15 * 60
        }
    }
    
    var displayName: String {
        switch self {
        case .work:
            return "工作"
        case .shortBreak:
            return "短休息"
        case .longBreak:
            return "长休息"
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .work:
            return "工作模式"
        case .shortBreak:
            return "短休息模式"
        case .longBreak:
            return "长休息模式"
        }
    }
}

