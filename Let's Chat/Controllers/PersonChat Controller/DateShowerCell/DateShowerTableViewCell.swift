//
//  DateShowerTableViewCell.swift
//  Let-s Chat
//
//  Created by Darshak on 05/04/23.
//

import UIKit

class DateShowerTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var supportiveView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        supportiveView.layer.cornerRadius = supportiveView.bounds.height / 2
        supportiveView.dropShadow(width: 1, height: 1, shadowOpacity: 0.1, shadowRadius: 2, shadowPathCornerRadius: 16)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
