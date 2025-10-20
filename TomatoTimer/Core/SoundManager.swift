//
//  SoundManager.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import AVFoundation
import AudioToolbox

@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    func playCompletionSound() {
        // 使用系统声音作为简单实现
        // SystemSoundID 1013 是邮件发送成功的声音
        AudioServicesPlaySystemSound(1013)
    }
    
    func playAlertSound() {
        // SystemSoundID 1005 是新邮件提醒音
        AudioServicesPlaySystemSound(1005)
    }
    
    func playClickSound() {
        // SystemSoundID 1104 是键盘点击音
        AudioServicesPlaySystemSound(1104)
    }
}

