//
//  SettingsTabViewModel.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 3.02.2025.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine
import FirebaseAuth
import AlertKit

@MainActor
final class SettingsTabViewModel: ObservableObject {
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var profilePhoto: MediaAttachment?
    @Published var showProgressHUD = false
    @Published var showSuccessHUD = false
    @Published var showUserInfoEditor = false
    @Published var name = ""
    @Published var bio = ""
    
    private var currentUser: UserItem
    
    private(set) var progressHUDView = AlertAppleMusic17View(title: "Uploading Profile Photo", subtitle: nil, icon: .spinnerSmall)
    private(set) var successHUDView = AlertAppleMusic17View(title: "Profile Info Updated!", subtitle: nil, icon: .done)
    
    private var subscription: AnyCancellable?
    
    var disableSaveButton: Bool {
        return profilePhoto == nil || showProgressHUD
    }
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        self.name = currentUser.username
        self.bio = currentUser.bio ?? ""
        onPhotoPickerSelection()
    }
    
    private func onPhotoPickerSelection() {
        subscription = $selectedPhotoItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] photoItem in
                guard let photoItem = photoItem else { return }
                self?.parsePhotoPickerItem(photoItem)
            }
    }
    
    private func parsePhotoPickerItem(_ photoItem: PhotosPickerItem) {
        Task {
            guard let data = try? await photoItem.loadTransferable(type: Data.self),
                    let uiImage = UIImage(data: data) else { return }
            
            self.profilePhoto = MediaAttachment(id: UUID().uuidString, type: .photo(uiImage))
                                                
        }
    }
    
    func uploadProfilePhoto() {
        guard let profilePhoto = profilePhoto?.thumbnail else { return }
        showProgressHUD = true
        FirebaseHelper.uploadImage(profilePhoto, for: .profilePhoto) { [weak self] result in
            switch result {
            case .success(let imageUrl):
                self?.onUploadSuccess(imageUrl)
            case .failure(let error):
                print("Image upload failed: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Progress: \(progress)")
        }
    }
    
    private func onUploadSuccess(_ imageUrl: URL) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserRef.child(currentUid).child(.profileImageURL).setValue(imageUrl.absoluteString)
        showProgressHUD = false
        progressHUDView.dismiss()
        currentUser.profileImageURL = imageUrl.absoluteString
        AuthManager.shared.authState.send(.authenticated(currentUser))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showSuccessHUD = true
            self.profilePhoto = nil
            self.selectedPhotoItem = nil
        }
    }
    
    func updateUsernameBio() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var dict: [String: Any] = [.bio: bio]
        currentUser.bio = bio
        
        if !name.isEmptyOrWhitespace {
            dict[.username] = name
            currentUser.username = name
        }
        
        FirebaseConstants.UserRef.child(currentUid).updateChildValues(dict)
        showSuccessHUD = true
        AuthManager.shared.authState.send(.authenticated(currentUser))
    }
}
