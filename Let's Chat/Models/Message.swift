//
//  Message.swift
//  Let-s Chat
//
//  Created by Darshak on 04/04/23.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseCore


struct Message{
    let ref: DatabaseReference?
    let key: String
    let senderUid: String
    let msg: String
    let timeStamp: String
    let isReaded: Bool
    let isDeleted: Bool
    let isDateChange: Bool
    let isExtraStuff: Bool
    

    init(){
        self.ref = nil
        self.key = ""
        self.senderUid = ""
        self.msg = ""
        self.timeStamp = Date().timeIntervalSince1970.description
        self.isReaded = false
        self.isDeleted = false
        self.isDateChange = false
        self.isExtraStuff = false
    }
    
    init(senderUid: String, msg: String, timeStamp: String, isReaded: Bool = false, isDeleted: Bool = false, isDateChange: Bool = false) {
        self.ref = nil
        self.key = ""
        self.senderUid = senderUid
        self.msg = msg
        self.timeStamp = timeStamp
        self.isReaded = isReaded
        self.isDeleted = isDeleted
        self.isDateChange = isDateChange
        self.isExtraStuff = false
    }
    
    init(msg: String, isExtraStuff: Bool){
        self.ref = nil
        self.key = ""
        self.senderUid = ""
        self.msg = msg
        self.timeStamp = Date().timeIntervalSince1970.description
        self.isReaded = false
        self.isDeleted = false
        self.isDateChange = false
        self.isExtraStuff = isExtraStuff
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let senderUid = value["senderUid"] as? String,
            let msg = value["msg"] as? String,
            let timeStamp = value["timeStamp"] as? String,
            let isReaded = value["isReaded"] as? Int,
            let isDeleted = value["isDeleted"] as? Int
        else {
          return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.senderUid = senderUid
        self.msg = msg
        self.timeStamp = timeStamp
        self.isReaded = isReaded == 0 ? false : true
        self.isDeleted = isDeleted == 0 ? false : true
        self.isDateChange = false
        if let isExtraStuff = value["isExtraStuff"] as? Int{
            self.isExtraStuff = isExtraStuff == 0 ? false : true
        }
        else{
            self.isExtraStuff = false
        }
    }
    
    func setDateChange() -> Message {
        
        return Message(senderUid: "", msg: "", timeStamp: self.timeStamp, isDateChange: true)
    }
    
    func getDate() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "d MMMM yyyy"
        let currentDate = dateFormater.string(from: Date())
        let DateOfMessage = dateFormater.string(from: Date(timeIntervalSince1970: TimeInterval(timeStamp)!))
        return currentDate == DateOfMessage ? "Today" : DateOfMessage
    }
    
    func getDateForTimeLabel() -> String {
        let date = getDate()
        
        return date == "Today" ? getTime() : date
    }

    func getTime() -> String {
        let timeFormater = DateFormatter()
            timeFormater.locale = Locale(identifier: "en_Us")
            timeFormater.timeStyle = .short
        return timeFormater.string(from: Date(timeIntervalSince1970: TimeInterval(timeStamp)!))
    }
    
    func toAnyObjectForChatMessage() -> Any {
      return [
        "senderUid": senderUid,
        "msg": msg,
        "timeStamp": timeStamp,
        "isReaded": isReaded,
        "isDeleted": isDeleted
      ]
    }
    
    func toAnyObjectForGroupMessage() -> Any {
      return [
        "senderUid": senderUid,
        "msg": msg,
        "timeStamp": timeStamp,
        "isReaded": isReaded,
        "isDeleted": isDeleted,
        "isExtraStuff": isExtraStuff
      ]
    }
    
}


