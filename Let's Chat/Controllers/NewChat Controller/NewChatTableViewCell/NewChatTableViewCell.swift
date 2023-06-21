//
//  NewChatTableViewCell.swift
//  Let-s Chat
//
//  Created by DUIUX-01 on 31/03/23.
//

import UIKit

class NewChatTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileImage.layer.cornerRadius = 16
    }


    
}
