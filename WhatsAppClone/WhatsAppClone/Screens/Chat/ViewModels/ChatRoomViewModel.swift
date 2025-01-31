//
//  ChatRoomViewModel.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 15.01.2025.
//

import Foundation
import Combine
import PhotosUI
import SwiftUI

final class ChatRoomViewModel: ObservableObject {
    @Published var textMessage = ""
    @Published var messages = [MessageItem]()
    @Published var showPhotoPicker = false
    @Published var photoPickerItems: [PhotosPickerItem] = []
    @Published var mediaAttachments: [MediaAttachment] = []
    @Published var videoPlayerState: (show: Bool, player: AVPlayer?) = (false, nil)
    @Published var isRecordingVoiceMessage = false
    @Published var elapsedVoiceMessageTime: TimeInterval = 0
    @Published var scrollToBottomRequest: (scroll: Bool, isAnimated: Bool) = (false, false)
    
    private(set) var channel: ChannelItem
    private var subscriptions = Set<AnyCancellable>()
    private var currentUser: UserItem?
    private var voiceRecorderService = VoiceRecorderService()
    
    var showPhotoPickerPreview: Bool {
        return !mediaAttachments.isEmpty || !photoPickerItems.isEmpty
    }
    
    var disableSendButton: Bool {
        return mediaAttachments.isEmpty && textMessage.isEmptyOrWhitespace
    }
    
    init(_ channel: ChannelItem) {
        self.channel = channel
        listenToAuthState()
        onPhotoPickerSelection()
        setUpVoiceRecorderListeners()
    }
    
    deinit {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        currentUser = nil
        voiceRecorderService.tearDown()
    }
    
    private func listenToAuthState() {
        AuthManager.shared.authState.receive(on: DispatchQueue.main).sink {[weak self] authState in
            guard let self = self else { return }
            switch authState {
            case .authenticated(let currentUser):
                self.currentUser = currentUser
                
                if self.channel.allMembersFetched {
                    self.getMessages()
                } else {
                    self.getAllChannelMembers()
                }
                
            default:
                break
            }
        }.store(in: &subscriptions)
    }
    
    private func setUpVoiceRecorderListeners() {
        voiceRecorderService.$isRecording.receive(on: DispatchQueue.main).sink {[weak self] isRecording in
            self?.isRecordingVoiceMessage = isRecording
        }.store(in: &subscriptions)
        
        voiceRecorderService.$elapsedTime.receive(on: DispatchQueue.main).sink {[weak self] elapsedTime in
            self?.elapsedVoiceMessageTime = elapsedTime
        }.store(in: &subscriptions)
    }
    
    func sendMessage() {
        guard let currentUser else { return }
        if mediaAttachments.isEmpty {
            MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) {[weak self] in
                self?.textMessage = ""
            }
        } else {
            sendMultipleMediaMessages(textMessage, attachments: mediaAttachments)
            clearTextInputArea()
        }
    }
    
    private func clearTextInputArea() {
        mediaAttachments.removeAll()
        photoPickerItems.removeAll()
        textMessage = ""
        UIApplication.dismissKeyboard()
    }
    
    private func sendMultipleMediaMessages(_ text: String, attachments: [MediaAttachment]) {
        mediaAttachments.forEach { attachment in
            switch attachment.type {
            case .photo:
                sendPhotoMessage(text: text, attachment)
            case .video:
                sendvideoMessage(text: text, attachment)
            case .audio:
                sendVoiceMessage(text: text, attachment)
            }
        }
    }
    
    private func sendPhotoMessage(text: String, _ attachment: MediaAttachment) {
        uploadImageToStorage(attachment) {[weak self] imageUrl in
            guard let self = self, let currentUser else { return }
            let uploadParams = MessageUploadParams(
                channel: channel,
                text: text,
                type: .photo,
                attachment: attachment,
                thumbnailURL: imageUrl.absoluteString,
                sender: currentUser
            )
            
            MessageService.sendMediaMessage(to: channel, params: uploadParams) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
        }
    }
    
    private func sendvideoMessage(text: String, _ attachment: MediaAttachment) {
        uploadFileToStorage(for: .videoMessage, attachment: attachment) {[weak self] videoURL in
            self?.uploadImageToStorage(attachment) {[weak self] thumbnailURL in
                guard let self = self, let currentUser else { return }
                let uploadParams = MessageUploadParams(
                    channel: self.channel,
                    text: text,
                    type: .video,
                    attachment: attachment,
                    thumbnailURL: thumbnailURL.absoluteString,
                    videoURL: videoURL.absoluteString,
                    sender: currentUser
                )
                MessageService.sendMediaMessage(to: channel, params: uploadParams) { [weak self] in
                    self?.scrollToBottom(isAnimated: true)
                    
                }
            }
        }
    }
    
    private func sendVoiceMessage(text: String, _ attachment: MediaAttachment) {
        guard let audioDuration = attachment.audioDuration, let currentUser = self.currentUser else { return }
        uploadFileToStorage(for: .voiceMessage, attachment: attachment) { [weak self] fileURL in
            guard let self = self else { return }
            let uploadParams = MessageUploadParams(
                channel: self.channel,
                text: text,
                type: .audio,
                attachment: attachment,
                sender: currentUser,
                audioURL: fileURL.absoluteString,
                audioDuration: audioDuration
            )
            
            MessageService.sendMediaMessage(to: self.channel, params: uploadParams) { [weak self] in
                self?.scrollToBottom(isAnimated: true)
            }
            
        }
    }
    
    private func scrollToBottom(isAnimated: Bool) {
        scrollToBottomRequest.scroll = true
        scrollToBottomRequest.isAnimated = isAnimated
    }
    
    private func uploadImageToStorage(_ attachment: MediaAttachment, completion: @escaping(_ imageUrl: URL) -> Void) {
        FirebaseHelper.uploadImage(attachment.thumbnail, for: .photoMessage) { result in
            switch result {
            case .success(let imageUrl):
                completion(imageUrl)
            case .failure(let error):
                print("Failed to upload image: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Progress: \(progress)")
        }
    }
    
    private func uploadFileToStorage(for uploadType: FirebaseHelper.UploadType, attachment: MediaAttachment, completion: @escaping(_ fileURL: URL) -> Void) {
        guard let fileToUpload = attachment.fileURL else { return }
        FirebaseHelper.uploadFile(for: uploadType, fileURL: fileToUpload) { result in
            switch result {
            case .success(let fileURL):
                completion(fileURL)
            case .failure(let error):
                print("Failed to file upload: \(error.localizedDescription)")
            }
        } progressHandler: { progress in
            print("Progress: \(progress)")
        }
    }
    
    private func getMessages() {
        MessageService.getMessages(for: channel) {[weak self] messages in
            self?.messages = messages
            self?.scrollToBottom(isAnimated: false)
            print("Messages: \(messages.map { $0.text })")
        }
    }
    
    private func getAllChannelMembers() {
        guard let currentUser = currentUser else { return }
        let membersAlreadyFetched = channel.members.compactMap { $0.id }
        var memberUIDSToFetch = channel.memberUids.filter{ !membersAlreadyFetched.contains($0) }
        memberUIDSToFetch = memberUIDSToFetch.filter { $0 != currentUser.uid }
        
        UserService.getUsers(with: memberUIDSToFetch) { [weak self] userNode in
            guard let self = self else { return }
            self.channel.members.append(contentsOf: userNode.users)
            self.getMessages()
            print("Members: \(channel.members.map { $0.username })")
        }
    }
    
    func handleTextInputArea(_ action: TextInputArea.UserAction) {
        switch action {
        case .presentPhotoPicker:
            showPhotoPicker = true
        case .sendMessage:
            sendMessage()
        case .recordAudio:
            toggleAudioRecording()
        }
    }
    
    private func toggleAudioRecording() {
        if voiceRecorderService.isRecording {
            voiceRecorderService.stopRecording { [weak self] audioURL, audioDuration in
                self?.createAudioAttachment(audioURL, audioDuration)
            }
        } else {
            voiceRecorderService.startRecording()
        }
    }
    
    private func createAudioAttachment(_ audioURL: URL?, _ audioDuration: TimeInterval) {
        guard let audioURL = audioURL else { return }
        let id = UUID().uuidString
        let audioAttachment = MediaAttachment(id: id, type: .audio(audioURL, audioDuration))
        mediaAttachments.insert(audioAttachment, at: 0)
    }
    
    private func onPhotoPickerSelection() {
        $photoPickerItems.sink { [weak self] photoItems in
            guard let self = self else { return }
            let audioRecordings = self.mediaAttachments.filter { $0.type == .audio(.stubURL, .stubTimeInterval) }
            self.mediaAttachments = audioRecordings
            Task {
                await self.parsePhotoPickerItems(photoItems)
            }
        }.store(in: &subscriptions)
    }
    
    private func parsePhotoPickerItems(_ photoPickerItems: [PhotosPickerItem]) async {
        for photoItem in photoPickerItems {
            if photoItem.isVideo {
                if let movie = try? await photoItem.loadTransferable(type: VideoPickerTransferable.self), let thumbnailImage = try? await movie.url.generateVideoThumbnail(), let itemIdentifier = photoItem.itemIdentifier {
                    let videoAttachment = MediaAttachment(id: itemIdentifier, type: .video(thumbnailImage, movie.url))
                    self.mediaAttachments.insert(videoAttachment, at: 0)
                }
            } else {
                guard
                    let data = try? await photoItem.loadTransferable(type: Data.self),
                    let thumbnail = UIImage(data: data),
                    let itemIdentifier = photoItem.itemIdentifier
                else { return }
                let photoAttachment = MediaAttachment(id: itemIdentifier, type: .photo(thumbnail))
                self.mediaAttachments.insert(photoAttachment, at: 0)
            }
        }
    }
    
    func dismissVideoPlayer() {
        videoPlayerState.player?.replaceCurrentItem(with: nil)
        videoPlayerState.player = nil
        videoPlayerState.show = false
    }
    
    func showMediaPlayer(_ fileURL: URL) {
        videoPlayerState.show = true
        videoPlayerState.player = AVPlayer(url: fileURL)
    }
    
    func handleMediaAttachmentPreview(_ action: MediaAttachmentPreview.UserAction) {
        switch action {
        case .play(let attachment):
            guard let fileURL = attachment.fileURL else { return }
            showMediaPlayer(fileURL)
        case .remove(let attachment):
            remove(attachment)
            guard let fileURL = attachment.fileURL else { return }
            if attachment.type == .audio(.stubURL, .stubTimeInterval) {
                voiceRecorderService.deleteRecording(at: fileURL)
            }
        }
    }
    
    private func remove(_ item: MediaAttachment) {
        guard let attachmentIndex = mediaAttachments.firstIndex(where: { $0.id == item.id }) else { return }
        mediaAttachments.remove(at: attachmentIndex)
        
        guard let photoIndex = photoPickerItems.firstIndex(where: { $0.itemIdentifier == item.id }) else { return }
        photoPickerItems.remove(at: photoIndex)
    }
    
    func isNewDay(for message: MessageItem, at index: Int) -> Bool {
        let priorIndex = max(0, (index - 1))
        let priorMessage = messages[priorIndex]
        return !message.timeStamp.isSameDay(as: priorMessage.timeStamp)
    }
}
