//
//  SignInScreen.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 10.01.2025.
//

import SwiftUI

struct SignInScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                AuthHeaderView()
                    .padding(.bottom, 32)
                
                AuthTextField(type: .email, text: .constant(""))
                AuthTextField(type: .password, text: .constant(""))
                
                forgotPasswordButton()
                
                AuthButton(title: "Sign in") {
                    
                }
                
                Spacer()

                signUpButton()
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
        }
        .environment(\.colorScheme, .light)
    }
    
    private func forgotPasswordButton() -> some View {
        Button {
            
        } label: {
            Text("Forgot password?")
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 32)
                .padding(.vertical)
        }
    }
    
    private func signUpButton() -> some View {
        NavigationLink {
            SignUpScreen()
        } label: {
            HStack {
                Text("Don't have an account?")
                
                Text("Sign up")
                    .bold()
            }
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    SignInScreen()
}
