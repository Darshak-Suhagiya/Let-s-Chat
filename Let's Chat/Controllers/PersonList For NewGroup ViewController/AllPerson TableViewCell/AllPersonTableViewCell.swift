//
//  AllPersonTableViewCell.swift
//  Let-s Chat
//
//  Created by Darshak on 11/04/23.
//

import UIKit

class AllPersonTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var isSelectedImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileImage.layer.cornerRadius = 16
    }
    
}
