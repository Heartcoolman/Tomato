//
//  PetType.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import Foundation
import SwiftUI

enum PetType: String, Codable, CaseIterable, Identifiable {
    case tomatoCat = "番茄猫"
    case tomatoDog = "番茄狗"
    case tomatoBird = "番茄鸟"
    case tomatoRabbit = "番茄兔"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .tomatoCat: return "🐱"
        case .tomatoDog: return "🐶"
        case .tomatoBird: return "🐦"
        case .tomatoRabbit: return "🐰"
        }
    }
    
    var color: Color {
        switch self {
        case .tomatoCat: return .orange
        case .tomatoDog: return .brown
        case .tomatoBird: return .blue
        case .tomatoRabbit: return .pink
        }
    }
}

enum EvolutionStage: Int, Codable {
    case baby = 0    // 0-10级
    case child = 1   // 11-30级
    case teen = 2    // 31-60级
    case adult = 3   // 61-100级
    
    var displayName: String {
        switch self {
        case .baby: return "幼年"
        case .child: return "少年"
        case .teen: return "青年"
        case .adult: return "成年"
        }
    }
    
    var levelRange: ClosedRange<Int> {
        switch self {
        case .baby: return 0...10
        case .child: return 11...30
        case .teen: return 31...60
        case .adult: return 61...100
        }
    }
    
    static func fromLevel(_ level: Int) -> EvolutionStage {
        if level <= 10 { return .baby }
        else if level <= 30 { return .child }
        else if level <= 60 { return .teen }
        else { return .adult }
    }
}

struct PetAppearance: Codable {
    var skinId: String
    var accessoryId: String?
    
    init(skinId: String = "default", accessoryId: String? = nil) {
        self.skinId = skinId
        self.accessoryId = accessoryId
    }
}

