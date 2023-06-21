//
//  PhoneNumberSignUpViewController.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 27/03/23.
//

import UIKit
import CountryPickerView
import FirebaseAuth
import FirebaseCore

class PhoneNumberSignUpViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var requestOTPButton: UIButton!
    @IBOutlet weak var countryCodeTextField: UITextField!
    
    let countryPicker = CountryPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        countryPicker.delegate = self
        countryCodeTextField.delegate = self
        
        setupKeyboard(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestOTPButton.tintColor = UIColor(red: 56/255, green: 162/255, blue: 123/255, alpha: 1.0)
    }

    
    @IBAction func onContinue(_ sender: Any) {
        let phoneNumber = "\(countryCodeTextField.text ?? "")\(phoneNumberTextField.text ?? "")"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                
                let alert = UIAlertController(title: "Alert!", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            //            self.currentVerificationId = verificationID!
            
            let otpVC = OTPVerificationViewController(nibName: "OTPVerificationViewController", bundle: nil)
            otpVC.currentVerificationId = verificationID!
            otpVC.phoneNumber = phoneNumber
            self.navigationController?.pushViewController(otpVC, animated: true)
            
            
        }
    }
    
    
    
    @IBAction func onTapSignIn(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}


extension PhoneNumberSignUpViewController:UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.countryPicker.showCountriesList(from: self)
        
        return false
    }
    
}

extension PhoneNumberSignUpViewController:CountryPickerViewDelegate {
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        
        countryCodeTextField.text = country.phoneCode
    }
    
    
}
