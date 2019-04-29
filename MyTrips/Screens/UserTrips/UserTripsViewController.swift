//
//  UserTripsTableViewController.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/20/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

enum FilterType {
    case upcoming, past
}

class UserTripsViewController: UIViewController, TripEditorViewControllerDelegate, TripViewerViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    var userTrips = [UserTrip]()
    var filteredUserTrips:[UserTrip]?
    var userInfo: UserInfo!
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    class func viewControllerInstance(userInfo: UserInfo!) -> UserTripsViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "UserTrips", bundle: nil)
        let nv = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = nv.viewControllers.first as! UserTripsViewController
        vc.userInfo = userInfo
        return vc
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: UserTripsTableViewCell.className, bundle: nil), forCellReuseIdentifier: UserTripsTableViewCell.className)
        self.tableView.rowHeight = 100
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1))
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0.1, height: 0.1))
        self.view.backgroundColor = Theme.themeEmptySpaceBackgroundColor
        
        self.addRefreshControl()

        self.setStatusMessage(nil)
        
        self.startLoadingAnimation()
        self.refresh{
            self.stopLoadingAnimation()
        }
        
        self.addSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If the user is admin, we shown the back button, else we show the logout icon
        if Network.userRole == .admin || Network.userRole == .manager {
            self.navigationItem.leftBarButtonItem = nil
        } else {
            let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(onLogout))
            self.navigationItem.leftBarButtonItem = logOutButton
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredUserTrips?.count ?? self.userTrips.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTripsTableViewCell.className, for: indexPath) as! UserTripsTableViewCell
        
        // Configure the cell...
        cell.updateWith(userTrip: self.filteredUserTrips?[indexPath.row] ?? self.userTrips[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = TripViewerViewController.viewControllerInstance(userTrip:  self.filteredUserTrips?[indexPath.row] ?? self.userTrips[indexPath.row], userInfo: self.userInfo, tripViewerDelegate: self)
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.filteredUserTrips == nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Network.deleteUserTrip(userInfo: self.userInfo, userTrip: self.userTrips[indexPath.row]) { error in
                if let error = error {
                    self.showMessageBox(title: "Error", message: error)
                } else {
                    self.userTrips.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    // MARK: - search delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchText: String? =  self.navigationItem.searchController?.searchBar.text
        if searchText != nil && searchText?.count ?? 0 > 0 {
            self.filterUserTrips(userTrips: self.userTrips, searchText: searchText!) { (userTrips, searchText, error) in
                if searchText == self.navigationItem.searchController?.searchBar.text {
                    // the text in the search bar is still the same
                    self.filteredUserTrips = userTrips
                    self.updateStatusMessage()
                    self.tableView.reloadData()
                }
            }
        } else {
            if self.filteredUserTrips != nil {
                self.filteredUserTrips = nil
                self.updateStatusMessage()
                self.tableView.reloadData()
            }
        }
    }

    
    // MARK: - Trip editor delegate
    func onUserTripChange(_ userTrip: UserTrip) {
        Network.addUserTrip(userInfo: self.userInfo, userTrip: userTrip) { error in
            self.refresh()
            if let error = error {
                self.showMessageBox(title: "Error", message: error)
            }
        }
    }
    
    //MARK: - Helpers
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching User's Trips ...", attributes: nil)
    }
    
    func addSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Trips"
        self.definesPresentationContext = true
        self.navigationItem.searchController = searchController
    }
    
    func listUserNetworkCall() -> (UserInfo, @escaping ([UserTrip], String?) -> Void) -> () {
        return Network.listAllUserTrips
    }
    
    @objc func refresh(completion:(()->Void)? = nil) {
        self.listUserNetworkCall()(self.userInfo){ (userTrips, error) in
            self.stopLoadingAnimation()
            if let error = error {
                if let fn = completion {
                   fn()
                }
                self.showMessageBox(title: "Error", message: error)
            } else {
                self.tableView.refreshControl?.endRefreshing()
                if( self.userTrips != userTrips) {
                    self.userTrips = userTrips
                    self.tableView.reloadData()
                }
                self.updateStatusMessage()
                if let fn = completion {
                    fn()
                }
            }
        }
    }
    
    func updateStatusMessage() {
        if let filteredUserTrips = self.filteredUserTrips {
            let statusMessage = filteredUserTrips.count > 0 ? nil: "No match found!"
            self.setStatusMessage(statusMessage)
        } else {
            let statusMessage = self.userTrips.count > 0 ? nil: "No trips found!"
            self.setStatusMessage(statusMessage)
        }
    }
    
    func setStatusMessage(_ status: String?) {
        guard status != nil && status?.count ?? 0 > 0 else {
            self.statusLabel.isHidden = true
            self.tableView.isHidden = false
            return
        }
        self.statusLabel.text = status
        self.statusLabel.isHidden = false
        self.tableView.isHidden = true
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return self.navigationItem.searchController!.isActive && !self.searchBarIsEmpty()
    }
    
    //MARK: - Editor delegate
    func onTripEditorAddTrip(_ tripEditorViewController: TripEditorViewController, newUserTrip: UserTrip) {
        self.onUserTripChange(newUserTrip)
    }
    
    func onTripEditorUpdateTrip(_ tripEditorViewController: TripEditorViewController, updatedUserTrip: UserTrip) {
        self.onUserTripChange(updatedUserTrip)
    }
    
    //MARK: - Viewer delegate
    func onTripViewerUpdateTrip(_ tripViewerViewController: TripViewerViewController, updatedUserTrip: UserTrip) {
        self.onUserTripChange(updatedUserTrip)
    }
    
    
    // MARK: - Navigation actions
    @IBAction func onAddTrip(_ sender: Any) {
        let nvc = TripEditorViewController.navigationViewControllerInstance(tripEditorDelegate: self)
        self.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func onAction(_ sender: Any) {
        self.onPrintUserTrips()
        // self.printUserTrips(self.userTrips)
    }
    
    @IBAction func onLogout(_ sender: UIBarButtonItem) {
        self.logout()
    }
}
