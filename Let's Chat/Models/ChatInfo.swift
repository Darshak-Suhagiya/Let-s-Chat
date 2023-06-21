//
//  ChatInfo.swift
//  Let-s Chat
//
//  Created by DUIUX-01 on 03/04/23.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseCore


struct ChatInfo{
    let ref: DatabaseReference?
    let key: String
    let person1_uid: String
    let person2_uid: String
    let timeStamp: String
    let isDeleted: Bool
    
    init() {
        self.ref = nil
        self.key = ""
        self.person1_uid = ""
        self.person2_uid = ""
        self.timeStamp = ""
        self.isDeleted = false
    }
    
    init(person1_uid: String, person2_uid: String, timeStamp: String, isDeleted: Bool = false) {
        self.ref = nil
        self.key = ""
        self.person1_uid = person1_uid
        self.person2_uid = person2_uid
        self.timeStamp = timeStamp
        self.isDeleted = isDeleted
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let person1_uid = value["person1_uid"] as? String,
            let person2_uid = value["person2_uid"] as? String,
            let timeStamp = value["timeStamp"] as? String,
            let isDeleted = value["isDeleted"] as? Int
        else {
          return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.person1_uid = person1_uid
        self.person2_uid = person2_uid
        self.timeStamp = timeStamp
        self.isDeleted = isDeleted == 0 ? false : true
    }
    
    func toAnyObject() -> Any {
      return [
        "person1_uid": person1_uid,
        "person2_uid": person2_uid,
        "timeStamp": timeStamp,
        "isDeleted": isDeleted
      ]
    }
    
}
