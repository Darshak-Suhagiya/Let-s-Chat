//
//  ChatListViewController.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 28/03/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class ChatListViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorLoader: UIActivityIndicatorView!
    
    let chatInfoReferance = Database.database().reference(withPath: "chatInfo")
    var chatInfoObservers:[DatabaseHandle] = []
    
    let onlineReferance = Database.database().reference(withPath: "Online")
    var onlineObservers:[DatabaseHandle] = []
    
    let userReferance = Database.database().reference(withPath: "users")
    var userObservers:[DatabaseHandle] = []
    
    var chatInfosMessagesObservers:[DatabaseHandle] = []
    
    var chatInfos:[ChatInfo] = []
    var onlineUsers:[String] = []
    var users: [String:UserInfo] = [:]
    var lastMessages:[String:Message] = [:]
    var noSeenMessageCount:[String:Int] = [:]
    let currentUserUid = Auth.auth().currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatListCell")
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        indicatorLoader.layer.cornerRadius = 12
        
        let userObserver = userReferance.observe(.value){ snapshot in
            
            var tempUsers:[String:UserInfo] = [:]
            let currentUserUid = Auth.auth().currentUser?.uid

            for child in snapshot.children{
                if
                    let snap = child as? DataSnapshot,
                    let user = UserInfo(snapshot: snap){
                    if user.key != currentUserUid{
                        tempUsers[user.key] = user
                    }
                }
            }
            print("---------------user_added----------------")
            self.users = tempUsers
        }
        self.userObservers.append(userObserver)
        
        let chatInfoObserver = chatInfoReferance.observe(.value){ snapshot in
            var tempChatInfos:[ChatInfo] = []
            
            for child in snapshot.children{
                if let snap = child as? DataSnapshot,
                   let chatInfo = ChatInfo(snapshot: snap){
                    if chatInfo.person1_uid == self.currentUserUid || chatInfo.person2_uid == self.currentUserUid{
                        tempChatInfos.append(chatInfo)
                        
                    }
                }
            }
            
            print("-----------------chatInfoAdded--------------------")
            

            for i in self.chatInfos{
                let messageRef = Database.database().reference(withPath: "Messages").child(i.key)
                messageRef.removeAllObservers()
            }
            
            self.chatInfos = tempChatInfos
            
            for i in self.chatInfos{
                let messageRef = Database.database().reference(withPath: "Messages").child(i.key)
                
                messageRef.observe(.childAdded){snap in
                    messageRef
                        .queryOrdered(byChild: "timeStamp")
                        .queryLimited(toLast: 1).observeSingleEvent(of: .value){ snapshot in
                            if let lastMessage = Message(snapshot: snap){
                                self.lastMessages[i.key] = lastMessage
                            }
                            self.tableView.reloadData()
                        }
                }
                
                messageRef.queryOrdered(byChild: "isReaded")
                    .queryEqual(toValue: false)
                    .observe(.value){snapshot in
                        
                        var count = 0
                        for child in snapshot.children{
                            if let snap = child as? DataSnapshot,
                               let message = Message(snapshot: snap){
                                if message.senderUid != self.currentUserUid{
                                    count += 1
                                }
                            }
                        }
                        self.noSeenMessageCount[i.key] = count
                        self.tableView.reloadData()
                    }
                
            }
            
            self.indicatorLoader.stopAnimating()
            self.tableView.reloadData()
            
            
            
        }
        self.chatInfoObservers.append(chatInfoObserver)
        
        let onlineObserver = onlineReferance.observe(.value){ snapshot in
            
            var tempOnlineUsers:[String] = []
            
            for child in snapshot.children{
                if let snap = child as? DataSnapshot{
                    tempOnlineUsers.append(snap.key)
                }
            }
            self.onlineUsers = tempOnlineUsers
            self.tableView.reloadData()
        }
        self.onlineObservers.append(onlineObserver)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatInfoObservers.forEach(chatInfoReferance.removeObserver(withHandle:))
        chatInfoObservers = []
        
        userObservers.forEach(userReferance.removeObserver(withHandle:))
        userObservers = []
        
        onlineObservers.forEach(onlineReferance.removeObserver(withHandle:))
        onlineObservers = []
        
        for i in self.chatInfos{
            let messageRef = Database.database().reference(withPath: "Messages").child(i.key)
            messageRef.removeAllObservers()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            let st = UIStoryboard(name: "Main", bundle: nil)
            let vc = st.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            
            changeWindow(from: self, to: vc)
            
        } catch {
            alertTheUser(self, string: "Sign Out Error")
        }
        
    }
    
    @IBAction func tapOnNewChat(_ sender: Any) {
        
        let vc = NewChatViewController(nibName: "NewChatViewController", bundle: nil)
        //        navigationController?.pushViewController(vc, animated: true)
        present(vc, animated: true)
        
        
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListTableViewCell
        let currentChatInfo = chatInfos[indexPath.row]
        let uid = currentChatInfo.person1_uid == currentUserUid ? currentChatInfo.person2_uid : currentChatInfo.person1_uid
        let user = users[uid]
        cell.personImage.sd_setImage(with: URL(string: user?.imageUrl ?? ""), placeholderImage: UIImage(named: "Avatar"))
        cell.personName.text = user?.fullname()
        cell.personStatus.isHidden = !onlineUsers.contains(uid)
        if let lastMessage = lastMessages[chatInfos[indexPath.row].key]{
            cell.lastMessage.isHidden = false
            cell.timeLabel.isHidden = false
            cell.lastMessage.text = lastMessage.msg
            cell.timeLabel.text = lastMessage.getDateForTimeLabel()
        }
        else{
            cell.lastMessage.isHidden = true
            cell.timeLabel.isHidden = true
        }
        if let count = noSeenMessageCount[chatInfos[indexPath.row].key]{
            if count == 0{
                cell.pendingMessageLabel.isHidden = true
                cell.pendingMessageLablelView.isHidden = true
                cell.timeLabel.textColor = UIColor(red: 164/255, green: 164/255, blue: 164/255, alpha: 1)
            }
            else{
                cell.pendingMessageLabel.isHidden = false
                cell.pendingMessageLablelView.isHidden = false
                cell.pendingMessageLabel.text = count.description
                cell.timeLabel.textColor = UIColor(red: 44/255, green: 192/255, blue: 105/255, alpha: 1)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 64+8+8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PersonChatViewController(nibName: "PersonChatViewController", bundle: nil)
        vc.currentUserUid = currentUserUid
        
        let currenChatInfo = chatInfos[indexPath.row]
        let uid = currenChatInfo.person1_uid == currentUserUid ? currenChatInfo.person2_uid : currenChatInfo.person1_uid
        vc.otherUser = users[uid] ?? UserInfo()
        
        vc.chatId = currenChatInfo.key
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
