//
//  SenderChatFormateTableViewCell.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 28/03/23.
//

import UIKit

class SenderChatFormateTableViewCell: UITableViewCell {

    @IBOutlet weak var mainMessageLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var isRead: UILabel!
    @IBOutlet weak var isReadImage: UIImageView!
    @IBOutlet weak var supportiveViewForAllContent: UIView!
    
    @IBOutlet weak var whiteBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        supportiveViewForAllContent.round(corners: [.topRight,.topLeft,.bottomLeft], radius: 16)
        whiteBackground.layer.cornerRadius = 16
        whiteBackground.dropShadow(width: -1, height: 1, shadowOpacity: 0.1, shadowRadius: 2, shadowPathCornerRadius: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
