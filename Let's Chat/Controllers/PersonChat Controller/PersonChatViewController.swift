//
//  PersonChatViewController.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 27/03/23.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import IQKeyboardManagerSwift

class PersonChatViewController: UIViewController {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var onlineStatusOfProfile: UIView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var supportiveViewForTextField: UIView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var microphoneIcon: UIImageView!
    @IBOutlet weak var sendIcon: UIImageView!
    @IBOutlet weak var chatTextField: UITextField!

    @IBOutlet weak var textFieldBottamConstraint: NSLayoutConstraint!
    
    var currentUserUid = ""
    var otherUser = UserInfo()
    var chatId = ""
    let timeFormater = DateFormatter()
    let dateFormater = DateFormatter()
    
    var messagesRefarance = Database.database().reference(withPath: "Messages")
    var messagesObservers:[DatabaseHandle] = []
    
    var isTypingRefarance = Database.database().reference(withPath: "Typing")
    var isTypingObservers:[DatabaseHandle] = []
    
    let onlineReferance = Database.database().reference(withPath: "Online")
    var onlineObservers:[DatabaseHandle] = []
    
    var currentUserTypingRefarance = Database.database().reference(withPath: "Typing")
    
    var messages:[Message] = []
    var onlineUsers:[String] = []
    var otherPersonTypingStatus = ""
    var currentUserTypingStatus = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        messagesRefarance = Database.database().reference(withPath: "Messages").child(chatId)
        isTypingRefarance = Database.database().reference(withPath: "Typing").child(currentUserUid).child(otherUser.key)
        currentUserTypingRefarance = Database.database().reference(withPath: "Typing").child(otherUser.key).child(currentUserUid)
        
        timeFormater.locale = Locale(identifier: "en_Us")
        timeFormater.timeStyle = .short
        dateFormater.dateFormat = "d MMMM yyyy"
        
        profileImage.sd_setImage(with: URL(string: otherUser.imageUrl), placeholderImage: UIImage(named: "Avatar"))
        personName.text = otherUser.fullname()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setupKeyboard(self)
        
        chatTextField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SenderChatFormateTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderCell")
        tableView.register(UINib(nibName: "ReceiverChatFormateTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverCell")
        tableView.register(UINib(nibName: "DateShowerTableViewCell", bundle: nil), forCellReuseIdentifier: "DateCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        supportiveViewForTextField.layer.cornerRadius = supportiveViewForTextField.bounds.height / 2
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        onlineStatusOfProfile.layer.cornerRadius = onlineStatusOfProfile.bounds.height / 2
        onlineStatusOfProfile.layer.borderColor = UIColor.white.cgColor
        onlineStatusOfProfile.layer.borderWidth = 2
        
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        
        
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
        self.messagesObservers.append(messagesObserver)
        
        
        let typingObserver = isTypingRefarance.observe(.value){ snapshot in
            if let value = snapshot.value as? [String:String]{
                self.otherPersonTypingStatus = value["isTyping"]!
            }
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.statusLabel.text = self.otherPersonTypingStatus
                self.view.layoutIfNeeded()
            })
        }
        self.isTypingObservers.append(typingObserver)
        
        
        let onlineObserver = onlineReferance.observe(.value){ snapshot in
            
            var isOnline = false
            
            for child in snapshot.children{
                if let snap = child as? DataSnapshot{
                    if snap.key == self.otherUser.key{
                        isOnline = true
                        break
                    }
                }
            }
            self.onlineStatusOfProfile.isHidden = !isOnline
        }
        self.onlineObservers.append(onlineObserver)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        if self.messages.count > 0
        {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        messagesObservers.forEach(messagesRefarance.removeObserver(withHandle:))
        messagesObservers = []
        
        isTypingObservers.forEach(isTypingRefarance.removeObserver(withHandle:))
        isTypingObservers = []
        
        onlineObservers.forEach(onlineReferance.removeObserver(withHandle:))
        onlineObservers = []
        
        setStatusTypingString(typingString: "")
        
    }
    
    @IBAction func dghdfhdfgh(_ sender: Any) {
        
    }
    

    @IBAction func onBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func onTapVideoCallButton(_ sender: Any) {
        let vc = VideoCallViewController(nibName: "VideoCallViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func onTouchUpSend(_ sender: Any) {
        let refaranceForNewMessage = messagesRefarance.childByAutoId()
        refaranceForNewMessage.setValue(Message(senderUid: currentUserUid, msg: chatTextField.text ?? "", timeStamp: Date().timeIntervalSince1970.description).toAnyObjectForChatMessage())
        hideSendButton()
        chatTextField.text = ""
        setStatusTypingString(typingString: "")
    }
    
    func setStatusTypingString(typingString:String) {
        if currentUserTypingStatus != typingString{
            currentUserTypingRefarance.setValue(["isTyping":typingString])
            currentUserTypingStatus = typingString
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let safeArea = view.window?.safeAreaInsets.bottom ?? 0.0
            // Do something with keyboard height, such as adjusting the constraints of views
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.textFieldBottamConstraint.constant = keyboardHeight - safeArea
                self.view.layoutIfNeeded()
            })
            
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            
            if chatTextField.text != "" {
                setStatusTypingString(typingString: "Typing")
            }
        }
    }

    // Method called when keyboard will hide
    @objc func keyboardWillHide(notification: NSNotification) {
        // Do something when keyboard will hide, such as resetting the constraints of views
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction,.transitionCurlDown], animations: {
            self.textFieldBottamConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
        setStatusTypingString(typingString: "")
    }

    
}

extension PersonChatViewController:UITableViewDelegate, UITableViewDataSource {
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
            cell.mainMessageLable.text = message.msg
            cell.timeLable.text = message.getTime()
            cell.personProfileInChat.sd_setImage(with: URL(string: otherUser.imageUrl), placeholderImage: UIImage(named: "Avatar"))
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


extension PersonChatViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if newText?.trimmingCharacters(in: .whitespaces) == ""{
            hideSendButton()
        }
        else if sendIcon.isHidden{
            showSendButton()
        }
        return true
    }
    
    func hideSendButton() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.cameraIcon.isHidden = false
            self.microphoneIcon.isHidden = false
            self.sendIcon.isHidden = true
                  self.view.layoutIfNeeded()
                })
        setStatusTypingString(typingString: "")
        
    }
    func showSendButton() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            self.cameraIcon.isHidden = true
            self.microphoneIcon.isHidden = true
            self.sendIcon.isHidden = false
                  self.view.layoutIfNeeded()
                })
        setStatusTypingString(typingString: "Typing")
    }
}


