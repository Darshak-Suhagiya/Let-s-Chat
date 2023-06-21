//
//  GroupCreationPageViewController.swift
//  Let-s Chat
//
//  Created by Darshak on 12/04/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class GroupCreationPageViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var newHeight:CGFloat = 0.0
    //    var newWidth:CGFloat = 0.0
    var selectedUsers = [String]()
    var users = [UserInfo]()
    var usersDictionary = [String:UserInfo]()
    var removePersonViaUid:((_ arrUser: [String]) -> Void)? = nil
    
    let imagePicker = UIImagePickerController()
    let currentUserUid = Auth.auth().currentUser?.uid ?? ""
    var profileImage: UIImage?
    var textFieldText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GroupDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupDetailCell")
        tableView.register(UINib(nibName: "SelectedPersonsCollectionViewTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectedPersonsCell")
        tableView.register(UINib(nibName: "HeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        tableView.separatorStyle = .none
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = view
        
        self.title = "Create Group"
        let createButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createGroup))
        createButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = createButton
        
        
        let deviceWidth = UIScreen.main.bounds.width
        //view.bounds.width
        
        let newWidth = (deviceWidth / 5)
        let totalRowInCollactionView = ceilf(Float(selectedUsers.count) / 5.0)
        let height = newWidth
        newHeight = (height) * CGFloat(totalRowInCollactionView)
        print("-----------------newHeight = \(newHeight)")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicatorView.layer.cornerRadius = 16
    }
    
    func setUpCreatedGroup( groupKey:String ) {
        let personsPerGroupRef = Database.database().reference(withPath: "groups").child("personsPerGroup").child(groupKey)
        
        let groupsPerPersonRef = Database.database().reference(withPath: "groups").child("groupsPerPerson")
        
        // add Admin means CurrenUser
        let admin = GroupUser(uid: currentUserUid, isAdmin: true)
        let personXRef = personsPerGroupRef.childByAutoId()
        personXRef.setValue(admin.toAnyObject())
        
        let personRefAtgroupsPerPerson = groupsPerPersonRef.child(currentUserUid).childByAutoId()
        personRefAtgroupsPerPerson.setValue(groupKey)
        
        for userX in selectedUsers{
            
            // set data at personsPerGroup
            let groupUser = GroupUser(uid: userX)
            let personXRef = personsPerGroupRef.childByAutoId()
            personXRef.setValue(groupUser.toAnyObject())
            
            // set data at groupsPerPerson
            let personRefAtgroupsPerPerson = groupsPerPersonRef.child(userX).childByAutoId()
            personRefAtgroupsPerPerson.setValue(groupKey)
            
        }
        
        indicatorView.stopAnimating()
        self.dismiss(animated: true)
    }
    
    func showAlert(str: String) {
        let alert = UIAlertController(title: "Alert!", message: str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkCreateButtonShouldBeEnableed() {
        if textFieldText.trimmingCharacters(in: .whitespaces).count == 0 || selectedUsers.count == 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        else{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    @objc func createGroup () {

        indicatorView.startAnimating()
        
        let groupInfoRef = Database.database().reference(withPath: "groups").child("groupInfo")
        let groupRef = groupInfoRef.childByAutoId()
        guard let groupKey = groupRef.key else{
            self.showAlert(str: "Unknown Error")
            return
        }
        
        if let profile = profileImage {

            let imageRef = Storage.storage().reference().child("groupProfileImages").child(groupKey)
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"

            uploadImage(profile, at: imageRef, metadata: metadata, completion: { (downloadURL) in
                guard let downloadURL = downloadURL else {
                    self.showAlert(str: "Error in Image Upload")
                    return
                }
                let urlString = downloadURL.absoluteString
                print("image url: \(urlString)")
                let group = GroupInfo(groupName: self.textFieldText, imageURL: urlString, timeStamp: Date().timeIntervalSince1970.description, adminUid: self.currentUserUid)
                groupRef.setValue(group.toAnyObject())
                self.setUpCreatedGroup(groupKey: groupKey)
            })
        }
        else{
            let group = GroupInfo(groupName: textFieldText, imageURL: "", timeStamp: Date().timeIntervalSince1970.description, adminUid: currentUserUid)
            groupRef.setValue(group.toAnyObject())
            self.setUpCreatedGroup(groupKey: groupKey)
        }
    }
    

}

extension GroupCreationPageViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        else{
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as? HeaderView else { return nil }
            header.stringforHeader.text = "Total Participants : \(selectedUsers.count)"
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupDetailCell", for: indexPath) as! GroupDetailTableViewCell
            cell.imageSetter = {
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            if let profileImage = profileImage{
                cell.profileImageView.image = profileImage
            }
            cell.groupSubjectTextField.text = textFieldText
            cell.textSetter = { text in
                self.textFieldText = text
                self.checkCreateButtonShouldBeEnableed()
            }
            cell.contentView.layoutIfNeeded()
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedPersonsCell", for: indexPath) as! SelectedPersonsCollectionViewTableViewCell
            cell.selectedUsers = selectedUsers
            cell.users = users
            cell.usersDictionary = usersDictionary
            
            cell.removePersonViaUid = { arrUser in
                self.selectedUsers = arrUser
                self.checkCreateButtonShouldBeEnableed()
                if let funcn = self.removePersonViaUid{
                    funcn(arrUser)
                }
                DispatchQueue.main.async {
                    self.checkCreateButtonShouldBeEnableed()
                    self.tableView.reloadData()

                }
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 36
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 48 + 8 + 8
        }
        return newHeight
    }
}

extension GroupCreationPageViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImage = editedImage
        }
        else if let orignalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImage = orignalImage
        }
        tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
        picker.dismiss(animated: true)
    }
}
