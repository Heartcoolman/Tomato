//
//  EncodingPickerView.swift
//  Tomato
//

import SwiftUI

/// 编码选择器视图
struct EncodingPickerView: View {
    let fileData: Data
    let onSelect: (String.Encoding) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedEncoding: String.Encoding = .utf8
    @State private var previewText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 编码列表
                List {
                    ForEach(EncodingDetector.supportedEncodings, id: \.0) { encoding, name in
                        Button(action: {
                            selectedEncoding = encoding
                            updatePreview()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name)
                                        .font(.body)
                                    
                                    if encoding == selectedEncoding {
                                        Text("已选择")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if encoding == selectedEncoding {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
                .frame(height: 300)
                
                Divider()
                
                // 预览区域
                VStack(alignment: .leading, spacing: 8) {
                    Text("预览（前 5 行）")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        Text(previewText)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("选择编码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("确定") {
                        onSelect(selectedEncoding)
                        dismiss()
                    }
                }
            }
            .onAppear {
                updatePreview()
            }
        }
    }
    
    private func updatePreview() {
        if let preview = EncodingDetector.previewText(data: fileData, encoding: selectedEncoding, lines: 5) {
            previewText = preview
        } else {
            previewText = "无法使用此编码解码文件"
        }
    }
}
