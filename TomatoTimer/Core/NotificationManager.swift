//
//  NotificationManager.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import UserNotifications
import UIKit

@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private override init() {
        super.init()
        checkAuthorization()
    }
    
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            isAuthorized = false
        }
    }
    
    func checkAuthorization() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    func sendCompletionNotification(for mode: TimerMode) {
        let content = UNMutableNotificationContent()
        
        switch mode {
        case .work:
            content.title = "番茄完成！"
            content.body = "工作时间结束，该休息一下了。"
        case .shortBreak:
            content.title = "短休息结束"
            content.body = "休息完毕，准备开始下一个番茄吧！"
        case .longBreak:
            content.title = "长休息结束"
            content.body = "充分休息后，继续加油！"
        }
        
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // 立即触发
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to add notification: \(error)")
            }
        }
        
        // VoiceOver 公告
        UIAccessibility.post(notification: .announcement, argument: content.title)
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}

