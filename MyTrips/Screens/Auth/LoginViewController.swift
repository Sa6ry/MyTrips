//
//  LoginViewController.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/21/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwrodTextField: UITextField!
    
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    class func viewNavigationControllerInstance() -> UINavigationController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let nv = storyboard.instantiateInitialViewController() as! UINavigationController
        nv.modalTransitionStyle = .crossDissolve
        return nv
    }
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Theme.themeBackgroundColor
        self.title = "Login"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObservers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwrodTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - buttons actions
    @IBAction func onLogin() {
        self.hideKeyboard()
        let email = self.emailTextField.text ?? ""
        let password = self.passwrodTextField.text ?? ""
        Network.signIn(email: email, password: password) { isAdmin, error in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                NSLog(error!)
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        let vc = SignUpViewController.viewNavigationControllerInstance()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Helpers
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Keyboard Animation
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,  name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ,
            let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            self.keyboardConstraint.constant = keyboardSize.height
            UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            self.keyboardConstraint.constant = 0
            UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}
