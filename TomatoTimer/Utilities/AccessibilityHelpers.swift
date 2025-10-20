//
//  AccessibilityHelpers.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

extension TimeInterval {
    var accessibilityTimeDescription: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        
        if minutes > 0 && seconds > 0 {
            return "\(minutes)分钟\(seconds)秒"
        } else if minutes > 0 {
            return "\(minutes)分钟"
        } else {
            return "\(seconds)秒"
        }
    }
}

extension View {
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(hint ?? "")
    }
}

