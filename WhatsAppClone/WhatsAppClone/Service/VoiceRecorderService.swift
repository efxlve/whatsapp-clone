//
//  VoiceRecorderService.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 24.01.2025.
//

import Foundation
import AVFoundation
import Combine

final class VoiceRecorderService {
    private var audioRecorder: AVAudioRecorder?
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    private var startRecordingDate: Date?
    private var timer: AnyCancellable?
    
    deinit {
        tearDown()
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = Date().toString(format: "dd-MM-YY 'at' HH:mm:ss") + ".m4a"
        let audioFilePath = documentPath.appendingPathComponent(audioFileName)
        
        let audioSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: audioSettings)
            audioRecorder?.record()
            isRecording = true
            startRecordingDate = Date()
            startTimer()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
      
    func stopRecording(completion: ((_ audioURL: URL?, _ audioDuration: TimeInterval) -> Void)? = nil) {
        
        guard isRecording else { return }
        let audioDuration = elapsedTime
        audioRecorder?.stop()
        isRecording = false
        timer?.cancel()
        elapsedTime = 0
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            guard let audioURL = audioRecorder?.url else { return }
            completion?(audioURL, audioDuration)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func tearDown() {
        if isRecording {
            stopRecording()
        }
        let filemanager = FileManager.default
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderContents = try? filemanager.contentsOfDirectory(atPath: documentPath.path)
        deleteRecordings(folderContents?.compactMap { documentPath.appendingPathComponent($0) } ?? [])
    }
    
    private func deleteRecordings(_ urls: [URL]) {
        for url in urls {
            deleteRecording(at: url)
        }
    }
    
    func deleteRecording(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let startTime = self?.startRecordingDate else { return }
                self?.elapsedTime = Date().timeIntervalSince(startTime)
                print("Elapsed Time: \(self?.elapsedTime ?? 0)")
            }
    }

}
