//
//  UserInfo.swift
//  Let-s Chat
//
//  Created by DUIUX-01 on 30/03/23.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseCore


struct UserInfo{
    let ref: DatabaseReference?
    let key: String
    let firstName: String
    let fullName: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let imageUrl: String
    let FCMToken : String
    let isDeleted: Bool
    
    init() {
        self.ref = nil
        self.key = ""
        self.firstName = ""
        self.fullName = ""
        self.lastName = ""
        self.email = ""
        self.phoneNumber = ""
        self.imageUrl = ""
        self.FCMToken = ""
        self.isDeleted = false
    }
    
    
    init(firstName: String, lastName: String, email: String, phoneNumber: String, imageUrl: String, isDeleted: Bool = false, key: String = "") {
        self.ref = nil
        self.key = key
        self.firstName = firstName
        self.fullName = "\(firstName) \(lastName)"
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.imageUrl = imageUrl
        self.FCMToken = ""
        self.isDeleted = isDeleted
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let firstName = value["firstName"] as? String,
            let lastName = value["lastName"] as? String,
            let email = value["email"] as? String,
            let phoneNumber = value["phoneNumber"] as? String,
            let imageUrl = value["imageUrl"] as? String,
            let FCMToken = value["FCMToken"] as? String,
            let isDeleted = value["isDeleted"] as? Int
        else {
          return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = "\(firstName) \(lastName)"
        self.email = email
        self.phoneNumber = phoneNumber
        self.imageUrl = imageUrl
        self.FCMToken = FCMToken
        self.isDeleted = isDeleted == 0 ? false : true
    }
    
    func fullname() -> String{
        return self.fullName
    }	
    
    func toAnyObject() -> Any {
      return [
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phoneNumber": phoneNumber,
        "imageUrl": imageUrl,
        "FCMToken": FCMToken,
        "isDeleted": isDeleted
      ]
    }
    
}

