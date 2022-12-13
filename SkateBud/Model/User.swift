//
//  User.swift
//  SkateBud
//
//  Created by Victor on 2022-10-26.
//

import Foundation
import UIKit

class User {
    var uid: String
    var username: String
    var email: String
    var profileImageUrl: String
    var profileImage = UIImage()
    var status: String
    var experience: String?
    var age: Int?
    var latitude = ""
    var longitude = ""
    
    init(uid: String, username: String, email: String, profileImageUrl: String, status: String)  {
        self.uid = uid
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.status = status
    }
    
    static func transformUser(dict: [String: Any]) -> User? {
        guard let email = dict["email"] as? String,
              let username = dict["username"] as? String,
              let profileImageUrl = dict["profileImageUrl"] as? String,
              let status = dict["status"] as?  String,
              let uid = dict["uid"] as? String else {
                  return nil
              }
        
        let user = User(uid: uid, username: username, email: email, profileImageUrl: profileImageUrl, status: status)
        if let experience = dict["experience"] as? String {
            user.experience = experience
        }
        if let age = dict["age"] as? Int {
            user.age = age
        }
        
        if let latitude = dict["current_latitude"] as? String {
            user.latitude = latitude
        }
        if let longitude = dict["current_longitude"] as? String {
            user.longitude = longitude
        }
        
        return user
    }
    
    func updateData(key: String, value: String) {
        switch key {
        case "username": self.username = value
        case "email": self.email = value
        case "profileImageUrl": self.profileImageUrl = value
        case "status": self.status = value
        default: break
        }
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}
