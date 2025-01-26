//
//  BubbleImageView.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 9.01.2025.
//

import SwiftUI
import Kingfisher

struct BubbleImageView: View {
    let item: MessageItem
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if item.direction == .sent {
                Spacer()
            }
            
            if item.showGroupPartnerInfo {
                CircularProfileImageView(item.sender?.profileImageURL, size: .mini)
                    .offset(y: 5)
            }

            messageImageView()
                .shadow(color: Color(.systemGray3).opacity(0.1), radius: 5, x: 0, y: 20)
                .overlay {
                    playButton()
                        .opacity(item.type == .video ? 1 : 0)
                }
            
            if item.direction == .received {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: item.alignment)
        .padding(.leading, item.leadingPadding)
        .padding(.trailing, item.trailingPadding)
    }
    
    private func playButton() -> some View {
        Image(systemName: "play.fill")
            .padding()
            .imageScale(.large)
            .foregroundColor(.gray)
            .background(.thinMaterial)
            .clipShape(Circle())
    }
    
    private func messageImageView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            KFImage(URL(string: item.thumbnailUrl ?? ""))
                .resizable()
                .placeholder { ProgressView() }
                .scaledToFill()
                .frame(width: item.imageSize.width, height: item.imageSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemGray5))
                        
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(.systemGray5))
                }
                .padding(5)
                .overlay(alignment: .bottomTrailing) {
                    timeStampTextView()
                }
            
            if !item.text.isEmptyOrWhitespace {
                Text(item.text)
                    .padding([.horizontal, .bottom], 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(width: item.imageSize.width)
            }
        }
        .background(item.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .applyTail(item.direction)
    }
    
    private func shareButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .padding(10)
                .foregroundColor(.white)
                .background(Color.gray)
                .background(.thinMaterial)
                .clipShape(Circle())
        }
    }
    
    private func timeStampTextView() -> some View {
        HStack {
            Text("11.11 AM")
                .font(.system(size: 12))
                
            if item.direction == .sent {
                Image(.seen)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 15, height: 15)
            }
        }
        .padding(.vertical, 2.5)
        .padding(.horizontal, 8)
        .foregroundStyle(.white)
        .background(.thinMaterial)
        .clipShape(Capsule())
        .padding(12)
    }
}

#Preview {
    ScrollView {
        BubbleImageView(item: .sentPlaceholder)
        BubbleImageView(item: .receivedPlaceholder)
    }
    .frame(maxWidth: .infinity)
    .padding(.horizontal)
    .background(Color(.systemGroupedBackground))
}
