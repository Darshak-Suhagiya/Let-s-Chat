//
//  PersonListForNewGroupViewController.swift
//  Let-s Chat
//
//  Created by Darshak on 11/04/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PersonListForNewGroupViewController: UIViewController {
    @IBOutlet weak var collactionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorLoader: UIActivityIndicatorView!
    @IBOutlet weak var supportiveViewForSearchBar: UIView!
    @IBOutlet weak var hightConstraintForCollactionView: NSLayoutConstraint!
    
    
    
    let userReferance = Database.database().reference(withPath: "users")
    var userObservers:[DatabaseHandle] = []
    var users: [UserInfo] = []
    var usersDictionary =  [String:UserInfo]()
    var selectedUser: [String] = []
    let currentUserUid = Auth.auth().currentUser?.uid
    let collactionViewHeight = 76
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Add Person"
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonClicked))
        self.navigationItem.leftBarButtonItem = closeButton
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonClicked))
        self.navigationItem.rightBarButtonItem = nextButton
        
        collactionView.delegate = self
        collactionView.dataSource = self
        collactionView.register(UINib(nibName: "SelectedPerosnCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "selectedPersonCell")
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AllPersonTableViewCell", bundle: nil), forCellReuseIdentifier: "AllPersonCell")
        
        hightConstraintForCollactionView.constant = 0
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        supportiveViewForSearchBar.layer.cornerRadius = supportiveViewForSearchBar.bounds.height / 2
        indicatorLoader.layer.cornerRadius = 12
        
        let userObserver = userReferance.observe(.value){ snapshot in
            
            var tempUsers:[UserInfo] = []
            var tempUsersDictionary = [String:UserInfo]()
            
            let currentUserUid = Auth.auth().currentUser?.uid
            for child in snapshot.children{
                if
                    let snap = child as? DataSnapshot,
                    let user = UserInfo(snapshot: snap){
                    if user.key != currentUserUid {
                        tempUsers.append(user)
                        tempUsersDictionary[user.key] = user
                    }
                }
            }
            self.users = tempUsers
            self.usersDictionary = tempUsersDictionary
            self.indicatorLoader.stopAnimating()
            self.tableView.reloadData()
        }
        self.userObservers.append(userObserver)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        userObservers.forEach(userReferance.removeObserver(withHandle:))
        userObservers = []
    }
    
    func isCollactionViewHidden(_ isHidden: Bool) {
        if isHidden{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [self] in
                hightConstraintForCollactionView.constant = 0
                
                view.layoutIfNeeded()
            })
        }
        else{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: { [self] in
                hightConstraintForCollactionView.constant = CGFloat(collactionViewHeight)
                view.layoutIfNeeded()
            })
        }
    }
    
    @objc func closeButtonClicked() {
        self.dismiss(animated: true)
    }
    @objc func nextButtonClicked() {
        let vc = GroupCreationPageViewController(nibName: "GroupCreationPageViewController", bundle: nil)
        vc.selectedUsers = selectedUser
        vc.users = users
        vc.usersDictionary = usersDictionary
        vc.removePersonViaUid = { arrUser in
            self.selectedUser = arrUser
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.collactionView.reloadData()
                self.isCollactionViewHidden((self.selectedUser.count == 0))
            }
        }
//        vc.removePersonViaUid = { key in
//            self.selectedUser.remove(at: key)
//            self.tableView.reloadData()
//            self.collactionView.reloadData()
//            if self.selectedUser.count == 0{
//                self.isCollactionViewHidden(true)
//            }
//
//        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension PersonListForNewGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedPersonCell", for: indexPath) as! SelectedPerosnCollectionViewCell
        let personImageUrl = usersDictionary[selectedUser[indexPath.row]]?.imageUrl ?? ""
        
        cell.personImage.sd_setImage(with: URL(string: personImageUrl), placeholderImage: UIImage(named: "Avatar"), completed: {_,_,_,_ in
            cell.contentView.layoutIfNeeded()
        })
        
        cell.contentView.layoutIfNeeded()
        
        
        cell.removePersonFunction = {
            self.selectedUser.remove(at: indexPath.row)
            self.tableView.reloadData()
            self.collactionView.reloadData()
            if self.selectedUser.count == 0{
                self.isCollactionViewHidden(true)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return (CGSize(width: collactionViewHeight, height: collactionViewHeight))
    }
    
}


extension PersonListForNewGroupViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllPersonCell", for: indexPath) as! AllPersonTableViewCell
        let user = users[indexPath.row]
        cell.nameLable.text = user.fullname()
        cell.userProfileImage.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: UIImage(named: "Avatar"), completed: {_,_,_,_ in
        })
        if !selectedUser.contains(user.key){
            cell.isSelectedImage.image = UIImage(systemName: "circle")
        }
        else{
            cell.isSelectedImage.image = UIImage(systemName: "checkmark.circle.fill")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64 + 8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let index = selectedUser.firstIndex(of: users[indexPath.row].key)
        else {
            selectedUser.append(users[indexPath.row].key)
            
            if self.hightConstraintForCollactionView.constant == 0 {
                isCollactionViewHidden(false)
            }
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.deselectRow(at: indexPath, animated: true)
            collactionView.reloadData()
            return
        }
        selectedUser.remove(at: index)
        
        if selectedUser.count == 0{
            isCollactionViewHidden(true)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
        collactionView.reloadData()
    }
    
}
