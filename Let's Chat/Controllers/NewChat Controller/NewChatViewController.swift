//
//  NewChatViewController.swift
//  Let-s Chat
//
//  Created by DUIUX-01 on 31/03/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SDWebImage

class NewChatViewController: UIViewController {
    
    @IBOutlet weak var supportiveViewForSearchBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var indicatorLoader: UIActivityIndicatorView!
    
    
    let userReferance = Database.database().reference(withPath: "users")
    let chatInfoReferance = Database.database().reference(withPath: "chatInfo")
    var userObservers:[DatabaseHandle] = []
    var chatInfoObservers:[DatabaseHandle] = []
    
    var users: [UserInfo] = []
    var chatUserUids:[String] = []
    var isLoaderLoading:Bool = false
    var isLoaderLoded:Bool = false
    var isDataLoaded:Bool = false
    let currentUserUid = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchTextField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "NewChatTableViewCell", bundle: nil), forCellReuseIdentifier: "NewChatCell")
        
        
        /*      //get current userData
         
         let ref = Database.database().reference().child("users").child(Auth.auth().currentUser?.uid ?? "")
         
         ref.observeSingleEvent(of: .value, with: { snapshot in
         
         if let cur = UserInfo(snapshot: snapshot){
         self.currentUser = cur
         }
         })
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        supportiveViewForSearchBar.layer.cornerRadius = supportiveViewForSearchBar.bounds.height / 2
        indicatorLoader.layer.cornerRadius = 12

        let chatInfoObserver = chatInfoReferance.observe(.value){ snapshot in
            var tempchatUserUid:[String] = []

            for child in snapshot.children{
                if let snap = child as? DataSnapshot,
                   let chatInfo = ChatInfo(snapshot: snap){
                    if chatInfo.person1_uid == self.currentUserUid {
                        tempchatUserUid.append(chatInfo.person2_uid)
                    }
                    else if chatInfo.person2_uid == self.currentUserUid {
                        tempchatUserUid.append(chatInfo.person1_uid)
                    }
                }
            }
            self.chatUserUids = tempchatUserUid

        }
        self.chatInfoObservers.append(chatInfoObserver)
        
        
        let userObserver = userReferance.observe(.value){ snapshot in

            var tempUsers:[UserInfo] = []
            let currentUserUid = Auth.auth().currentUser?.uid
            for child in snapshot.children{
                if
                    let snap = child as? DataSnapshot,
                    let user = UserInfo(snapshot: snap){
                    if user.key != currentUserUid && !self.chatUserUids.contains(user.key){
                        tempUsers.append(user)
                    }
                }
            }
            self.users = tempUsers
            self.isDataLoaded = true
            self.indicatorLoader.stopAnimating()
            self.tableView.reloadData()
        }
        self.userObservers.append(userObserver)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userObservers.forEach(userReferance.removeObserver(withHandle:))
        chatInfoObservers.forEach(chatInfoReferance.removeObserver(withHandle:))
        userObservers = []
        chatInfoObservers = []
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func onClose(_ sender: Any) {
        
        dismiss(animated: true)
        
    }
    
//    func checkIsUserAlredyPresent(personUid: ) -> Bool {
//        for i in chatUserUid{
//
//        }
//    }
    
}

extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewChatCell") as! NewChatTableViewCell
        cell.nameLable.text = users[indexPath.row].fullname()
        cell.userProfileImage.sd_setImage(with: URL(string: users[indexPath.row].imageUrl), placeholderImage: UIImage(named: "Avatar"), completed: {_,_,_,_ in
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUserUid = users[indexPath.row].key
        let currentUserUid = Auth.auth().currentUser?.uid ?? ""
        
//        let chatRoomId = createChatRoomId(index: 0, currentUserUid: currentUserUid, selectedUserUid: selectedUserUid)
//        let chatRoomIdRefrance = chatInfoReferance.child(chatRoomId)
        let chatRoomIdRefrance = chatInfoReferance.childByAutoId()
        let newChatinfo = ChatInfo(person1_uid: currentUserUid, person2_uid: selectedUserUid, timeStamp: Date().timeIntervalSince1970.description)
        chatRoomIdRefrance.setValue(newChatinfo.toAnyObject())
        self.dismiss(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64+8+8
    }
    
//    func createChatRoomId(index: Int, currentUserUid: String, selectedUserUid: String) -> String {
//
//        let currentUserChar = currentUserUid[currentUserUid.index(currentUserUid.startIndex, offsetBy: index)]
//        let selectedUserChar = selectedUserUid[selectedUserUid.index(selectedUserUid.startIndex, offsetBy: index)]
//
//        if currentUserChar.asciiValue! == selectedUserChar.asciiValue!{
//            return createChatRoomId(index: index + 1, currentUserUid: currentUserUid, selectedUserUid: selectedUserUid)
//        }
//        else if currentUserChar.asciiValue! > selectedUserChar.asciiValue! {
//            return "\(currentUserUid)\(selectedUserUid)"
//        }
//        else{
//            return "\(selectedUserUid)\(currentUserUid)"
//        }
//    }
    
}

extension NewChatViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        return true
    }
    
}
