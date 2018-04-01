//
//  InterfaceHelper.swift
//  Tailgate
//
//  Created by Michael Onjack on 3/25/18.
//  Copyright © 2018 Michael Onjack. All rights reserved.
//

import UIKit

func createAlert(title: String, message: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let closeAction = UIAlertAction(title: "Close", style: .default)
    alert.addAction(closeAction)
    
    return alert
}



extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



class PaddedTextField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
