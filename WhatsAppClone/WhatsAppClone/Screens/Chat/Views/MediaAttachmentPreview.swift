//
//  MediaAttachmentPreview.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 21.01.2025.
//

import SwiftUI

struct MediaAttachmentPreview: View {
    let mediaAttachments: [MediaAttachment]
    let actionHandler: (_ action: UserAction) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(mediaAttachments) { attachment in
                    if attachment.type == .audio(.stubURL, .stubTimeInterval) {
                        audioAttachmentPreview(attachment)
                    } else {
                        thumbnailImageView(attachment)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: Constants.listHeight)
        .frame(maxWidth: .infinity)
        .background(.whatsAppWhite)
    }
    
    private func thumbnailImageView(_ attachment: MediaAttachment) -> some View {
        Button {
            
        } label: {
            Image(uiImage: attachment.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: Constants.imageDimension, height: Constants.imageDimension)
                .cornerRadius(5)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    cancelButton(attachment)
                }
                .overlay {
                    playButton("play.fill", attachment: attachment)
                        .opacity(attachment.type == .video(UIImage(), .stubURL)
                                 ? 1 : 0)
                }
        }
    }
    
    private func cancelButton(_ attachment: MediaAttachment) -> some View {
        Button {
            actionHandler(.remove(attachment))
        } label: {
            Image(systemName: "xmark")
                .scaledToFit()
                .imageScale(.small)
                .padding(5)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func playButton(_ systemName: String, attachment: MediaAttachment) -> some View {
        Button {
            actionHandler(.play(attachment))
        } label: {
            Image(systemName: systemName)
                .scaledToFit()
                .imageScale(.large)
                .padding(10)
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding(2)
                .bold()
        }
    }
    
    private func audioAttachmentPreview(_ attachment: MediaAttachment) -> some View {
        ZStack {
            LinearGradient(colors: [.green, .green.opacity(0.8), .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            playButton("mic.fill", attachment: attachment)
        }
        .frame(width: Constants.imageDimension * 2, height: Constants.imageDimension)
        .cornerRadius(5)
        .clipped()
        .overlay(alignment: .topTrailing) {
            cancelButton(attachment)
        }
    }
}

extension MediaAttachmentPreview {
    enum Constants {
        static let listHeight: CGFloat = 100
        static let imageDimension: CGFloat = 80
    }
    
    enum UserAction {
        case play(_ item: MediaAttachment)
        case remove(_ item: MediaAttachment)
    }
}

#Preview {
    MediaAttachmentPreview(mediaAttachments: []) { _ in
        
    }
}
