//
//  ViewController.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 23/03/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var passwordHideShowImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //        navigationController?.isNavigationBarHidden = true
        
        setupKeyboard(self)
        //
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signInButton.tintColor = UIColor(red: 56/255, green: 162/255, blue: 123/255, alpha: 1.0)
    }
    
    
    @IBAction func tapOnPasswordHideShowImage(_ sender: Any) {
        if passwordTextField.isSecureTextEntry{
            passwordTextField.isSecureTextEntry = false
            passwordHideShowImage.image = UIImage(systemName: "eye.slash")
        }else{
            passwordTextField.isSecureTextEntry = true
            passwordHideShowImage.image = UIImage(systemName: "eye")
        }
    }
    
    @IBAction func onSignin(_ sender: UIButton) {
        
        showLoader(self)
        
        Auth.auth().signIn(withEmail: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "") { authResult, error in
            //          guard let strongSelf = self else { return }
            
            if let error = error as? NSError {
                switch AuthErrorCode(AuthErrorCode.Code(rawValue: error.code)!) {
                case AuthErrorCode.operationNotAllowed:
                    // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                    alertTheUser(self,string: "For Now you can not Sign in")
                    
                case AuthErrorCode.userDisabled:
                    // Error: The user account has been disabled by an administrator.
                    alertTheUser(self,string: "You have been Blocked")
                    
                case AuthErrorCode.wrongPassword:
                    // Error: The password is invalid or the user does not have a password.
                    alertTheUser(self,string: "Wrong Password")
                    
                case AuthErrorCode.invalidEmail:
                    // Error: Indicates the email address is malformed.
                    alertTheUser(self,string: "Invalid Email")
                    
                default:
                    print("Error: \(error.localizedDescription)")
                    alertTheUser(self,string: "Error: \(error.localizedDescription)")
                }
                
            } else {
                print("User signs in successfully")
                let userInfo = Auth.auth().currentUser
                if userInfo != nil {
                    
                    let pushManager = PushNotificationManager(userID: Auth.auth().currentUser?.uid ?? "")
                    pushManager.registerForPushNotifications()
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomePageTabBarController") as! HomePageTabBarController
                    
                    changeWindow(from: self, to: vc)
                }
                
            }
            
        }
        
    }
    
    
    @IBAction func TapOnRegister(_ sender: Any) {
        let vc = SignUpUserInfoViewController(nibName: "SignUpUserInfoViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func TapOnPhoneImage(_ sender: Any) {
        let vc = PhoneNumberSignUpViewController(nibName: "PhoneNumberSignUpViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

