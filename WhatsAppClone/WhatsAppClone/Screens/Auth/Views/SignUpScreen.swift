//
//  SignUpScreen.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 10.01.2025.
//

import SwiftUI

struct SignUpScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authScreenModel: AuthScreenModel
    
    var body: some View {
        VStack {
            Spacer()
            
            AuthHeaderView()
                .padding(.bottom, 32)
            
            AuthTextField(type: .email, text: $authScreenModel.email)
            
            let usernameInputType = AuthTextField.InputType.custom("Username", "at")
            AuthTextField(type: usernameInputType, text: $authScreenModel.username)
            
            AuthTextField(type: .password, text: $authScreenModel.password)
            
            AuthButton(title: "Sign up") {
                Task {
                    await authScreenModel.handleSignUp()
                }
            }
            .padding(.top, 16)
            .disabled(authScreenModel.disableSignUpButton)
            
            Spacer()
            
            backButton()
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
    
    private func backButton() -> some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Text("Already have an account?")
                
                Text("Sign in")
                    .bold()
            }
            .foregroundStyle(.white)
        }
    }

}

#Preview {
    SignUpScreen(authScreenModel: AuthScreenModel())
}
