//
//  HapticManager.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import UIKit

@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    func playSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    func playWarning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    func playError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    func playImpact() {
        impactGenerator.impactOccurred()
    }
    
    func playSelection() {
        selectionGenerator.selectionChanged()
    }
}

