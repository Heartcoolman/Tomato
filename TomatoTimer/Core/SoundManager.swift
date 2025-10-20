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
            let session = AVAudioSession.sharedInstance()
            print("Current audio session category: \(session.category.rawValue)")
            print("Current audio session mode: \(session.mode.rawValue)")
            
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth, .duckOthers])
            try session.setActive(true)
            
            print("Audio session configured successfully")
            print("New audio session category: \(session.category.rawValue)")
            print("Audio session is active: \(session.isActive)")
            print("Other audio is playing: \(session.isOtherAudioPlaying)")
        } catch {
            print("Failed to configure audio session: \(error)")
            
            // 尝试使用更简单的配置
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.soloAmbient)
                try session.setActive(true)
                print("Audio session configured with soloAmbient category")
            } catch {
                print("Failed to configure audio session with soloAmbient: \(error)")
            }
        }
    }
    
    func playCompletionSound() {
        print("Attempting to play completion sound...")
        print("Sound enabled setting: \(UserDefaults.standard.bool(forKey: "soundEnabled"))")
        
        // 确保音频会话活跃
        reactivateAudioSession()
        
        // 尝试播放系统声音
        let soundIDs: [SystemSoundID] = [1013, 1005, 1152, 1254, 1103] // 邮件发送、新邮件、短信、锁屏、提醒声音
        
        var soundPlayed = false
        for soundID in soundIDs {
            print("Trying to play system sound ID: \(soundID)")
            AudioServicesPlaySystemSound(soundID)
            soundPlayed = true
            print("Successfully played system sound ID: \(soundID)")
            break // 只播放第一个成功的声音
        }
        
        // 额外的震动反馈（如果设备支持）
        if soundPlayed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                print("Added vibration feedback")
            }
        }
        
        print("Completion sound playback completed")
    }
    
    func playAlertSound() {
        // 使用更常见的系统声音
        AudioServicesPlaySystemSound(1005)
        print("Playing alert sound")
    }
    
    func playClickSound() {
        // 使用键盘点击音
        AudioServicesPlaySystemSound(1104)
        print("Playing click sound")
    }
    
    // 添加一个测试声音的方法
    func playTestSound() {
        print("Testing sound playback...")
        
        // 首先确保音频会话活跃
        reactivateAudioSession()
        
        // 尝试播放系统声音
        AudioServicesPlaySystemSound(1013)
        
        // 如果系统声音不工作，尝试播放一个简单的音频文件
        guard let path = Bundle.main.path(forResource: "test", ofType: "wav") else {
            print("Test sound file not found, trying system sounds only")
            // 尝试其他系统声音
            AudioServicesPlaySystemSound(1005)
            return
        }
        
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
            print("Playing test audio file successfully")
        } catch {
            print("Failed to play test audio file: \(error)")
            // 备用方案：使用系统声音
            AudioServicesPlaySystemSound(1005)
        }
    }
    
    // 重新激活音频会话
    private func reactivateAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            if !session.isOtherAudioPlaying {
                try session.setActive(true)
                print("Reactivated audio session")
            }
        } catch {
            print("Failed to reactivate audio session: \(error)")
        }
    }
}

