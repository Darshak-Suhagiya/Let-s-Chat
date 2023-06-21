//
//  GroupDetailTableViewCell.swift
//  Let-s Chat
//
//  Created by Darshak on 12/04/23.
//

import UIKit

class GroupDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var supportiveViewForProfileImage: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imageSetter: (() -> Void)? = nil
    var textSetter: ((_ text: String) -> Void)? = nil
    @IBOutlet weak var groupSubjectTextField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        groupSubjectTextField.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        supportiveViewForProfileImage.layer.cornerRadius = supportiveViewForProfileImage.bounds.width / 2
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onTapImage(_ sender: Any) {
        if let imageSetter = imageSetter{
            imageSetter()
        }
    }
}

extension GroupDetailTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if let textSetter = textSetter{
            textSetter(newText ?? "")
        }
        
        return true
    }
    
    
    
}
