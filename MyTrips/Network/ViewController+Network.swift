//
//  ViewController+Network.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/23/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


extension UIViewController {
    
    func presentLoginScreen(animated: Bool) {
        let authViewController = AuthViewController.loginViewControllerInstance()
        self.present(authViewController, animated: animated, completion: nil)
    }
    
    func logout() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: UIAlertAction.Style.destructive, handler: { (alert) in
            Network.logout { (error) in
                if(error !=  nil) {
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.presentLoginScreen(animated: true)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func listUsers(completion:@escaping (_ users: [UserInfo], _ error:String? )-> Void) {
        if !Network.isLoggedIn() {
            completion([],"Not logged in")
            return self.presentLoginScreen(animated: false)
        }
        Network.listUsers(completion: completion)
    }
    
    func allUserTrips(userInfo: UserInfo, completion:@escaping (_ userTirps: [UserTrip], _ error:String? )-> Void) {
        if !Network.isLoggedIn() { return self.presentLoginScreen(animated: false) }
        Network.listAllUserTrips(userInfo: userInfo, completion: completion)
    }
}
