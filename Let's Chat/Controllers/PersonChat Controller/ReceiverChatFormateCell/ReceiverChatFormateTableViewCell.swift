//
//  ReceiverChatFormateTableViewCell.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 28/03/23.
//

import UIKit

class ReceiverChatFormateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var mainMessageLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet weak var supportiveViewForAllContent: UIView!
    @IBOutlet weak var whiteBackground: UIView!
    @IBOutlet weak var personProfileInChat: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        supportiveViewForAllContent.round(corners: [.topRight,.topLeft,.bottomRight], radius: 16)
        
        whiteBackground.layer.cornerRadius = 16
        personProfileInChat.layer.cornerRadius = 14
        
        whiteBackground.dropShadow(width: 1, height: 1, shadowOpacity: 0.1, shadowRadius: 2, shadowPathCornerRadius: 16)
        
    }
    
}
