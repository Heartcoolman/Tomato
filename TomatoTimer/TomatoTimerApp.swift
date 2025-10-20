//
//  TomatoTimerApp.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

@main
struct TomatoTimerApp: App {
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        // 请求通知权限
        Task {
            await NotificationManager.shared.requestAuthorization()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.light)
                .onAppear {
                    // 清除通知角标
                    NotificationManager.shared.clearBadge()
                }
        }
    }
}

