//
//  Extensions.swift
//  SQLManager
//
//  Created by Никита Пивоваров on 04.03.2023.
//

import Foundation
import UIKit

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case hostname
        case username
        case password
        case database
    }
    
    var hostname: String? {
        get {
            string(forKey: UserDefaultsKeys.hostname.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.hostname.rawValue)
        }
    }
    
    var username: String? {
        get {
            string(forKey: UserDefaultsKeys.username.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.username.rawValue)
        }
    }
    
    var password: String? {
        get {
            string(forKey: UserDefaultsKeys.password.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.password.rawValue)
        }
    }
    
    var database: String? {
        get {
            string(forKey: UserDefaultsKeys.database.rawValue)
        }
        
        set {
            setValue(newValue,
                     forKey: UserDefaultsKeys.database.rawValue)
        }
    }
}

extension UIViewController {
    internal func setupKeyboardHidding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextField else { return }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY
        }
    }
    
    @objc private func keyboardWillHide(sender: NSNotification) {
        view.frame.origin.y = 0
    }
}

extension UIResponder {
    
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
