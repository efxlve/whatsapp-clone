//
//  PhotosPickerItemExtensions.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 22.01.2025.
//

import Foundation
import PhotosUI
import SwiftUI

extension PhotosPickerItem {
    var isVideo: Bool {
        let videoUTTypes: [UTType] = [
            .avi,
            .video,
            .mpeg2Video,
            .mpeg4Movie,
            .movie,
            .quickTimeMovie,
            .audiovisualContent,
            .mpeg,
            .appleProtectedMPEG4Audio,
            .appleProtectedMPEG4Video
        ]
        return videoUTTypes.contains(where:supportedContentTypes.contains)
    }
}
