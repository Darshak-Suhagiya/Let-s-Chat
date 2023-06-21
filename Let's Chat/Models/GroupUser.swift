//
//  GroupUser.swift
//  Let-s Chat
//
//  Created by Darshak on 14/04/23.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseCore


struct GroupUser{
    let ref: DatabaseReference?
    let key: String
    let uid: String
    let isAdmin: Bool
    
    init(){
        self.ref = nil
        self.key = ""
        self.uid = ""
        self.isAdmin = false
    }
    
    init(uid: String ,isAdmin: Bool = false) {
        self.ref = nil
        self.key = ""
        self.uid = uid
        self.isAdmin = isAdmin
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let uid = value["uid"] as? String,
            let isAdmin = value["isAdmin"] as? Int
        else {
          return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.uid = uid
        self.isAdmin = isAdmin == 0 ? false : true
    }
    
    func toAnyObject() -> Any {
      return [
        "uid": uid,
        "isAdmin": isAdmin
      ]
    }
    
}

