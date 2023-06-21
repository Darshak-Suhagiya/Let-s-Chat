//
//  ChatListTableViewCell.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 27/03/23.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {


    @IBOutlet weak var personName: UILabel!
    
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var pendingMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var personStatus: UIView!
    @IBOutlet weak var pendingMessageLablelView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        personImage.layer.cornerRadius = 16
        personStatus.layer.cornerRadius = 6
        personStatus.layer.borderColor = UIColor.white.cgColor
        personStatus.layer.borderWidth = 2
        pendingMessageLablelView.layer.cornerRadius = pendingMessageLablelView.bounds.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
