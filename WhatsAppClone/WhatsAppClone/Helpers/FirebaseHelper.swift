//
//  FirebaseHelper.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 24.01.2025.
//

import Foundation
import UIKit
import FirebaseStorage

typealias UploadResult = (Result<URL, Error>) -> Void
typealias ProgressHandler = (Double) -> Void

enum UploadError: Error {
    case failedToUploadImage(_ description: String)
    case failedToUploadFile(_ description: String)
}

extension UploadError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToUploadImage(let description), .failedToUploadFile(let description):
            return description
        }
    }
}

struct FirebaseHelper {
    static func uploadImge(_ image: UIImage, for type: UploadType, completion: @escaping UploadResult, progressHandler: @escaping ProgressHandler) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let storageRef = type.filePath
        let uploadTask = storageRef.putData(imageData) { metadata, error in
            if let error = error {
                completion(.failure(UploadError.failedToUploadImage(error.localizedDescription)))
                return
            }
            
            storageRef.downloadURL(completion: completion)
                
        }
        
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
            progressHandler(percentage)
        }
    }
    
    static func uploadFile(for type: UploadType, fileURL: URL, completion: @escaping UploadResult, progressHandler: @escaping ProgressHandler) {
        let storageRef = type.filePath
        let uploadTask = storageRef.putFile(from: fileURL) { metadata, error in
            if let error = error {
                completion(.failure(UploadError.failedToUploadFile(error.localizedDescription)))
                return
            }
            
            storageRef.downloadURL(completion: completion)
            
        }
        
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentage = Double(progress.completedUnitCount / progress.totalUnitCount)
            progressHandler(percentage)
        }
    }
}

extension FirebaseHelper {
    enum UploadType {
        case profile
        case photoMessage
        case videoMessage
        case voiceMessage
        
        var filePath: StorageReference {
            let filename = UUID().uuidString
            
            switch self {
            case .profile:
                return FirebaseConstants.StorageRef.child("profile_images").child(filename)
            case .photoMessage:
                return FirebaseConstants.StorageRef.child("photo_messages").child(filename)
            case .videoMessage:
                return FirebaseConstants.StorageRef.child("video_messages").child(filename)
            case .voiceMessage:
                return FirebaseConstants.StorageRef.child("voice_messages").child(filename)
            }
        }
    }
}
