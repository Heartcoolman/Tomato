//
//  CreatePetView.swift
//  TomatoTimer
//
//  Created by AI Assistant
//

import SwiftUI

struct CreatePetView: View {
    @ObservedObject var petStore: PetStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedType: PetType = .tomatoCat
    @State private var petName: String = ""
    @State private var showNameError = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 标题
                    VStack(spacing: 8) {
                        Text("领养宠物")
                            .font(.title.bold())
                            .foregroundColor(.darkGray)
                        
                        Text("选择一只可爱的番茄宠物陪伴你的番茄钟之旅")
                            .font(.subheadline)
                            .foregroundColor(.darkGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // 宠物类型选择
                    VStack(alignment: .leading, spacing: 16) {
                        Text("选择类型")
                            .font(.headline)
                            .foregroundColor(.darkGray)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(PetType.allCases) { type in
                                PetTypeCard(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                    
                    // 名字输入
                    VStack(alignment: .leading, spacing: 12) {
                        Text("取个名字")
                            .font(.headline)
                            .foregroundColor(.darkGray)
                        
                        TextField("给宠物起个好听的名字", text: $petName)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showNameError ? Color.red : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                        
                        if showNameError {
                            Text("请输入宠物名字（1-10个字符）")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // 预览
                    VStack(spacing: 16) {
                        Text("预览")
                            .font(.headline)
                            .foregroundColor(.darkGray)
                        
                        VStack(spacing: 12) {
                            Text(selectedType.emoji)
                                .font(.system(size: 100))
                            
                            Text(petName.isEmpty ? "???" : petName)
                                .font(.title2.bold())
                                .foregroundColor(.darkGray)
                            
                            Text(selectedType.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.darkGray.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        )
                    }
                    
                    // 确认按钮
                    Button(action: createPet) {
                        Text("确认领养")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.tomatoRed)
                            )
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .background(Color.lightYellow.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createPet() {
        // 验证名字
        let trimmedName = petName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName.count <= 10 else {
            showNameError = true
            return
        }
        
        showNameError = false
        petStore.createPet(type: selectedType, name: trimmedName)
        HapticManager.shared.playSuccess()
        dismiss()
    }
}

struct PetTypeCard: View {
    let type: PetType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(type.emoji)
                    .font(.system(size: 60))
                
                Text(type.rawValue)
                    .font(.subheadline.bold())
                    .foregroundColor(.darkGray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? type.color.opacity(0.2) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? type.color : Color.gray.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreatePetView(petStore: PetStore())
}

