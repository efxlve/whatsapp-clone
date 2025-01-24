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
    
    private(set) var channel: ChannelItem
    private var subscriptions = Set<AnyCancellable>()
    private var currentUser: UserItem?
    private var voiceRecorderService = VoiceRecorderService()
    
    var showPhotoPickerPreview: Bool {
        return !mediaAttachments.isEmpty || !photoPickerItems.isEmpty
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
        MessageService.sendTextMessage(to: channel, from: currentUser, textMessage) {[weak self] in
            self?.textMessage = ""
        }
    }
    
    private func getMessages() {
        MessageService.getMessages(for: channel) {[weak self] messages in
            self?.messages = messages
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
}
