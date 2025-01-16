//
//  AuthTextField.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 10.01.2025.
//

import SwiftUI

struct AuthTextField: View {
    let type: InputType
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: type.imageName)
                .fontWeight(.semibold)
                .frame(width: 30)
            
            switch type {
            case .password:
                SecureField("Password", text: $text)
            default:
                TextField(type.placeholder, text: $text)
                    .keyboardType(type.keyboardType)
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color.white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 32)
    }
}

extension AuthTextField {
    enum InputType {
        case email
        case password
        case custom(_ placeholder: String, _ iconName: String)
        
        var placeholder: String {
            switch self {
            case .email:
                return "Email"
            case .password:
                return "Password"
            case .custom(let placeholder, _):
                return placeholder
            }
        }
        
        var imageName: String {
            switch self {
            case .email:
                return "envelope"
            case .password:
                return "lock"
            case .custom(_, let iconName):
                return iconName
            }
        }
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .email:
                return .emailAddress
            case .password:
                return .default
            case .custom:
                return .default
            }
        }
    }
}

#Preview {
    ZStack {
        Color.teal
        VStack {
            AuthTextField(type: .email, text: .constant(""))
            AuthTextField(type: .password, text: .constant(""))
            AuthTextField(type: .custom("Custom", "person"), text: .constant(""))
        }
    }
}
