//
//  SettingsItem.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 8.01.2025.
//

import SwiftUI

struct SettingsItem {
    let imageName: String
    let imageColor: Color = .primary
    var imageType: ImageType = .systemImage
    let backgroundColor: Color
    let title: String
    var isArrow: Bool = true
    
    enum ImageType {
        case systemImage, assetImage
    }
}

// MARK: Settings Data
extension SettingsItem {
    static let avatar = SettingsItem(
        imageName: "photo",
        backgroundColor: .clear,
        title: "Change Profile Photo"
    )
    
    static let broadcastLists = SettingsItem(
        imageName: "megaphone",
        backgroundColor: .clear,
        title: "Broadcast Lists"
    )
    
    static let starredMessages = SettingsItem(
        imageName: "star",
        backgroundColor: .clear,
        title: "Starred Messages"
    )
    
    static let linkedDevices = SettingsItem(
        imageName: "laptopcomputer",
        backgroundColor: .clear,
        title: "Linked Devices"
    )
    
    static let account = SettingsItem(
        imageName: "key",
        backgroundColor: .clear,
        title: "Account"
    )
    
    static let privacy = SettingsItem(
        imageName: "lock",
        backgroundColor: .clear,
        title: "Privacy"
    )
    
    static let chats = SettingsItem(
        imageName: "message",
        backgroundColor: .clear,
        title: "Chats"
    )
    
    static let notifications = SettingsItem(
        imageName: "bell.badge",
        backgroundColor: .clear,
        title: "Notifications"
    )
    
    static let storage = SettingsItem(
        imageName: "arrow.up.arrow.down",
        backgroundColor: .clear,
        title: "Storage and Data"
    )
    
    static let help = SettingsItem(
        imageName: "info",
        backgroundColor: .clear,
        title: "Help"
    )
    
    static let tellFriend = SettingsItem(
        imageName: "heart",
        backgroundColor: .clear,
        title: "Tell a Friend"
    )
    
    static let logout = SettingsItem(
        imageName: "door.right.hand.open",
        backgroundColor: .clear,
        title: "Log Out"
    )
}

// MARK: Contact Info Data
extension SettingsItem {
    static let media = SettingsItem(
        imageName: "photo",
        backgroundColor: .blue,
        title: "Media, Links and Docs"
    )
    
    static let mute = SettingsItem(
        imageName: "speaker.wave.2.fill",
        backgroundColor: .green,
        title: "Mute"
    )
    
    static let wallpaper = SettingsItem(
        imageName: "circles.hexagongrid",
        backgroundColor: .mint,
        title: "Wallpaper & Sound"
    )
    
    static let saveToCameraRoll = SettingsItem(
        imageName: "square.and.arrow.down",
        backgroundColor: .yellow,
        title: "Save to Camera Roll"
    )
    
    static let encryption = SettingsItem(
        imageName: "lock.fill",
        backgroundColor: .blue,
        title: "Encryption"
    )
    
    static let disappearingMessages = SettingsItem(
        imageName: "timer",
        backgroundColor: .blue,
        title: "Disappearing Messages"
    )
    
    static let lockChat = SettingsItem(
        imageName: "lock.doc.fill",
        backgroundColor: .blue,
        title: "Lock Chat"
    )
    
    static let contactDetails = SettingsItem(
        imageName: "person.circle",
        backgroundColor: .gray,
        title: "Contact Details"
    )
}
