//
//  AddWebDAVAccountView.swift
//  Tomato
//

import SwiftUI

struct AddWebDAVAccountView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = WebDAVManager.shared
    
    @State private var name = ""
    @State private var serverURL = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isTesting = false
    @State private var testResult: TestResult?
    
    enum TestResult {
        case success
        case failure(String)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("账号信息") {
                    TextField("账号名称", text: $name)
                    TextField("服务器地址", text: $serverURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("用户名", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("密码", text: $password)
                }
                
                Section("常用服务") {
                    Button("坚果云") {
                        serverURL = "https://dav.jianguoyun.com/dav/"
                    }
                    Button("Nextcloud") {
                        // 用户需要填写自己的服务器地址
                    }
                }
                
                Section {
                    Button(action: testConnection) {
                        HStack {
                            if isTesting {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text(isTesting ? "测试中..." : "测试连接")
                        }
                    }
                    .disabled(isTesting || !isFormValid)
                    
                    if let result = testResult {
                        switch result {
                        case .success:
                            Label("连接成功", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        case .failure(let message):
                            Label(message, systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("添加 WebDAV 账号")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveAccount()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !serverURL.isEmpty && !username.isEmpty && !password.isEmpty
    }
    
    private func testConnection() {
        isTesting = true
        testResult = nil
        
        let account = WebDAVAccount(
            name: name,
            serverURL: serverURL,
            username: username
        )
        
        Task {
            do {
                let success = try await manager.testConnection(account: account, password: password)
                await MainActor.run {
                    isTesting = false
                    testResult = success ? .success : .failure("连接失败")
                }
            } catch {
                await MainActor.run {
                    isTesting = false
                    testResult = .failure(error.localizedDescription)
                }
            }
        }
    }
    
    private func saveAccount() {
        let account = WebDAVAccount(
            name: name,
            serverURL: serverURL,
            username: username,
            isDefault: manager.accounts.isEmpty
        )
        
        manager.addAccount(account, password: password)
        dismiss()
    }
}
