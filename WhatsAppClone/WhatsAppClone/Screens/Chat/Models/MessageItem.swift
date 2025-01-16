//
//  MessageItem.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 8.01.2025.
//

import SwiftUI

struct MessageItem: Identifiable {
    let id = UUID().uuidString
    let text: String
    let type: MessageType
    let direction: MessageDirection
    
    static let sentPlaceholder = MessageItem(text: "Hello, World!", type: .text, direction: .sent)
    static let receivedPlaceholder = MessageItem(text: "Hello, World!", type: .text, direction: .received)
    
    var alignment: Alignment {
        return direction == .received ? .leading : .trailing
    }
    
    var horizontalAlignment: HorizontalAlignment {
        return direction == .received ? .leading : .trailing
    }
    
    var backgroundColor: Color {
        return direction == .sent ? .bubbleGreen : .bubbleWhite
    }
    
    static let stubMessages: [MessageItem] = [
        MessageItem(text: "Hello, World!", type: .text, direction: .sent),
        MessageItem(text: "Hello, World!", type: .photo, direction: .received),
        MessageItem(text: "Hello, World!", type: .video, direction: .sent),
        MessageItem(text: "Hello, World!", type: .audio, direction: .received),
    ]
}

extension String {
    static let `type` = "type"
    static let timeStamp = "timeStamp"
    static let ownerUid = "ownerUid"
    static let text = "text"
}
