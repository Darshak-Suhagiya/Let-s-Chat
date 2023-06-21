//
//  GroupChatListViewController.swift
//  Let-s Chat
//
//  Created by Darshak on 11/04/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class GroupChatListViewController: UIViewController {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    let groupInfoRef = Database.database().reference(withPath: "groups").child("groupInfo")
    let groupsPerPersonRef = Database.database().reference(withPath: "groups").child("groupsPerPerson").child(Auth.auth().currentUser?.uid ?? "")
    
    var allGroupsInfo = [String:GroupInfo]()
    var groupsOfCurrentUser = [String]()
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
        
        indicatorView.layer.cornerRadius = 12
        
        let groupInfoObserver = groupInfoRef.observe(.value, with: { snapshot in
            var tempGroupsInfo = [String:GroupInfo]()
            for child in snapshot.children{
                if let snap = child as? DataSnapshot,
                let groupInfo = GroupInfo(snapshot: snap){
                    tempGroupsInfo[groupInfo.key] = groupInfo
                }
            }
            self.allGroupsInfo = tempGroupsInfo
            self.tableView.reloadData()
        })
        
        let groupsPerPersonObserver = groupsPerPersonRef.observe(.value, with: { snapshot in
            var tempGroups = [String]()
            
            for child in snapshot.children{
                if let snap = child as? DataSnapshot,
                   let value = snap.value as? String{
                    tempGroups.append(value)
                }
            }
            self.groupsOfCurrentUser = tempGroups
            self.indicatorView.stopAnimating()
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        groupInfoRef.removeAllObservers()
        groupsPerPersonRef.removeAllObservers()
    }
    

    @IBAction func onTapAddGroup(_ sender: Any) {
        let vc = PersonListForNewGroupViewController(nibName: "PersonListForNewGroupViewController", bundle: nil)
        let rootNC = UINavigationController(rootViewController: vc)
        self.present(rootNC, animated: true)
    }
}

extension GroupChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groupsOfCurrentUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListTableViewCell
        let currentGroupKey = groupsOfCurrentUser[indexPath.row]
        let currentGroupInfo = allGroupsInfo[currentGroupKey]
        
        cell.personImage.sd_setImage(with: URL(string: currentGroupInfo?.imageURL ?? ""), placeholderImage: UIImage(named: "Avatar"))
        cell.personName.text = currentGroupInfo?.groupName
        cell.personStatus.isHidden = true
        
//        if let lastMessage = lastMessages[chatInfos[indexPath.row].key]{
//            cell.lastMessage.isHidden = false
//            cell.timeLabel.isHidden = false
//            cell.lastMessage.text = lastMessage.msg
//            cell.timeLabel.text = lastMessage.getDateForTimeLabel()
//        }
//        else{
//            cell.lastMessage.isHidden = true
//            cell.timeLabel.isHidden = true
//        }
//        if let count = noSeenMessageCount[chatInfos[indexPath.row].key]{
//            if count == 0{
//                cell.pendingMessageLabel.isHidden = true
//                cell.pendingMessageLablelView.isHidden = true
//                cell.timeLabel.textColor = UIColor(red: 164/255, green: 164/255, blue: 164/255, alpha: 1)
//            }
//            else{
//                cell.pendingMessageLabel.isHidden = false
//                cell.pendingMessageLablelView.isHidden = false
//                cell.pendingMessageLabel.text = count.description
//                cell.timeLabel.textColor = UIColor(red: 56/255, green: 162/255, blue: 123/255, alpha: 1)
//            }
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 64+8+8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GroupChatViewController(nibName: "GroupChatViewController", bundle: nil)
        vc.currentUserUid = currentUserUid
        
        let currentGroupKey = groupsOfCurrentUser[indexPath.row]
        let currentGroupInfo = allGroupsInfo[currentGroupKey]
        
        vc.currentGroupInfo = currentGroupInfo
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
