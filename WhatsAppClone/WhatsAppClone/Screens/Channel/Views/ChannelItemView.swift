//
//  ChannelItemView.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 7.01.2025.
//

import SwiftUI

struct ChannelItemView: View {
    let channel: ChannelItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            CircularProfileImageView(channel, size: .medium)
            
            VStack(alignment: .leading, spacing: 3) {
                titleTextView()
                lastMessagePreviewTextView()
            }
        }
    }
    
    private func titleTextView() -> some View {
        HStack {
            Text(channel.title)
                .lineLimit(3)
                .bold()
            
            Spacer()
            
            Text(channel.lastMessageTimestamp.dayOrTimeRepresentation)
                .foregroundStyle(.gray)
                .font(.system(size: 15))
        }
    }
    
    private func lastMessagePreviewTextView() -> some View {
        Text(channel.lastMessage)
            .font(.system(size: 16))
            .lineLimit(2)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ChannelItemView(channel: .placeholder)
}
