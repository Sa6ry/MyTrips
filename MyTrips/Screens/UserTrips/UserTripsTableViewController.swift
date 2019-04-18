//
//  UserTripsTableViewController.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/20/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit

class UserTripsViewController: UITableViewController, TripEditorViewControllerDelegate {
    
    var userTrips = [UserTrip]()
    
    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: UserTripsTableViewCell.className, bundle: nil), forCellReuseIdentifier: UserTripsTableViewCell.className)
        self.tableView.rowHeight = 100
        self.tableView.tableHeaderView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        Database.allUserTrips { (userTrips, error) in
            self.userTrips = userTrips
            self.tableView.reloadData()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
//        let segment: UISegmentedControl = UISegmentedControl(items: ["Upcoming", "Past"])
//        segment.sizeToFit()
//        // segment.tintColor = UIColor(red:0.99, green:0.00, blue:0.25, alpha:1.00)
//        segment.selectedSegmentIndex = 0;
//        segment.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)], for: .normal)
//        self.navigationItem.titleView = segment
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userTrips.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTripsTableViewCell.className, for: indexPath) as! UserTripsTableViewCell

        // Configure the cell...
        cell.updateWith(userTrip: self.userTrips[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nvc = TripEditorViewController.navigationViewControllerInstance(userTrip:self.userTrips[indexPath.row], tripEditorDelegate: self)
        self.present(nvc, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Database.deleteUserTrip(self.userTrips[indexPath.row])
            self.userTrips.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Trip editor delegate
    func onUserTripChange(_ userTrip: UserTrip) {
        if let obj = self.userTrips.first(where: {$0.uuid == userTrip.uuid}) {
            obj.copyValues(userTrip)
            Database.addUserTrip(obj)
        } else {
            // this is a new item
            self.userTrips.append(userTrip)
            Database.addUserTrip(userTrip)
        }
        self.tableView.reloadData()
    }
    
    func onTripEditorSaveTrip(_ tripEditorViewController: TripEditorViewController, newUserTrip: UserTrip) {
        self.onUserTripChange(newUserTrip)
    }
    
    func onTripEditorUpdateTrip(_ tripEditorViewController: TripEditorViewController, updatedUserTrip: UserTrip) {
        self.onUserTripChange(updatedUserTrip)
    }
    
    
    // MARK: - Navigation buttons
    @IBAction func onAddTrip(_ sender: Any) {
        let nvc = TripEditorViewController.navigationViewControllerInstance(tripEditorDelegate: self)
        self.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func onDummy(_ sender: UIBarButtonItem) {
        let nvc = LoginViewController.viewControllerInstance()
        self.present(nvc, animated: true, completion: nil)
    }
}
