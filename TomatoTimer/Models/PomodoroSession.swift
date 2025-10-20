//
//  PomodoroSession.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

struct PomodoroSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let mode: TimerMode
    let duration: TimeInterval
    
    init(id: UUID = UUID(), date: Date = Date(), mode: TimerMode, duration: TimeInterval) {
        self.id = id
        self.date = date
        self.mode = mode
        self.duration = duration
    }
    
    var durationInMinutes: Int {
        Int(duration / 60)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

