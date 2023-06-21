//
//  SelectedPersonsCollectionViewTableViewCell.swift
//  Let-s Chat
//
//  Created by Darshak on 12/04/23.
//

import UIKit

class SelectedPersonsCollectionViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    //    @IBOutlet weak var heightConstraintForCollectionView: NSLayoutConstraint!
    
    var deviceWidth:CGFloat = 0.0
    var newWidth:CGFloat = 0.0
    var count = 12
    var selectedUsers = [String]()
    var users = [UserInfo]()
    var usersDictionary = [String:UserInfo]()
    var removePersonViaUid:((_ arrUser: [String]) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SelectedPerosnCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "selectedPersonCell")
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deviceWidth = UIScreen.main.bounds.width
        newWidth = (deviceWidth / 5)
        //        let totalRowInCollactionView = ceilf(Float(count) / 5.0)
        //        let newHeight = (newWidth + 8 + 10) * CGFloat(totalRowInCollactionView)
        
        //        heightConstraintForCollectionView.constant = newHeight + 16
    }
    
    
}

extension SelectedPersonsCollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "selectedPersonCell", for: indexPath) as! SelectedPerosnCollectionViewCell
        let personImageUrl = usersDictionary[selectedUsers[indexPath.row]]?.imageUrl ?? ""
        
        cell.personImage.sd_setImage(with: URL(string: personImageUrl), placeholderImage: UIImage(named: "Avatar"), completed: {_,_,_,_ in
            cell.contentView.layoutIfNeeded()
        })
        
        cell.contentView.layoutIfNeeded()
        
        
        cell.removePersonFunction = {
            self.selectedUsers.remove(at: indexPath.row)
            if let funcn = self.removePersonViaUid{
//                funcn(indexPath.row)
                funcn(self.selectedUsers)
            }
            self.collectionView.reloadData()
        }
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return (CGSize(width: newWidth, height: newWidth))
    }
    
}
