//
//  RootScreenModel.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 11.01.2025.
//

import Foundation
import Combine

final class RootScreenModel: ObservableObject {
    @Published private(set) var authState = AuthState.pending
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = AuthManager.shared.authState.sink { [weak self] state in
            self?.authState = state
        }
        
//        AuthManager.testAccounts.forEach { email in
//            registerTextAccount(with: email)
//        }
    }
    
//    private func registerTextAccount(with email: String) {
//        Task {
//            let username = email.replacingOccurrences(of: "@example.com", with: "")
//            try? await AuthManager.shared.signUp(for: username, with: email, and: "password")
//        }
//    }
}
