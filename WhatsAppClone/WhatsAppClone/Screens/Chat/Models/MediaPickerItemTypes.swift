//
//  MediaPickerItemTypes.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 22.01.2025.
//

import SwiftUI

struct VideoPickerTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { exportingFile in
            return .init(exportingFile.url)
        } importing: { receivedTransferredFile in
            let originalURL = receivedTransferredFile.file
            let uniqueFileName = "\(UUID().uuidString).mov"
            let copiedFile = URL.documentsDirectory.appendingPathComponent(uniqueFileName)
            try FileManager.default.copyItem(at: originalURL, to: copiedFile)
            return .init(url: copiedFile)
        }
    }
}

struct MediaAttachment: Identifiable {
    let id: String
    let type: MediaAttachmentType
    
    var thumbnail: UIImage {
        switch type {
        case .photo(let thumbnail):
            return thumbnail
        case .video(let thumbnail, _):
            return thumbnail
        case .audio:
            return UIImage()
        }
    }
    
    var fileURL: URL? {
        switch type {
            case .photo:
                return nil
            case .video(_, let fileURL):
                return fileURL
            case .audio(let voiceURL, _):
                return voiceURL
        }
    }
    
    var audioDuration: TimeInterval? {
        switch type {
        case .audio(_, let duration):
            return duration
        default:
            return nil
        }
    }
}

enum MediaAttachmentType {
    case photo(_ thumbnail: UIImage)
    case video(_ thumbnail: UIImage, _ url: URL)
    case audio(_ url: URL, _ duration: TimeInterval)
    
    static func == (lhs: MediaAttachmentType, rhs: MediaAttachmentType) -> Bool {
        switch (lhs, rhs) {
        case (.photo, .photo), (.video, .video), (.audio, .audio):
            return true
            
        default:
            return false
        }
    }
}
