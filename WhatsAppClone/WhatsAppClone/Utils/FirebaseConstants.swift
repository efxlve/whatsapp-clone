//
//  FirebaseConstants.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 12.01.2025.
//

import Firebase
import FirebaseStorage

enum FirebaseConstants {
    static let StorageRef = Storage.storage().reference()
    private static let DatabaseRef = Database.database().reference()
    static let UserRef = DatabaseRef.child("users")
    static let ChannelsRef = DatabaseRef.child("channels")
    static let MessagesRef = DatabaseRef.child("channel-messages")
    static let UserChannelsRef = DatabaseRef.child("user-channels")
    static let UserDirectChannels = DatabaseRef.child("user-direct-channels")
}
