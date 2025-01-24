//
//  TextInputArea.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 8.01.2025.
//

import SwiftUI

struct TextInputArea: View {
    @Binding var textMessage: String
    @Binding var isRecording: Bool
    @Binding var elsapsedTime: TimeInterval
    
    @State private var isPulsing = false
    
    let actionHandler: (_ action: UserAction) -> Void
    
    private var disableSendButton: Bool {
        return textMessage.isEmptyOrWhitespace || isRecording
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            imagePickerButton()
                .padding(3)
                .disabled(isRecording)
                .grayscale(isRecording ? 0.8 : 0)
            
            audioRecorderButton()
            
            if isRecording {
                audioSessionIndicatorView()
            } else {
                messageTextField()
            }

            sendMessageButton()
                .disabled(disableSendButton)
                .grayscale(disableSendButton ? 0.8 : 0)
        }
        .padding(.bottom)
        .padding(.horizontal)
        .padding(.top, 10)
        .background(.whatsAppWhite)
        .animation(.spring, value: isRecording)
        .onChange(of: isRecording) { _, isRecording in
            if !isRecording {
                withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                    isPulsing = true
                }
            } else {
                isPulsing = false
            }
        }
    }
    
    private func audioSessionIndicatorView() -> some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(.red)
                .font(.caption)
                .scaleEffect(isPulsing ? 1.8 : 1.0)
            
            Text("Recording Audio..")
                .font(.callout)
                .lineLimit(1)
            
            Spacer()
            
            Text(elsapsedTime.formatElapsedTime)
                .font(.callout)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .frame(height: 30)
        .frame(maxWidth: .infinity)
        .clipShape(Capsule())
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.blue.opacity(0.1)
            )
        )
        .overlay(textViewBorder())
    }
    
    private func messageTextField() -> some View {
        TextField("", text: $textMessage, axis: .vertical)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemGray5))
            )
            .overlay(textViewBorder())
    }
    
    private func textViewBorder() -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color(.systemGray5), lineWidth: 1)
    }
    
    private func imagePickerButton() -> some View {
        Button {
            actionHandler(.presentPhotoPicker)
        } label: {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 22))
        }
    }
    
    private func audioRecorderButton() -> some View {
        Button {
            actionHandler(.recordAudio)
            isRecording.toggle()
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                isPulsing.toggle()
            }
        } label: {
            Image(systemName: isRecording ? "square.fill" : "mic.fill")
                .fontWeight(.heavy)
                .imageScale(.small)
                .foregroundColor(.white)
                .padding(6)
                .background(isRecording ? .red : .blue)
                .clipShape(Circle())
                .padding(.horizontal, 3)
        }
    }
    
    private func sendMessageButton() -> some View {
        Button {
            actionHandler(.sendMessage)
        } label: {
            Image(systemName: "arrow.up")
                .fontWeight(.heavy)
                .foregroundStyle(.white)
                .padding(6)
                .background(.blue)
                .clipShape(Circle())
        }
    }
}

extension TextInputArea {
    enum UserAction {
        case presentPhotoPicker
        case sendMessage
        case recordAudio
    }
}

#Preview {
    TextInputArea(textMessage: .constant(""), isRecording: .constant(false), elsapsedTime: .constant(0)) { action in
    }
}
