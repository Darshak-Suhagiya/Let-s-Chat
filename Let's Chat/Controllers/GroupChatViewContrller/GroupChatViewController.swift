//
//  GroupChatViewController.swift
//  Let-s Chat
//
//  Created by Darshak on 17/04/23.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import IQKeyboardManagerSwift

class GroupChatViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var supportiveViewForTopBar: UIView!
    
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    
    @IBOutlet weak var supportiveViewForTextField: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var textFieldBottamConstraint: NSLayoutConstraint!
    @IBOutlet weak var minimumHeightForTextField: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var microphoneIcon: UIImageView!
    @IBOutlet weak var sendIcon: UIImageView!
    
    private var isOversized = false
    private let maxHeight: CGFloat = 116
    
    var messagesRefarance = Database.database().reference(withPath: "groups").child("Messages")
    let userReferance = Database.database().reference(withPath: "users")
    
    var currentGroupInfo:GroupInfo? = nil
    var currentUserUid = ""
    var messages:[Message] = []
    var users: [String:UserInfo] = [:]
    
    let timeFormater = DateFormatter()
    let dateFormater = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self

        messagesRefarance = Database.database().reference(withPath: "groups").child("Messages").child(currentGroupInfo?.key ?? "default")
        
        timeFormater.locale = Locale(identifier: "en_Us")
        timeFormater.timeStyle = .short
        dateFormater.dateFormat = "d MMMM yyyy"
        
        profileImage.sd_setImage(with: URL(string: currentGroupInfo?.imageURL ?? ""), placeholderImage: UIImage(named: "Avatar"))
        personName.text = currentGroupInfo?.groupName ?? ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupKeyboard(self)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SenderChatFormateTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
        tableView.register(UINib(nibName: "ReceiverChatFormateTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverCell")
        tableView.register(UINib(nibName: "DateShowerTableViewCell", bundle: nil), forCellReuseIdentifier: "DateCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        
        supportiveViewForTextField.layer.cornerRadius = 33/2
        supportiveViewForTextField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        mainView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        mainView.layer.borderWidth = 1
        supportiveViewForTopBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        supportiveViewForTopBar.layer.borderWidth = 1
        supportiveViewForTextField.layer.borderWidth = 1
        
        
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        let userObserver = userReferance.observe(.value){ snapshot in
            
            var tempUsers:[String:UserInfo] = [:]

            for child in snapshot.children{
                if
                    let snap = child as? DataSnapshot,
                    let user = UserInfo(snapshot: snap){
                    if user.key != self.currentUserUid{
                        tempUsers[user.key] = user
                    }
                }
            }
            print("---------------user_added----------------")
            self.users = tempUsers
        }
        
        let messagesObserver = messagesRefarance
            .queryOrdered(byChild: "timeStamp")
            .observe(.value){ snapshot in
                print("------------message_Loaded-------------")
                var tempMessages:[Message] = []
                var previousDate = ""
                for child in snapshot.children{
                    
                    if let snap = child as? DataSnapshot,
                       let message = Message(snapshot: snap){
                        if tempMessages.count == 0 {
                            tempMessages.append(message.setDateChange())
                            tempMessages.append(message)
                            if let timeInterval = TimeInterval(message.timeStamp){
                                previousDate = self.dateFormater.string(from: Date(timeIntervalSince1970: timeInterval))
                            }
                        }
                        else{
                            if let timeInterval = TimeInterval(message.timeStamp){
                                let date = self.dateFormater.string(from: Date(timeIntervalSince1970: timeInterval))
                                if date != previousDate{
                                    tempMessages.append(message.setDateChange())
                                }
                                previousDate = date
                                tempMessages.append(message)
                            }
                        }
                    }
                }
                if tempMessages.count == 0{
                    let message = Message()
                    tempMessages.append(message.setDateChange())
                }
                self.messages = tempMessages
                self.tableView.reloadData()
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        if self.messages.count > 0
        {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        messagesRefarance.removeAllObservers()
        userReferance.removeAllObservers()
    }
    
    @IBAction func tapOnSend(_ sender: Any) {
        let refaranceForNewMessage = messagesRefarance.childByAutoId()
        refaranceForNewMessage.setValue(Message(senderUid: currentUserUid, msg: textView.text.trimmingCharacters(in: .whitespacesAndNewlines) , timeStamp: Date().timeIntervalSince1970.description).toAnyObjectForChatMessage())
        hideSendButton()
        textView.text = ""
        textView.isScrollEnabled = false
        textView.setNeedsUpdateConstraints()
        minimumHeightForTextField.constant = 33
    }
    


    @IBAction func tapOnBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapOnProfileDetail(_ sender: Any) {
        
        let vc = GroupInfoViewController(nibName: "GroupInfoViewController", bundle: nil)
        vc.currentGroupInfo = currentGroupInfo
        vc.currentUserUid = currentUserUid
        vc.personsPerGroupRef = Database.database().reference(withPath: "groups")
            .child("personsPerGroup")
            .child(currentGroupInfo?.key ?? "")
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let safeArea = view.window?.safeAreaInsets.bottom ?? 0.0

            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.textFieldBottamConstraint.constant = keyboardHeight - safeArea

                self.view.layoutIfNeeded()
            })

        }
    }

    // Method called when keyboard will hide
    @objc func keyboardWillHide(notification: NSNotification) {

        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction,.transitionCurlDown], animations: {
            self.textFieldBottamConstraint.constant = 0

            self.view.layoutIfNeeded()
        })

    }
    
    func calculateHeightOfTextView() -> CGFloat {
        let tempTextView = UITextView(frame: CGRect(x: 0, y: 0, width: textView.bounds.width, height: 0))
        tempTextView.isScrollEnabled = false
        tempTextView.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tempTextView.textAlignment = .natural
        tempTextView.text = textView.text
        tempTextView.sizeToFit()
        print("-------------temp - \(tempTextView.bounds.height) -----------")
        return tempTextView.bounds.height
    }
    
    func hideSendButton() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.cameraIcon.isHidden = false
            self.microphoneIcon.isHidden = false
            self.sendIcon.isHidden = true
                  self.view.layoutIfNeeded()
                })
//        setStatusTypingString(typingString: "")
        
    }
    func showSendButton() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.cameraIcon.isHidden = true
            self.microphoneIcon.isHidden = true
            self.sendIcon.isHidden = false
                  self.view.layoutIfNeeded()
                })
//        setStatusTypingString(typingString: "Typing")
    }

}

extension GroupChatViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        
        var flag = false
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            if !sendIcon.isHidden{
                hideSendButton()
                flag = true
            }
        }
        else if sendIcon.isHidden{
            showSendButton()
            flag = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (flag ? 0.1 : 0)){ [self] in
            if isOversized != (calculateHeightOfTextView() > maxHeight) {
                isOversized = !isOversized
                if isOversized{
                    minimumHeightForTextField.constant = maxHeight
                    textView.isScrollEnabled = true
                    textView.setNeedsUpdateConstraints()
                }
                else{
                    textView.isScrollEnabled = false
                    textView.setNeedsUpdateConstraints()
                    minimumHeightForTextField.constant = 33
                }
                
            }
        }
    }
}


extension GroupChatViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.isDateChange{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell") as! DateShowerTableViewCell
            
            cell.dateLable.text = message.getDate()
            cell.contentView.layoutIfNeeded()
            
            return cell
        } else if message.senderUid == currentUserUid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell") as! SenderChatFormateTableViewCell
            cell.mainMessageLable.text = message.msg
            cell.timeLable.text = message.getTime()
            
            cell.isReadImage.tintColor = message.isReaded == true ? .link : .lightGray

            
            cell.contentView.layoutIfNeeded()
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell") as! ReceiverChatFormateTableViewCell
            let sender = users[message.senderUid]
            cell.mainMessageLable.text = message.msg
            cell.timeLable.text = message.getTime()
            cell.personProfileInChat.sd_setImage(with: URL(string: sender?.imageUrl ?? ""), placeholderImage: UIImage(named: "Avatar"))
            cell.senderName.isHidden = false
            cell.senderName.text = sender?.fullname()
            cell.contentView.layoutIfNeeded()
            
            if !message.isReaded {
                setMeaasgeAsReaded(message: message)
            }
            
            return cell
        }
    }
    
    func setMeaasgeAsReaded(message:Message) {
        let isReadedMessageRef = message.ref?.child("isReaded")
        isReadedMessageRef?.setValue(true)
    }
}
