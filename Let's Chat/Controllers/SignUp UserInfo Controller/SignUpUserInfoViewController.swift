//
//  SignUpUserInfoViewController.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 27/03/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseStorage
import FirebaseDatabase

class SignUpUserInfoViewController: UIViewController {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var isPasswordShowImage: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupKeyboard(self)
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signUpButton.tintColor = UIColor(red: 56/255, green: 162/255, blue: 123/255, alpha: 1.0)
        
    }
    
    @IBAction func onTapProfileImage(_ sender: Any) {
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func onTapisPasswordHidden(_ sender: Any) {
        if passwordTextField.isSecureTextEntry{
            passwordTextField.isSecureTextEntry = false
            isPasswordShowImage.image = UIImage(systemName: "eye.slash")
        }else{
            passwordTextField.isSecureTextEntry = true
            isPasswordShowImage.image = UIImage(systemName: "eye")
        }
    }
    
    
    
    @IBAction func onTapSignUP(_ sender: Any) {
        
        
        showLoader(self)
        let email = emailTextField.text
        let password = passwordTextField.text
        switch 1 {
        case 1:
            if(checkData(code: 1, data: firstNameTextField.text ?? "")){
                fallthrough
            }else{
                alertTheUser(self, string: "Invalid FirstName")
            }
        case 2:
            if(checkData(code: 2, data: lastNameTextField.text ?? "")){
                fallthrough
            }else{
                alertTheUser(self, string: "Invalid LastName")
            }
        case 3:
            if(self.checkData(code: 3, data: email ?? "")){
                fallthrough
            }else{
                alertTheUser(self, string: "Invalid Email")
            }
        case 4:
            if profileImage.alpha == 1.0 {
                fallthrough
            }else{
                alertTheUser(self, string: "Please select profile picture")
            }
        default:
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
                if let error = error as? NSError {
                    switch AuthErrorCode(AuthErrorCode.Code(rawValue: error.code)!) {
                    case AuthErrorCode.operationNotAllowed:
                        // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
                        alertTheUser(self, string: "For Now you can not Sign up")
                        
                    case AuthErrorCode.emailAlreadyInUse:
                        // Error: The email address is already in use by another account.
                        alertTheUser(self, string: "Email is alredy in use")
                        
                    case AuthErrorCode.invalidEmail:
                        // Error: The email address is badly formatted.
                        alertTheUser(self, string: "Invalid Email")
                        
                    case AuthErrorCode.weakPassword:
                        // Error: The password must be 6 characters long or more.
                        alertTheUser(self, string: "Use Strong password")
                        
                    default:
                        print("Error: \(error.localizedDescription)")
                        alertTheUser(self, string: "Error: \(error.localizedDescription)")
                    }
                } else {
                    print("User signs up successfully")
                    
                    self.userCreated()
                    
                    
                }
            }
        }
    }
    
    @IBAction func onTapGoogleSignUp(_ sender: Any) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        showLoader(self)
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            
            guard error == nil else {
                // ...
                alertTheUser(self,string: error!.localizedDescription)
                
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                // ...
                alertTheUser(self,string: error!.localizedDescription)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                
                if let error = error as? NSError {
                    switch AuthErrorCode(AuthErrorCode.Code(rawValue: error.code)!) {
                    case AuthErrorCode.operationNotAllowed:
                        // Error: Indicates that email and password accounts are not enabled. Enable them in the Auth section of the Firebase console.
                        alertTheUser(self,string: "For Now you can not Sign in")
                        
                    case AuthErrorCode.userDisabled:
                        // Error: The user account has been disabled by an administrator.
                        alertTheUser(self,string: "You have been Blocked")
                        
                    default:
                        print("Error: \(error.localizedDescription)")
                        alertTheUser(self,string: "Error: \(error.localizedDescription)")
                    }
                    
                } else {
                    print("User signs in successfully")
                    
                    let pushManager = PushNotificationManager(userID: Auth.auth().currentUser?.uid ?? "")
                    pushManager.registerForPushNotifications()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePageTabBarController") as! HomePageTabBarController
                    
                    changeWindow(from: self, to: homeVC)
                }
            }
        }
    }
    
    @IBAction func TapOnSignIn(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func TapOnPhoneImage(_ sender: Any) {
        let vc = PhoneNumberSignUpViewController(nibName: "PhoneNumberSignUpViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func userCreated() {
        let newUserInfo = Auth.auth().currentUser
        
        let imageRef = Storage.storage().reference().child("profileImages").child("\(newUserInfo?.uid ?? "1").png")
        
        if let profile = profileImage.image {
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            uploadImage(profile, at: imageRef, metadata: metadata, completion: { (downloadURL) in
                guard let downloadURL = downloadURL else {
                    alertTheUser(self, string: "Error in Image Upload")
                    return
                }
                let urlString = downloadURL.absoluteString
                print("image url: \(urlString)")
                
                let ref = Database.database().reference(withPath: "users")
                let userObject = UserInfo(firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, email: self.emailTextField.text!, phoneNumber: "", imageUrl: urlString)
                let user = ref.child(newUserInfo?.uid ?? "")
                user.setValue(userObject.toAnyObject())
                
                let pushManager = PushNotificationManager(userID: Auth.auth().currentUser?.uid ?? "")
                pushManager.registerForPushNotifications()
    
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = storyboard.instantiateViewController(withIdentifier: "HomePageTabBarController") as! HomePageTabBarController
                
                changeWindow(from: self, to: homeVC)
            })
        }
        
    }
    
    
    
    func checkData(code: Int, data: String) -> Bool{
        var regEx = ""
        
        switch code {
        case 1,2:
            regEx = "[A-Za-z]+"
        case 3:
            regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        default:
            return (0 != 0)
        }
        let test = NSPredicate(format: "SELF MATCHES%@", regEx)
        return test.evaluate(with: data)
    }
    
}


extension SignUpUserInfoViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImage.image = editedImage
        }
        else if let orignalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profileImage.image = orignalImage
        }
        
        profileImage.layer.cornerRadius = profileImage.bounds.width / 2
        profileImage.alpha = 1.0
        
        picker.dismiss(animated: true)
    }
}
