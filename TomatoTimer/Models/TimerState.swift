//
//  TimerState.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

enum TimerState: String, Codable {
    case idle
    case running
    case paused
    case completed
    
    var displayName: String {
        switch self {
        case .idle:
            return "待机"
        case .running:
            return "运行中"
        case .paused:
            return "已暂停"
        case .completed:
            return "已完成"
        }
    }
}

