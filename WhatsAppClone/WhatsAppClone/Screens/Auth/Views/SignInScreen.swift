//
//  SignInScreen.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 10.01.2025.
//

import SwiftUI

struct SignInScreen: View {
    @StateObject private var authScreenModel = AuthScreenModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                AuthHeaderView()
                    .padding(.bottom, 32)
                
                AuthTextField(type: .email, text: $authScreenModel.email)
                AuthTextField(type: .password, text: $authScreenModel.password)
                
                forgotPasswordButton()
                
                AuthButton(title: "Sign in") {
                    Task {
                        await authScreenModel.handleSignIn()
                    }
                }
                .disabled(authScreenModel.disableSignInButton)
                
                Spacer()

                signUpButton()
                    .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom)
            }
            .ignoresSafeArea()
            .alert(isPresented: $authScreenModel.errorState.showError) {
                Alert(title: Text(authScreenModel.errorState.errorMessage), dismissButton: .default(Text("OK")))
            }
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
            SignUpScreen(authScreenModel: authScreenModel)
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
