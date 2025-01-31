//
//  BubbleView.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 31.01.2025.
//

import SwiftUI

struct BubbleView: View {
    let message: MessageItem
    let channel: ChannelItem
    let isNewDay: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if isNewDay {
                newDayTimeStampTextView()
                    .padding()
            }
            
            composeDynamicBubbleView()
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func composeDynamicBubbleView() -> some View {
        switch message.type {
        case .text:
            BubbleTextView(item: message)
        case .photo, .video:
            BubbleImageView(item: message)
        case .audio:
            BubbleAudioView(item: message)
        case .admin(let adminType):
            switch adminType {
            case .channelCreation:
                
                newDayTimeStampTextView()
                ChannelCreationTextView()
                    .padding()
                
                if channel.isGroupChat {
                    AdminMessageTextView(channel: channel)
                }
            default:
                Text("Admin message")
            }
        }
    }
    
    private func newDayTimeStampTextView() -> some View {
        Text(message.timeStamp.relativeDateString)
            .font(.caption)
            .bold()
            .padding(.vertical, 3)
            .padding(.horizontal)
            .background(Color.whatsAppGray)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    BubbleView(message: .sentPlaceholder, channel: .placeholder, isNewDay: false)
}
