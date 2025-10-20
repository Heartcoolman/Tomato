//
//  CircularProgressView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 ~ 1.0
    let lineWidth: CGFloat = 20
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // 背景圆环
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // 进度圆环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.tomatoRed,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? .none : .linear(duration: 0.1), value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("计时进度")
        .accessibilityValue("\(Int(progress * 100))%")
    }
}

#Preview {
    CircularProgressView(progress: 0.65)
        .frame(width: 300, height: 300)
        .padding()
}

