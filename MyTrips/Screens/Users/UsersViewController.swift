//
//  UsersViewController.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/22/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class UsersViewController: UITableViewController {

    var users = [UserInfo]()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 60
        self.tableView.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1))
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We don't show this screen to non-admin users
        guard Network.userRole == .manager || Network.userRole == .admin else {
            if let currentUser = Network.currentUser {
                let vc = UserTripsViewController.viewControllerInstance(userInfo: currentUser)
                self.navigationController?.pushViewController(vc, animated: false)
            } else {
                self.presentLoginScreen(animated: false)
            }
            return
        }
        
        self.startLoadingAnimation()
        self.refresh {
            self.stopLoadingAnimation()
        }
    }
    
    // MARK: - Helpers
    func refresh(completion:(()->Void)?=nil) {
        self.listUsers { (users, error) in
            if error == nil {
                self.users = users
                self.tableView.reloadData()
            }
            if let fn = completion {
                fn()
            }
        }
    }

    // MARK: - Table view data source & delegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        let userInfo = self.users[indexPath.row]
        cell.textLabel?.text = userInfo.email
        if self.isTripsLocked(userInfo: userInfo) {
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imgView.image = UIImage(named: "lock")!
            cell.accessoryView = imgView
        } else {
            cell.accessoryView = nil
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfo = self.users[indexPath.row]
        if self.isTripsLocked(userInfo: userInfo) {
            // we can not display
            self.showMessageBox(title: "Limited Access", message: "You don't have enough permissions to view this user's trips!")
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let vc = UserTripsViewController.viewControllerInstance(userInfo: userInfo)
            self.navigationController?.pushViewController(vc, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //MARK: - helpers
    func isTripsLocked(userInfo: UserInfo) -> Bool {
        return Network.userRole != .admin && Network.currentUser?.uid != userInfo.uid
    }
    
    //MARK: - navigation buttons
    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        self.logout()
    }

}
