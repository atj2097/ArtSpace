//
//  AppUser.swift
//  ArtSpaceDos
//
//  Created by Adam Jackson on 1/30/20.
//  Copyright © 2020 Adam Jackson. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
fileprivate let imageURLKey = "profileImageURL"
struct AppUser {
    let userName: String?
    let email: String?
    let uid: String
    let dateCreated: Date?
    let profileImageURL: String?
    let stripeCustomerId: String?
    
    init(from user: User, stripeId: String) {
        self.userName = user.displayName
        self.email = user.email
        self.uid = user.uid
        self.profileImageURL = user.photoURL?.absoluteString
        self.dateCreated = user.metadata.creationDate
        self.stripeCustomerId = stripeId
    }
    
//    MARK: - Failable init
    init?(from dict: [String: Any], id: String) {
        guard let userName = dict["userName"] as? String,
        let email = dict["email"] as? String,
        let profileImageURL = dict["profileImageURL"] as? String, let stripeId = dict["stripeCustomerId"] as? String,
        let dateCreated = (dict["dateCreated"] as? Timestamp)?.dateValue() else {return nil}
        self.userName = userName
        self.email = email
        self.dateCreated = dateCreated
        self.uid = id
      self.profileImageURL = profileImageURL
        self.stripeCustomerId = stripeId
    }
    
    var fieldsDict: [String:Any] {

        return ["userName": self.userName ?? "", "email": self.email ?? "", "uid": self.uid, "profileImageURL": self.profileImageURL ?? "", "stripeCustomerId": stripeCustomerId ?? "" ]
    }
    
}
