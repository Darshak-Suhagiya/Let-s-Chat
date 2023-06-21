//
//  SelectedPerosnCollectionViewCell.swift
//  Let-s Chat
//
//  Created by Darshak on 11/04/23.
//

import UIKit

class SelectedPerosnCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var removeButtonImage: UIImageView!
    
    var removePersonFunction:(() -> Void)? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        personImage.layer.cornerRadius = personImage.bounds.width / 2
        removeButtonImage.layer.cornerRadius = removeButtonImage.bounds.width / 2
    }
    
    @IBAction func tapOnRemove(_ sender: Any) {
        
        if let function = self.removePersonFunction{
            function()
        }
        
    }
    
    
}
