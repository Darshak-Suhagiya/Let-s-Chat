//
//  GroupInfoViewController.swift
//  Let-s Chat
//
//  Created by Darshak on 19/04/23.
//

import UIKit
import FirebaseDatabase

class GroupInfoViewController: UIViewController {
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var numberOfParticipatesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var endingStackView: UIStackView!
    
    var personsPerGroupRef = DatabaseReference()
    let userReferance = Database.database().reference(withPath: "users")
    
    var currentGroupInfo:GroupInfo? = nil
    var currentUserUid = ""
    private var users: [String:UserInfo] = [:]
    private var groupPrsons:[GroupUser] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PersonTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonCell")
        
        self.title = "Group info"
        let createButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editGroup))
        self.navigationItem.rightBarButtonItem = createButton
        
        groupImageView.sd_setImage(with: URL(string: currentGroupInfo?.imageURL ?? ""), placeholderImage: UIImage(named: "GroupPlaceholder"))
        groupName.text = currentGroupInfo?.groupName
        
        
        navigationController?.isNavigationBarHidden = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        groupImageView.layer.cornerRadius = groupImageView.bounds.height / 2
        tableView.layer.cornerRadius = 12
        endingStackView.layer.cornerRadius = 12
        tableViewHightConstraint.constant = ((48 + 12 + 13) * 8) - 1
        
        let userObserver = userReferance.observe(.value){ snapshot in
            
            var tempUsers:[String:UserInfo] = [:]
            
            for child in snapshot.children{
                if
                    let snap = child as? DataSnapshot,
                    let user = UserInfo(snapshot: snap){
//                    if user.key != self.currentUserUid{
                        tempUsers[user.key] = user
//                    }
                }
            }
            print("---------------user_added----------------")
            self.users = tempUsers
            self.tableView.reloadData()
        }
        
        let groupPrsonsObserver = personsPerGroupRef.observe(.value){ snapshot in

            var tempGroupPrsons:[GroupUser] = []

            for child in snapshot.children{
                if
                    let snap = child as? DataSnapshot,
                    let groupUser = GroupUser(snapshot: snap){
                    if groupUser.key == self.currentUserUid{
                        tempGroupPrsons.insert(groupUser, at: 0)
                    }
                    else{
                        tempGroupPrsons.append(groupUser)
                    }
                }
            }
            print("---------------groupUsers_added----------------")
            self.groupPrsons = tempGroupPrsons
            self.tableView.reloadData()
        }
        
        let currentGroupInfoObserver = currentGroupInfo?.ref?.observe(.value, with: { snapshot in

            if let snap = snapshot.value as? DataSnapshot,
               let group = GroupInfo(snapshot: snap){
                self.groupImageView.sd_setImage(with: URL(string: group.imageURL), placeholderImage: UIImage(named: "GroupPlaceholder"))
                self.groupName.text = group.groupName
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = true
        userReferance.removeAllObservers()
        personsPerGroupRef.removeAllObservers()
        currentGroupInfo?.ref?.removeAllObservers()
        
    }
    
    @objc func editGroup() {
        
    }
    
}

extension GroupInfoViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupPrsons.count > 7 ? 9 : groupPrsons.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonTableViewCell
        
        switch indexPath.row{
        case 0:
            cell.profileImage.isHidden = true
            cell.supportiveViewForAddIcon.isHidden = false
            cell.mainTitle.text = "Add Participants"
            cell.subTitle.isHidden = true
            cell.adminLabel.isHidden = true
            cell.moreButton.isHidden = true
//        case 1:
//            cell.profileImage.isHidden = true
//            cell.supportiveViewForAddIcon.isHidden = false
//            cell.mainTitle.text = "Add Participants"
//            cell.subTitle.isHidden = true
//            cell.adminLabel.isHidden = true
//            cell.moreButton.isHidden = true
        case 8:
            cell.profileImage.isHidden = true
            cell.mainTitle.text = "See more"
            cell.subTitle.isHidden = true
            cell.adminLabel.isHidden = true
            cell.stackViewLeadingConstrint.constant = -48
        default:
            let groupPerson = groupPrsons[indexPath.row - 1]
            let groupPesonDetail = users[groupPerson.uid]
            cell.adminLabel.isHidden = !groupPerson.isAdmin
            cell.mainTitle.text = groupPesonDetail?.fullname()
            cell.subTitle.text = groupPesonDetail?.email
            cell.profileImage.sd_setImage(with: URL(string: groupPesonDetail?.imageUrl ?? ""), placeholderImage: UIImage(named: "Avatar"))
        }
        
        cell.contentView.layoutIfNeeded()
        cell.contentView.updateConstraints()
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48 + 12 + 13
    }
    
    
}
