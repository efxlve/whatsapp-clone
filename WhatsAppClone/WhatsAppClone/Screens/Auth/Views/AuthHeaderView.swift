//
//  AuthHeaderView.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 10.01.2025.
//

import SwiftUI

struct AuthHeaderView: View {
    var body: some View {
        HStack {
            Image(.whatsapp)
                .resizable()
                .frame(width: 50, height: 50)
            
            Text("WhatsApp")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    AuthHeaderView()
}
