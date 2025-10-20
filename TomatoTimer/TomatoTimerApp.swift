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
            MainView(sceneID: UUID().uuidString)
                .preferredColorScheme(.light)
                .onAppear {
                    // 清除通知角标
                    NotificationManager.shared.clearBadge()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                NotificationCenter.default.post(
                    name: NSNotification.Name("SceneDidBecomeActive"),
                    object: nil,
                    userInfo: ["sceneID": UUID().uuidString]
                )
            case .background:
                // 应用进入后台，确保状态已保存
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}

