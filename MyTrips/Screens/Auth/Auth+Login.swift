//
//  Auth+Login.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/25/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension AuthViewController {

    class func loginViewControllerInstance() -> UINavigationController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let nv = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nv.viewControllers.first as! AuthViewController
        vc.authType = .login
        nv.modalTransitionStyle = .crossDissolve
        return nv
    }
    
    func onLogin(_ username: String, _ password: String) {
        let email = self.emailTextField.text ?? ""
        let password = self.passwrodTextField.text ?? ""
        self.startLoadingAnimation()
        Network.signIn(email: email, password: password) { isAdmin, error in
            self.stopLoadingAnimation()
            if let error = error {
                self.showMessageBox(title: "Error",message: error)
            } else {
                if let nv:UINavigationController = self.presentingViewController as? UINavigationController {
                    nv.popToRootViewController(animated: false)
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
