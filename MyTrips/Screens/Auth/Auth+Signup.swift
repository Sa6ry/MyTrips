//
//  Auth+Signup.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/25/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

extension AuthViewController {

    class func signupViewControllerInstance() -> UIViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RootVC") as! AuthViewController
        vc.authType = .signup
        return vc
    }
    
    func onSignUp(_ email: String, _ password: String) {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData())
        self.startLoadingAnimation()
        Network.createUser(email: email, password: password) { isAdmin, error in
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
