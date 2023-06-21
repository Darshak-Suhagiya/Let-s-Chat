//
//  PersonTableViewCell.swift
//  Let-s Chat
//
//  Created by Darshak on 20/04/23.
//

import UIKit

class PersonTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var supportiveViewForAddIcon: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var moreButton: UIImageView!
    @IBOutlet weak var stackViewLeadingConstrint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        supportiveViewForAddIcon.layer.cornerRadius = supportiveViewForAddIcon.bounds.height / 2
    }
}
