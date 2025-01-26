//
//  UIApplicationExtensions.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 26.01.2025.
//

import UIKit

extension UIApplication {
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
