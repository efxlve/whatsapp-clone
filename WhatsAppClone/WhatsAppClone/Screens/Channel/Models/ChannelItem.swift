//
//  ChannelItem.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 14.01.2025.
//

import Foundation
import FirebaseAuth

struct ChannelItem: Identifiable, Hashable {
    var id: String
    var name: String?
    var lastMessage: String
    var creationDate: Date
    var lastMessageTimestamp: Date
    var membersCount: Int
    var adminUids: [String]
    var memberUids: [String]
    var members: [UserItem]
    private var thumbnailUrl: String?
    let createdBy: String
    
    var isGroupChat: Bool {
        return membersCount > 2
    }
    
    var coverImageUrl: String? {
        if let thumbnailUrl = thumbnailUrl {
            return thumbnailUrl
        }
        
        if isGroupChat == false {
            return membersExcludingMe.first?.profileImageURL
        }
        
        return nil
    }
    
    var membersExcludingMe: [UserItem] {
        guard let currentUid = Auth.auth().currentUser?.uid else { return [] }
        return members.filter { $0.uid != currentUid }
    }
    
    var title: String {
        if let name = name {
            return name
        }
        
        if isGroupChat {
            return groupMemberNames
        } else {
            return membersExcludingMe.first?.username ?? "Unknown User"
        }
    }
    
    private var groupMemberNames: String {
        let membersCount = membersCount - 1
        let fullNames: [String] = membersExcludingMe.map { $0.username }
        
        if membersCount == 2 {
            return fullNames.joined(separator: " and ")
        } else if membersCount > 2 {
            let remainingCount = membersCount - 2
            return fullNames.prefix(2).joined(separator: ", ") + " and \(remainingCount) others"
        }
        
        return "Unknown"
    }
    
    var isCreatedByMe: Bool {
        return createdBy == Auth.auth().currentUser?.uid ?? ""
    }
    
    var creatorName: String {
        return members.first { $0.uid == createdBy }?.username ?? "Unknown User"
    }
    
    var allMembersFetched: Bool {
        return members.count == membersCount
    }
    
    static let placeholder = ChannelItem.init(id: "1", lastMessage: "Hello World!", creationDate: Date(), lastMessageTimestamp: Date(), membersCount: 2, adminUids: [], memberUids: [], members: [], createdBy: "")
}

extension ChannelItem {
    init(_ dict: [String: Any]) {
        self.id = dict[.id] as? String ?? ""
        self.name = dict[.name] as? String? ?? nil
        self.lastMessage = dict[.lastMessage] as? String ?? ""
        let creationDate = dict[.creationDate] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: creationDate)
        let lastMessageTimestamp = dict[.lastMessageTimestamp] as? Double ?? 0
        self.lastMessageTimestamp = Date(timeIntervalSince1970: lastMessageTimestamp)
        self.membersCount = dict[.membersCount] as? Int ?? 0
        self.adminUids = dict[.adminUids] as? [String] ?? []
        self.memberUids = dict[.memberUids] as? [String] ?? []
        self.thumbnailUrl = dict[.thumbnailUrl] as? String ?? nil
        self.members = dict[.members] as? [UserItem] ?? []
        self.createdBy = dict[.createdBy] as? String ?? ""
    }
}

extension String {
    static let id = "id"
    static let name = "name"
    static let lastMessage = "lastMessage"
    static let creationDate = "creationDate"
    static let lastMessageTimestamp = "lastMessageTimestamp"
    static let membersCount = "membersCount"
    static let adminUids = "adminUids"
    static let memberUids = "memberUids"
    static let thumbnailUrl = "thumbnailUrl"
    static let members = "members"
    static var createdBy = "createdBy"
}
