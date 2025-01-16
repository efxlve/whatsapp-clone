//
//  AuthProvider.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 11.01.2025.
//

import Combine
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabaseInternal

enum AuthState {
    case pending, authenticated(UserItem), unauthenticated
}

protocol AuthProvider {
    static var shared: AuthProvider { get }
    var authState: CurrentValueSubject<AuthState, Never> { get }
    func autoSignIn() async
    
    func signIn(email: String, and password: String) async throws
    func signUp(for username: String, with email: String, and password: String) async throws
    func signOut() async throws
}

enum AuthError: Error {
    case accountCreationFailed(_ description: String)
    case failedToSaveUserInfo(_ description: String)
    case emailSignInFailed(_ description: String)
}

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountCreationFailed(let description):
            return description
        case .failedToSaveUserInfo(let description):
            return description
        case .emailSignInFailed(let description):
            return description
        }
    }
}

final class AuthManager: AuthProvider {
    
    private init() {
        Task {
            await autoSignIn()
        }
    }
    
    static let shared: AuthProvider = AuthManager()
    
    var authState = CurrentValueSubject<AuthState, Never>(.pending)
    
    func autoSignIn() async {
        if Auth.auth().currentUser == nil {
            authState.send(.unauthenticated)
        } else {
            fetchCurrentUserInfo()
        }
    }
    
    func signIn(email: String, and password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            fetchCurrentUserInfo()
        } catch {
            print("Failed to sign in. \(error.localizedDescription)")
            throw AuthError.emailSignInFailed(error.localizedDescription)
        }
    }
    
    func signUp(for username: String, with email: String, and password: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            let newUser = UserItem(uid: uid, username: username, email: email)
            try await saveUserInfoDatabase(user: newUser)
            self.authState.send(.authenticated(newUser))
        } catch {
            print("Failed to sign up. \(error.localizedDescription)")
            throw AuthError.accountCreationFailed(error.localizedDescription)
        }
    }
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            authState.send(.unauthenticated)
        } catch {
            print("Failed to sign out. \(error.localizedDescription)")
            throw error
        }
    }
    
}

extension AuthManager {
    private func saveUserInfoDatabase(user: UserItem) async throws {
        do {
            let userDictionary: [String: Any] = [.uid: user.uid, .username: user.username, .email: user.email]
            try await FirebaseConstants.UserRef.child(user.uid).setValue(userDictionary)
        } catch {
            print("Failed to save user info. \(error.localizedDescription)")
            throw AuthError.failedToSaveUserInfo(error.localizedDescription)
        }
    }
    
    private func fetchCurrentUserInfo() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let user = UserItem(dictionary: dictionary)
            self?.authState.send(.authenticated(user))
            print("User info fetched successfully. \(user)")
        } withCancel: { error in
            print("Failed to fetch user info. \(error.localizedDescription)")
        }
    }
}

//extension AuthManager {
//    static let testAccounts: [String] = [
//        "david@example.com",
//        "alex@example.com",
//        "john@example.com",
//        "mia@example.com",
//        "sophia@example.com",
//        "emma@example.com",
//        "olivia@example.com",
//        "ava@example.com",
//        "isabella@example.com",
//        "liam@example.com",
//        "noah@example.com",
//        "amelia@example.com"
//    ]
//}


