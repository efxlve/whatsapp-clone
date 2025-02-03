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
    @StateObject private var viewModel = SettingsTabViewModel()
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
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
            }
            .navigationTitle("Settings")
            .searchable(text: $searchText)
            .toolbar {
                LeadingNavItem()
            }
        }
    }
}

extension SettingsTabScreen {
  @ToolbarContentBuilder
    private func LeadingNavItem() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                isSignOutAlertPresented = true
            } label: {
//                Image(systemName: "person.crop.circle.fill.badge.minus")
                Text("Sign Out")
            }
            .bold()
            .foregroundStyle(.red)
            .alert("Are you sure you want to sign out?", isPresented: $isSignOutAlertPresented) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await AuthManager.shared.signOut()
                    }
                }
            }
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
            CircularProfileImageView(nil, size: .custom(55))
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
                    .foregroundStyle(.blue)
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
