//
//  ChatPartnerPickerViewModel.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 12.01.2025.
//

import Foundation
import FirebaseAuth
import Combine

enum ChannelCreationRoute {
    case groupPartnerPicker
    case setUpGroupChat
}

enum ChannelContants {
    static let maxGroupChatMembers = 12
}

enum ChannelCreationError: Error {
    case noChatPartnersSelected
    case failedToCreateUniqueChannelId
}

@MainActor
final class ChatPartnerPickerViewModel: ObservableObject {
    @Published var navStack = [ChannelCreationRoute]()
    @Published var selectedChatPartners = [UserItem]()
    @Published private(set) var users = [UserItem]()
    @Published var errorState: (showError: Bool, errorMessage: String) = (false, "Uh Oh! Something went wrong.")
    
    private var subscription: AnyCancellable?
    
    private var lastCursor: String?
    private var currentUser: UserItem?
    
    var showSelectedUsers: Bool {
        return !selectedChatPartners.isEmpty
    }
    
    var disableNextButton: Bool {
        return selectedChatPartners.isEmpty
    }
    
    var isPaginatable: Bool {
        return !users.isEmpty
    }
    
    private var isDirectChannel: Bool {
        return selectedChatPartners.count == 1
    }
    
    init() {
        listenForAuthState()
    }
    
    deinit {
        subscription?.cancel()
        subscription = nil
    }
    
    private func listenForAuthState() {
        subscription = AuthManager.shared.authState.receive(on: DispatchQueue.main).sink { [weak self] authState in
            switch authState {
            case .authenticated(let currentUser):
                self?.currentUser = currentUser
                Task {
                    await self?.fetchUsers()
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Public Methods
    func fetchUsers() async {
        do {
            let userNode = try await UserService.paginateUsers(lastCursor: lastCursor, pageSize: 5)
            var fetchedUsers = userNode.users
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            fetchedUsers = fetchedUsers.filter { $0.uid != currentUid }
            
            self.users.append(contentsOf: fetchedUsers)
            self.lastCursor = userNode.currentCursor
        } catch {
            print("Failed to fetch users. \(error.localizedDescription)")
        }
    }
    
    func deSelectAllChatPartners() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedChatPartners.removeAll()
        }
    }
    
    func handleItemSelection(_ item: UserItem) {
        if isUserSelected(item) {
            guard let index = selectedChatPartners.firstIndex(where: { $0.uid == item.uid }) else { return }
            selectedChatPartners.remove(at: index)
        } else {
            guard selectedChatPartners.count < ChannelContants.maxGroupChatMembers else {
                let errorMessgae = "You can't add more than \(ChannelContants.maxGroupChatMembers) members."
                showError(errorMessgae)
                return
            }
            selectedChatPartners.append(item)
        }
    }
    
    func isUserSelected(_ user: UserItem) -> Bool {
        let isSelected = selectedChatPartners.contains { $0.uid == user.uid }
        return isSelected
    }
    
    func createDirectChannel(_ chatPartner: UserItem, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        selectedChatPartners.append(chatPartner)
        
        Task {
            if let channelId = await verifyIfDirectChannelExists(with: chatPartner.uid) {
                let snapshot = try await FirebaseConstants.ChannelsRef.child(channelId).getData()
                let channelDict = snapshot.value as! [String: Any]
                var directChannel = ChannelItem(channelDict)
                directChannel.members = selectedChatPartners
                if let currentUser {
                    directChannel.members.append(currentUser)
                }
                completion(directChannel)
            } else {
                let channelCreation = createChannel(nil)
                switch channelCreation {
                case .success(let channel):
                    completion(channel)
                case .failure (let failure):
                    showError("Failed to create a Direct Channel: \(failure.localizedDescription)")
                    print("Failed to create a Direct Channel: \(failure.localizedDescription)")
                }
            }
        }
    }

    
    func createGroupChannel(_ groupName: String?, completion: @escaping (_ newChannel: ChannelItem) -> Void) {
        let channelCreation = createChannel(groupName)
        switch channelCreation {
        case .success(let channel):
            completion(channel)
        case .failure(let failure):
            showError("Failed to create a Group Channel: \(failure.localizedDescription)")
            print("Failed to create a Group Channel: \(failure.localizedDescription)")
        }
    }
    
    typealias ChannelId = String
    private func verifyIfDirectChannelExists(with chatPartnerId: String) async -> ChannelId? {
        guard let currentUid = Auth.auth().currentUser?.uid,
              let snapshot = try? await FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartnerId).getData(), snapshot.exists()
                
        else { return nil }
        
        let directMessageDict = snapshot.value as! [String: Bool]
        let channelId = directMessageDict.compactMap({ $0.key }).first
        return channelId
    }
    
    private func showError(_ errorMessage: String) {
        errorState.errorMessage = errorMessage
        errorState.showError = true
    }
    
    private func createChannel(_ channelName: String?) -> Result<ChannelItem, Error> {
        guard !selectedChatPartners.isEmpty else {
            return .failure(ChannelCreationError.noChatPartnersSelected)
        }
        
        guard
            let channelId = FirebaseConstants.ChannelsRef.childByAutoId().key,
            let currentUid = Auth.auth().currentUser?.uid,
            let messageId = FirebaseConstants.MessagesRef.childByAutoId().key
        else {
            return .failure(ChannelCreationError.failedToCreateUniqueChannelId)
        }
        
        let timestamp = Date().timeIntervalSince1970
        var membersUids = selectedChatPartners.compactMap{ $0.uid }
        membersUids.append(currentUid)
        
        let newChannelBroadcast = AdminMessageType.channelCreation.rawValue
        
        var channelDict: [String: Any] = [
            .id: channelId,
            .lastMessage: newChannelBroadcast,
            .creationDate: timestamp,
            .lastMessageTimestamp: timestamp,
            .memberUids: membersUids,
            .membersCount: membersUids.count,
            .adminUids: [currentUid],
            .createdBy: currentUid
        ]
        
        if let channelName = channelName, !channelName.isEmptyOrWhitespace {
            channelDict[.name] = channelName
        }
        
        let messageDict: [String: Any] = [.type: newChannelBroadcast,
                                          .timeStamp: timestamp,
                                          .ownerUid: currentUid]
        
        FirebaseConstants.ChannelsRef.child(channelId).setValue(channelDict)
        FirebaseConstants.MessagesRef.child(channelId).child(messageId).setValue(messageDict)
        
        membersUids.forEach { userId in
            FirebaseConstants.UserChannelsRef.child(userId).child(channelId).setValue(true)
        }
        
        if isDirectChannel {
            let chatPartner = selectedChatPartners[0]
            FirebaseConstants.UserDirectChannels.child(currentUid).child(chatPartner.uid).setValue([channelId: true])
            FirebaseConstants.UserDirectChannels.child(chatPartner.uid).child(currentUid).setValue([channelId: true])
        }
        
        var newChannelItem = ChannelItem(channelDict)
        newChannelItem.members = selectedChatPartners
        if let currentUser {
            newChannelItem.members.append(currentUser)
        }
        return .success(newChannelItem)
    }
}
