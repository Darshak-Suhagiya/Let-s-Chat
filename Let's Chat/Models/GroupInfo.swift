//
//  GroupInfo.swift
//  Let-s Chat
//
//  Created by Darshak on 13/04/23.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseCore


struct GroupInfo{
    let ref: DatabaseReference?
    let key: String
    let groupName: String
    let imageURL: String
    let timeStamp: String
    let adminUid:String
    let isDeleted: Bool


    
    init(groupName: String, imageURL: String, timeStamp: String, adminUid: String) {
        self.ref = nil
        self.key = ""
        self.groupName = groupName
        self.imageURL = imageURL
        self.timeStamp = timeStamp
        self.adminUid = adminUid
        self.isDeleted = false
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let groupName = value["groupName"] as? String,
            let imageURL = value["imageURL"] as? String,
            let timeStamp = value["timeStamp"] as? String,
            let adminUid = value["adminUid"] as? String,
            let isDeleted = value["isDeleted"] as? Int
        else {
          return nil
        }

        self.ref = snapshot.ref
        self.key = snapshot.key
        self.groupName = groupName
        self.imageURL = imageURL
        self.timeStamp = timeStamp
        self.adminUid = adminUid
        self.isDeleted = isDeleted == 0 ? false : true
    }
    
    func toAnyObject() -> Any {
      return [
        "groupName": groupName,
        "imageURL": imageURL,
        "timeStamp": timeStamp,
        "adminUid": adminUid,
        "isDeleted": isDeleted
      ]
    }
    
    
}
