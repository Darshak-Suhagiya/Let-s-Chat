//
//  config.swift
//  Let's Chat
//
//  Created by DUIUX-01 on 27/03/23.
//

import Foundation
import UIKit
import FirebaseStorage

func setupKeyboard(_ vc: UIViewController){
    let tap = UITapGestureRecognizer(target: vc, action: #selector(vc.dismissKeyboard))

    vc.view.addGestureRecognizer(tap)
}

func alertTheUser(_ vc: UIViewController,string: String) {
    vc.dismiss(animated: false) {
        let alert = UIAlertController(title: "Alert!", message: string, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        vc.present(alert, animated: true, completion: nil)
    }
}

func showLoader(_ vc: UIViewController) {
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.medium
    loadingIndicator.startAnimating();

    alert.view.addSubview(loadingIndicator)
    vc.present(alert, animated: false, completion: nil)
}

func dismissLoader(_ vc: UIViewController) {
    
    vc.dismiss(animated: false)
}

func changeWindow(from: UIViewController, to: UIViewController) {
    
    let rootNC = UINavigationController(rootViewController: to)
    
    let transition = CATransition()
    transition.duration = 0.3
    transition.type = .push
    transition.isRemovedOnCompletion = true
    transition.subtype = .fromRight
    from.view.window?.layer.add(transition, forKey: kCATransition)
    
    from.view.window!.rootViewController = rootNC
}


func uploadImage(_ image: UIImage, at reference: StorageReference, metadata: StorageMetadata, completion: @escaping (URL?) -> Void) {
    // 1
    guard let imageData = image.pngData() else {
        return completion(nil)
    }
    
    // 2
    reference.putData(imageData, metadata: metadata, completion: { (metadata, error) in
        // 3
        if let error = error {
            assertionFailure(error.localizedDescription)
            return completion(nil)
        }
        
        // 4
        reference.downloadURL(completion: { (url, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            completion(url)
        })
    })
}
