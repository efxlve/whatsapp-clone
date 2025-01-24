//
//  ChannelTabViewModel.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 14.01.2025.
//

import Foundation
import FirebaseAuth

enum ChannelTabRoutes: Hashable {
    case chatRoom( _ channel: ChannelItem)
}

final class ChannelTabViewModel: ObservableObject {
    
    @Published var navRoutes = [ChannelTabRoutes]()
    @Published var navigateToChatRoom = false
    @Published var newChannel: ChannelItem?
    @Published var showChatPartnerPickerView = false
    @Published var channels = [ChannelItem]()
    typealias ChannelId = String
    @Published var channelDict: [ChannelId: ChannelItem] = [:]
    
    private let currentUser: UserItem
    
    init(_ currentUser: UserItem) {
        self.currentUser = currentUser
        fetchCurrentUserChannels()
    }
    
    func onNewChannelCreation(_ channel: ChannelItem) {
        showChatPartnerPickerView = false
        newChannel = channel
        navigateToChatRoom = true
    }
    
    private func fetchCurrentUserChannels() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        FirebaseConstants.UserChannelsRef.child(currentUid).observe(.value) {[weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            dict.forEach { key, value in
                let channelId = key
                self?.getChannel(with: channelId)
            }
        } withCancel: { error in
            print("Failed to fetch user channels: \(error.localizedDescription)")
        }
    }
    
    private func getChannel(with channelId: String) {
        FirebaseConstants.ChannelsRef.child(channelId).observe(.value) { [weak self] snapshot in
            guard let dict = snapshot.value as? [String: Any], let self = self else { return }
            var channel = ChannelItem(dict)
            self.getChannelMembers(channel) { members in
                channel.members = members
                channel.members.append(self.currentUser)
                self.channelDict[channelId] = channel
                self.reloadData()
                //self.channels.append(channel)
            }
            
        } withCancel: { error in
            print("Failed to fetch channel: \(error.localizedDescription)")
        }
    }
    
    private func getChannelMembers(_ channel: ChannelItem, completion: @escaping (_ members: [UserItem]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let channelMembersUids = Array(channel.memberUids.filter { $0 != currentUid }.prefix(2))
        UserService.getUsers(with: channelMembersUids) { userNode in
            completion(userNode.users)
        }
    }
    
    private func reloadData() {
        self.channels = Array(channelDict.values)
        self.channels.sort { $0.lastMessageTimestamp > $1.lastMessageTimestamp }
    }
}
