//
//  HistoryViewNew.swift
//  TomatoTimer
//
//  Enhanced history view with data visualization
//

import SwiftUI

struct HistoryViewNew: View {
    @ObservedObject var statsStore: StatsStore
    
    @State private var showingExportSheet = false
    @State private var csvDocument: CSVFile?
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xxxl) {
                // Header with time range selector
                header
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                    .padding(.top, DesignTokens.Spacing.xl)
                
                // Insights cards
                insightsSection
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                
                // Week stats visualization
                weekStatsSection
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                
                // History list
                historySection
                    .padding(.horizontal, DesignTokens.Spacing.screenEdge)
                    .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
        }
        .background(Color.backgroundGradient.ignoresSafeArea())
        .fileExporter(
            isPresented: $showingExportSheet,
            document: csvDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "pomodoro-stats-\(formattedDate()).csv"
        ) { result in
            switch result {
            case .success(let url):
                print("CSV exported to: \(url)")
            case .failure(let error):
                print("Export failed: \(error)")
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text("History")
                    .font(DesignTokens.Typography.largeTitle)
                    .foregroundColor(.neutralGray)
                
                Text("Track your productivity")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(.neutralMid)
            }
            
            Spacer()
            
            // Export button
            ProfessionalButton(
                icon: "square.and.arrow.up",
                title: "Export",
                style: .tertiary,
                compact: true
            ) {
                exportToCSV()
            }
        }
    }
    
    // MARK: - Insights Section
    
    private var insightsSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.md) {
                InsightCard(
                    title: "Total Sessions",
                    value: "\(totalSessions)",
                    icon: "circle.fill",
                    color: .primary,
                    trend: nil
                )
                
                InsightCard(
                    title: "Total Hours",
                    value: String(format: "%.1f", totalHours),
                    icon: "clock.fill",
                    color: .secondary,
                    trend: nil
                )
            }
            
            HStack(spacing: DesignTokens.Spacing.md) {
                InsightCard(
                    title: "Current Streak",
                    value: "\(statsStore.currentStreak)",
                    icon: "flame.fill",
                    color: .warning,
                    trend: nil
                )
                
                InsightCard(
                    title: "Avg per Day",
                    value: String(format: "%.1f", averagePerDay),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .success,
                    trend: nil
                )
            }
        }
    }
    
    // MARK: - Week Stats
    
    private var weekStatsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text("This Week")
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(.neutralGray)
                
                // Simple bar chart
                weekBarChart
            }
        }
    }
    
    private var weekBarChart: some View {
        HStack(alignment: .bottom, spacing: DesignTokens.Spacing.sm) {
            ForEach(last7Days(), id: \.0) { day, count in
                VStack(spacing: DesignTokens.Spacing.xxs) {
                    // Bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            count > 0 ?
                            Color.primaryGradient :
                            LinearGradient(
                                colors: [Color.neutralSuperLight],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: barHeight(for: count))
                        .frame(maxWidth: .infinity)
                    
                    // Label
                    Text(dayLabel(for: day))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.neutralMid)
                }
            }
        }
        .frame(height: 120)
    }
    
    // MARK: - History Section
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("Recent Sessions")
                .font(DesignTokens.Typography.title3)
                .foregroundColor(.neutralGray)
            
            if statsStore.sessions.isEmpty {
                EmptyHistoryCard()
            } else {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(statsStore.sessionsGroupedByDay().prefix(10), id: \.0) { date, sessions in
                        DaySessionCardNew(date: date, sessions: sessions)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var totalSessions: Int {
        statsStore.sessions.filter { $0.mode == .work }.count
    }
    
    private var totalHours: Double {
        Double(statsStore.sessions.reduce(0) { $0 + $1.duration }) / 3600.0
    }
    
    private var averagePerDay: Double {
        let days = Set(statsStore.sessions.map { Calendar.current.startOfDay(for: $0.date) }).count
        guard days > 0 else { return 0 }
        return Double(totalSessions) / Double(days)
    }
    
    private func last7Days() -> [(Date, Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { (dayOffset: Int) -> (Date, Int) in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let count = statsStore.sessions.filter {
                calendar.isDate($0.date, inSameDayAs: date) && $0.mode == .work
            }.count
            return (date, count)
        }.reversed()
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        let maxCount = last7Days().map { $0.1 }.max() ?? 1
        guard maxCount > 0 else { return 20 }
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return max(20, 100 * ratio)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date).prefix(1).uppercased()
    }
    
    private func exportToCSV() {
        let csvContent = statsStore.exportToCSV()
        csvDocument = CSVFile(text: csvContent)
        showingExportSheet = true
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - Insight Card

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: Double?
    
    var body: some View {
        GlassCard(padding: DesignTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: DesignTokens.IconSize.medium))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    if let trend = trend {
                        TrendIndicator(value: trend)
                    }
                }
                
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.neutralGray)
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.neutralMid)
            }
        }
    }
}

// MARK: - Trend Indicator

struct TrendIndicator: View {
    let value: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: value >= 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 10, weight: .semibold))
            
            Text(String(format: "%.1f%%", abs(value)))
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(value >= 0 ? .success : .error)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill((value >= 0 ? Color.success : Color.error).opacity(0.15))
        )
    }
}

// MARK: - Day Session Card New

struct DaySessionCardNew: View {
    let date: Date
    let sessions: [PomodoroSession]
    
    var workSessions: [PomodoroSession] {
        sessions.filter { $0.mode == .work }
    }
    
    var totalMinutes: Int {
        Int(sessions.reduce(0) { $0 + $1.duration } / 60)
    }
    
    var body: some View {
        GlassCard(padding: DesignTokens.Spacing.md, useMaterial: false) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(formattedDate)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.neutralGray)
                    
                    Text(relativeDateString)
                        .font(DesignTokens.Typography.caption)
                        .foregroundColor(.neutralMid)
                }
                
                Spacer()
                
                HStack(spacing: DesignTokens.Spacing.md) {
                    Label("\(workSessions.count)", systemImage: "circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Label("\(totalMinutes)m", systemImage: "clock.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.neutralMid)
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
            return "\(days) days ago"
        }
    }
}

// MARK: - Empty History Card

struct EmptyHistoryCard: View {
    var body: some View {
        GlassCard {
            VStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 48))
                    .foregroundColor(.neutralMid.opacity(0.5))
                
                Text("No history yet")
                    .font(DesignTokens.Typography.title3)
                    .foregroundColor(.neutralMid)
                
                Text("Complete your first pomodoro session\nto see your history here")
                    .font(DesignTokens.Typography.caption)
                    .foregroundColor(.neutralLight)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.xxxl)
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryViewNew(statsStore: StatsStore())
}

