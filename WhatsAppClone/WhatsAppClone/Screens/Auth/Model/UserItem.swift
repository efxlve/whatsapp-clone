//
//  UserItem.swift
//  WhatsAppClone
//
//  Created by Muharrem Efe Çayırbahçe on 12.01.2025.
//

struct UserItem: Identifiable, Hashable, Decodable {
    let uid: String
    let username: String
    let email: String
    var bio: String? = nil
    var profileImageURL: String? = nil
    
    var id: String {
        return uid
    }
    
    var bioUnwrapped: String {
        return bio ?? "Hey there! I'm using WhatsApp."
    }
    
    static let placeholder = UserItem(uid: "1", username: "efxlve", email: "hi@efxlve.com")
    
    static let placeholders: [UserItem] = [
        UserItem(uid: "1", username: "efxlve", email: "hi@efxlve.com"),
        UserItem(uid: "2", username: "David", email: "david@example.com", bio: "Hello, I'm David."),
        UserItem(uid: "3", username: "Alex", email: "alex@example.com", bio: "Hey, I'm Alex."),
        UserItem(uid: "4", username: "John", email: "john@example.com", bio: "Hi, I'm John."),
        UserItem(uid: "5", username: "Mia", email: "mia@example.com", bio: "Hi, I'm Mia."),
        UserItem(uid: "6", username: "Sophia", email: "sophia@example.com", bio: "Hi, I'm Sophia."),
        UserItem(uid: "7", username: "Emma", email: "emma@example.com", bio: "Hi, I'm Emma."),
        UserItem(uid: "8", username: "Olivia", email: "olivia@example.com", bio: "Hi, I'm Olivia."),
        UserItem(uid: "9", username: "Ava", email: "ava@example.com", bio: "Hi, I'm Ava."),
        UserItem(uid: "10", username: "Isabella", email: "isabella@example.com", bio: "Hi, I'm Isabella")
    ]
}

extension UserItem {
    init(dictionary: [String: Any]) {
        self.uid = dictionary[.uid] as? String ?? ""
        self.username = dictionary[.username] as? String ?? ""
        self.email = dictionary[.email] as? String ?? ""
        self.bio = dictionary[.bio] as? String
        self.profileImageURL = dictionary[.profileImageURL] as? String
    }
}

extension String {
    static let uid = "uid"
    static let username = "username"
    static let email = "email"
    static let bio = "bio"
    static let profileImageURL = "profileImageURL"
}
