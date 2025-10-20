//
//  StatsStore.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation

@MainActor
class StatsStore: ObservableObject {
    @Published private(set) var sessions: [PomodoroSession] = []
    
    private let sessionsKey = "pomodoroSessions"
    
    init() {
        loadSessions()
    }
    
    func addSession(_ session: PomodoroSession) {
        sessions.append(session)
        saveSessions()
    }
    
    func clearAllSessions() {
        sessions.removeAll()
        saveSessions()
    }
    
    // MARK: - Statistics
    
    var todaySessions: [PomodoroSession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return sessions.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    var todayWorkSessions: [PomodoroSession] {
        todaySessions.filter { $0.mode == .work }
    }
    
    var todayPomodoroCount: Int {
        todayWorkSessions.count
    }
    
    var todayTotalMinutes: Int {
        Int(todaySessions.reduce(0) { $0 + $1.duration } / 60)
    }
    
    var thisWeekSessions: [PomodoroSession] {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        return sessions.filter { $0.date >= weekAgo }
    }
    
    var thisWeekPomodoroCount: Int {
        thisWeekSessions.filter { $0.mode == .work }.count
    }
    
    var thisWeekTotalMinutes: Int {
        Int(thisWeekSessions.reduce(0) { $0 + $1.duration } / 60)
    }
    
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        while true {
            let dayStart = calendar.startOfDay(for: checkDate)
            let hasSessions = sessions.contains { session in
                calendar.isDate(session.date, inSameDayAs: dayStart)
            }
            
            if hasSessions {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                // 如果今天还没有记录，允许当天没有
                if calendar.isDateInToday(dayStart) {
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
                    continue
                }
                break
            }
        }
        
        return streak
    }
    
    func sessionsGroupedByDay() -> [(Date, [PomodoroSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    // MARK: - CSV Export
    
    func exportToCSV() -> String {
        var csv = "日期,时间,模式,时长(分钟)\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        for session in sessions.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: session.date)
            let time = timeFormatter.string(from: session.date)
            let mode = session.mode.displayName
            let duration = session.durationInMinutes
            
            csv += "\(date),\(time),\(mode),\(duration)\n"
        }
        
        return csv
    }
    
    // MARK: - Persistence
    
    private func saveSessions() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }
    
    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: sessionsKey) else {
            return
        }
        
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([PomodoroSession].self, from: data) {
            sessions = decoded
        }
    }
}

