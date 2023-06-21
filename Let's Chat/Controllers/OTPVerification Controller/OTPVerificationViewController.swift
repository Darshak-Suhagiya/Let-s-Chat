//
//  OTPVerificationViewController.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 27/03/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class OTPVerificationViewController: UIViewController {
    // MARK: outlets

    @IBOutlet weak var stackViewOfOTP: UIStackView!
    @IBOutlet weak var phoneNumberLable: UILabel!
    @IBOutlet weak var editPhoneNumberButton: UIView!
    @IBOutlet weak var resendButton: UILabel!
    @IBOutlet weak var resendTimer: UILabel!
    
    
    
   // MARK: global Variables
    
    var textFields:[UITextField] = []
    var index = 0
    var currentVerificationId = ""
    var phoneNumber = ""
    let backgroundQueue = DispatchQueue.global(qos: .background)
    var timer = Timer()
    var timerCount = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setTimer()
        
        phoneNumberLable.text = phoneNumber
        
        let temporaryViews = stackViewOfOTP.subviews.filter {
            $0 is UITextField
        }
        
        for i in temporaryViews{
            textFields.append(i as! UITextField)
            textFields.last?.delegate = self
        }

        setupKeyboard(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer.invalidate()
    }
    
    @IBAction func authenticateOTP(_ sender: UITextField) {
        if sender.text?.count ?? 0 > 0{
            var otp = ""
            for i in textFields{
                otp += i.text!
            }
            self.verifyOTP(otp: otp)
        }
    }
    
    
    @IBAction func onTapEditNumber(_ sender: Any) {
        let alert = UIAlertController(title: "Alert", message: "are you Sure to change PhoneNumber \n\(phoneNumber)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            
                self.navigationController?.popViewController(animated: true)

        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive))
        self.present(alert, animated: true)
    }
    
    
    @IBAction func onTapResend(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                
                let alert = UIAlertController(title: "Alert!", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            self.setTimer()
        }
    }
    
    
    func verifyOTP(otp: String) {
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: currentVerificationId, verificationCode: otp)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                
                let alert = UIAlertController(title: "Alert!", message: "Invalid OTP", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
                
                print(authError.description)
                return
            }
            
            
            print("User signs in successfully")
            
            let pushManager = PushNotificationManager(userID: Auth.auth().currentUser?.uid ?? "")
            pushManager.registerForPushNotifications()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePageTabBarController") as! HomePageTabBarController
            
            changeWindow(from: self, to: homeVC)
        }

    }
    
    
    
    func setTimer() {
        timerCount = 30
        self.resendButton.isHidden = true
        self.resendTimer.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    func resetTimer() {
        self.timer.invalidate()
        self.resendButton.isHidden = false
        self.resendTimer.isHidden = true
    }
    
    @objc func handleTimer(){
        self.resendTimer.text = "00:\(self.timerCount > 9 ? "\(self.timerCount)" : "0\(self.timerCount)")"
        self.timerCount -= 1
        if timerCount == -1 {
            self.resetTimer()
        }
    }

}

extension OTPVerificationViewController:UITextFieldDelegate{
    
    // Asks the delegate if editing should begin in the specified text field.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        
        //        textFields[index].becomeFirstResponder()
        
        if Int(textField.accessibilityIdentifier ?? "-1") == index{
            return true
        }
        else{
            textFields[index].becomeFirstResponder()
            return false
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the new text that would result from adding the replacement string
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        

        let count = (newText ?? "").count
        
        if count == 1{
            return true
        }
        else if count > 1 {
            if index < 4 {
                index += 1
                let a = (newText?.last)!.description
                textFields[index].text = a
                textFields[index].becomeFirstResponder()
                return true
            }
            else if index == 4{
                index += 1
                let a = (newText?.last)!.description
                textFields[index].text = a
                textField.resignFirstResponder()
                return true
            }
            else {
                textField.resignFirstResponder()
                return false
            }
        }
        else if count == 0 {
            if index > 0 {
                textFields[index].text = newText
                index -= 1
                textFields[index].becomeFirstResponder()
                return false
            }
        }
        return true
    }
    
}
