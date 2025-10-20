//
//  HistoryView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var statsStore: StatsStore
    
    @State private var showingExportSheet = false
    @State private var csvDocument: CSVFile?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 周统计
                WeekStatsView(statsStore: statsStore)
                    .padding(.horizontal)
                
                // 按天分组的历史记录
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("历史记录")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.darkGray)
                        
                        Spacer()
                        
                        Button {
                            exportToCSV()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("导出")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.tomatoRed)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .accessibleButton(label: "导出为 CSV", hint: "将历史数据导出为 CSV 文件")
                    }
                    .padding(.horizontal)
                    
                    if statsStore.sessions.isEmpty {
                        EmptyHistoryView()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(statsStore.sessionsGroupedByDay(), id: \.0) { date, sessions in
                                DaySessionCard(date: date, sessions: sessions)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .padding(.vertical)
        }
        .background(Color.lightYellow.ignoresSafeArea())
        .fileExporter(
            isPresented: $showingExportSheet,
            document: csvDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "番茄工作法统计_\(formattedDate()).csv"
        ) { result in
            switch result {
            case .success(let url):
                print("CSV exported to: \(url)")
            case .failure(let error):
                print("Export failed: \(error)")
            }
        }
    }
    
    private func exportToCSV() {
        let csvContent = statsStore.exportToCSV()
        csvDocument = CSVFile(content: csvContent)
        showingExportSheet = true
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

struct DaySessionCard: View {
    let date: Date
    let sessions: [PomodoroSession]
    
    var workSessions: [PomodoroSession] {
        sessions.filter { $0.mode == .work }
    }
    
    var totalMinutes: Int {
        Int(sessions.reduce(0) { $0 + $1.duration } / 60)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.headline)
                        .foregroundColor(.darkGray)
                    
                    Text(relativeDateString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Label("\(workSessions.count)", systemImage: "circle.fill")
                        .foregroundColor(.tomatoRed)
                        .font(.subheadline)
                    
                    Label("\(totalMinutes) 分钟", systemImage: "clock.fill")
                        .foregroundColor(.darkGray)
                        .font(.subheadline)
                }
            }
            
            // 番茄圆点
            if !workSessions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(workSessions.prefix(10)) { _ in
                        Circle()
                            .fill(Color.tomatoRed)
                            .frame(width: 12, height: 12)
                    }
                    
                    if workSessions.count > 10 {
                        Text("+\(workSessions.count - 10)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(formattedDate)，完成 \(workSessions.count) 个番茄，共 \(totalMinutes) 分钟")
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "今天"
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: Date()).day ?? 0
            return "\(days) 天前"
        }
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("暂无历史记录")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("完成第一个番茄后，记录将显示在这里")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    HistoryView(statsStore: StatsStore())
}

