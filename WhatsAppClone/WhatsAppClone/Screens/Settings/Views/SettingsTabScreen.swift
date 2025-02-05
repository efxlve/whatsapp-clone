//
//  SettingsTabScreen.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 8.01.2025.
//

import SwiftUI
import PhotosUI

struct SettingsTabScreen: View {
    @State private var searchText = ""
    @State private var isSignOutAlertPresented = false
    @StateObject private var viewModel: SettingsTabViewModel
    
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        self._viewModel = StateObject(wrappedValue: SettingsTabViewModel(currentUser))
    }
    
    var body: some View {
        NavigationStack {
            List {
                SettingsHeaderView(viewModel, currentUser)
                
                Section {
                    SettingsItemView(item: .broadcastLists)
                    SettingsItemView(item: .starredMessages)
                    SettingsItemView(item: .linkedDevices)
                }
                
                Section {
                    SettingsItemView(item: .account)
                    SettingsItemView(item: .privacy)
                    SettingsItemView(item: .chats)
                    SettingsItemView(item: .notifications)
                    SettingsItemView(item: .storage)
                }
                
                Section {
                    SettingsItemView(item: .help)
                    SettingsItemView(item: .tellFriend)
                }

                Section {
                    Button {
                        isSignOutAlertPresented = true
                    } label: {
                        SettingsItemView(item: .logout)
                    }
                }
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                TrailingNavItem()
            }
            .alert(isPresent: $viewModel.showProgressHUD, view: viewModel.progressHUDView)
            .alert(isPresent: $viewModel.showSuccessHUD, view: viewModel.successHUDView)
            .alert("Update Your Profile", isPresented: $viewModel.showUserInfoEditor) {
                TextField("Username", text: $viewModel.name)
                TextField("Bio", text: $viewModel.bio)
                Button("Update") {
                    viewModel.updateUsernameBio()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your new username and bio")
            }
            .alert("Are you sure you want to sign out?", isPresented: $isSignOutAlertPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await AuthManager.shared.signOut()
                    }
                }
            }
        }
    }
}

extension SettingsTabScreen {
    @ToolbarContentBuilder
    private func TrailingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
                viewModel.uploadProfilePhoto()
            }
            .bold()
            .disabled(viewModel.disableSaveButton)
        }
    }
}


private struct SettingsHeaderView: View {
    private let currentUser: UserItem
    @ObservedObject private var viewModel: SettingsTabViewModel
    
    init(_ viewModel: SettingsTabViewModel, _ currentUser: UserItem) {
        self.viewModel = viewModel
        self.currentUser = currentUser
    }
    
    var body: some View {
        Section {
            HStack {
                profileImageView()
                
                userInfoTextView()
                    .onTapGesture {
                        viewModel.showUserInfoEditor = true
                    }
            }
            
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .not(.videos)) {
                SettingsItemView(item: .avatar)
            }
        }
    }
    
    @ViewBuilder
    private func profileImageView() -> some View {
        if let profilePhoto = viewModel.profilePhoto {
            Image(uiImage: profilePhoto.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
        } else {
            CircularProfileImageView(currentUser.profileImageURL, size: .custom(55))
        }
    }
    
    private func userInfoTextView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(currentUser.username)
                    .font(.title2)
                
                Spacer()
                
                Image(.qrcode)
                    .renderingMode(.template)
                    .padding(5)
                    .foregroundStyle(.primary)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
            
            Text(currentUser.bioUnwrapped)
                .foregroundStyle(.gray)
                .font(.callout)
        }
        .lineLimit(1)
    }
}

#Preview {
    SettingsTabScreen(.placeholder)
}
