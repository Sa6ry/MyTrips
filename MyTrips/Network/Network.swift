//
//  Database.swift
//  MyTrips
//
//  Created by Ahmed Sabry on 4/21/19.
//  Copyright © 2019 Sabry. All rights reserved.
//

import UIKit
import CodableFirebase
import Firebase

enum UserRole: String {
    case user, admin, manager
}

class Network: NSObject {
    // static let sharedInstance = Database()
    private static let db = Firestore.firestore()
    private static let usersCollection = db.collection("users")
    class var userRole: UserRole {
        get {
            let stringValue = UserDefaults.standard.string(forKey: "Network_userRole") ?? "user"
            return UserRole(rawValue: stringValue) ?? UserRole.user
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "Network_userRole")
        }
    }
    
    class var currentUser: UserInfo? {
        get {
            if self.userEmail != nil && self.userUid != nil {
                return UserInfo(uid: self.userUid!, email: self.userEmail!)
            } else {
                return nil
            }
        }
    }

    private class var userEmail: String? {
        return Auth.auth().currentUser?.email
    }
    
    private class var userUid: String? {
        return Auth.auth().currentUser?.uid
    }
    
    class func isLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    private class func userTripsCollection(_ userInfo: UserInfo?) -> CollectionReference {
        return self.usersCollection.document(userInfo?.uid ?? self.userUid!).collection("trips")
    }
    
    private class func updateUserInfo(completion:@escaping (_ error:String?) -> Void) {
        guard self.userUid != nil && self.userEmail != nil else {
            return
        }
        let userInfo = UserInfo(uid: self.userUid!, email: self.userEmail!)
        let data: [String: Any] = try! FirebaseEncoder().encode(userInfo) as! [String : Any]

        self.usersCollection.document(self.userUid!).setData(data) { err in
            completion(err?.localizedDescription ?? nil)
        }
    }
    
    class func logout(completion:@escaping (String?)->Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error.localizedDescription)
        }
    }
    
    class func createUser(email: String, password: String, completion:@escaping (_ userRole:UserRole, _ error:String?)->Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
            if error == nil {
                self.signIn(email: email, password: password, completion: completion)
                return
            } else {
                let error = error! as NSError
                let errorMessage = error.userInfo[NSLocalizedDescriptionKey]! as! String
                completion(UserRole.user, errorMessage)
            }
        }
    }
    
    class func signIn(email: String, password: String, completion:@escaping (_ userRole:UserRole, _ error:String?)->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if error == nil {
                // get the user role (admin or not)
                self.updateUserInfo() { error in
                    self.getUserRole { userRole, error in
                        self.userRole = userRole
                        completion(userRole, error)
                    }
                }
            } else {
                let signInError = error! as NSError
                let errorMessage = signInError.userInfo[NSLocalizedDescriptionKey]! as! String
                completion(UserRole.user, errorMessage)
            }
        }
    }
    
    class func listUsers(completion:@escaping (_ users: [UserInfo], _ error:String? )-> Void) {        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            var users = [UserInfo]()
            if let err = err {
                let listError = err as NSError
                if listError.code == 7 { // permision error
                    guard self.userUid != nil && self.userEmail != nil else {
                        completion(users,nil)
                        return
                    }
                    let userInfo = UserInfo(uid: self.userUid!, email: self.userEmail!)
                    users.append(userInfo)
                    completion(users,nil)
                } else {
                    completion(users, listError.localizedDescription)
                }
            } else {
                for document in querySnapshot!.documents {
                    let userInfo = try! FirebaseDecoder().decode(UserInfo.self, from: document.data())
                    users.append(userInfo)
                }
                completion(users, nil)
            }
        }
    }
    
    class func addUserTrip(userInfo:UserInfo, userTrip: UserTrip, completion:@escaping (_ error:String? )-> Void) {
        let data: [String: Any] = try! FirebaseEncoder().encode(userTrip) as! [String : Any]
        
        self.userTripsCollection(userInfo).document(userTrip.uuid).setData(data) { err in
            if let err = err {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
    
    class func deleteUserTrip(userInfo: UserInfo, userTrip: UserTrip, completion:@escaping (_ error:String? )-> Void) {
        self.userTripsCollection(userInfo).document(userTrip.uuid).delete() { err in
            if let err = err {
                completion(err.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
    
    class func getUserRole(completion:@escaping (_ userRole:UserRole, _ error: String?) -> Void) {
        db.collection("administrators").document(self.userUid!).getDocument() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(UserRole.user, err.localizedDescription)
            } else {
                if let userRoles = querySnapshot?.data() {
                    let isAdmin = userRoles["isAdmin"] as? Bool
                    let isManager = userRoles["isManager"] as? Bool
                    if isAdmin == true {
                        completion(UserRole.admin, nil)
                    }
                    else if isManager == true {
                        completion(UserRole.manager, nil)
                    } else {
                        completion(UserRole.user, nil)
                    }
                }else {
                    completion(UserRole.user, nil)
                }
            }
        }
    }
    
    private class func getUserTripsList(query:Query, completion:@escaping (_ userTirps: [UserTrip], _ error:String? )-> Void) {
        query.getDocuments() { (querySnapshot, err) in
            var userTrips = [UserTrip]()
            if let err = err {
                completion(userTrips, err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    let userTrip = try! FirebaseDecoder().decode(UserTrip.self, from: document.data())
                    userTrips.append(userTrip)
                }
                completion(userTrips, nil)
            }
        }
    }

    class func listPastUserTrips(userInfo: UserInfo, completion:@escaping (_ userTirps: [UserTrip], _ error:String? )-> Void) {
        let today = try! FirebaseEncoder().encode(Calendar.current.startOfDay(for: Date.init()))
        let query = self.userTripsCollection(userInfo).whereField("startDate", isLessThanOrEqualTo: today).order(by: "startDate")
        self.getUserTripsList(query: query, completion: completion)
    }
    
    class func listUpcomingUserTrips(userInfo: UserInfo, completion:@escaping (_ userTirps: [UserTrip], _ error:String? )-> Void) {
        let today = try! FirebaseEncoder().encode(Calendar.current.startOfDay(for: Date.init()))
        let query = self.userTripsCollection(userInfo).whereField("startDate", isGreaterThan: today).order(by: "startDate")
        self.getUserTripsList(query: query, completion: completion)
    }
    
    class func listAllUserTrips(userInfo: UserInfo, completion:@escaping (_ userTirps: [UserTrip], _ error:String? )-> Void) {
        let query = self.userTripsCollection(userInfo).order(by: "startDate")
        self.getUserTripsList(query: query, completion: completion)
    }
    
    class func getUserTrip(userInfo: UserInfo, tripUid: String, completion:@escaping (_ userTirps: UserTrip?, _ error:String? )-> Void) {
        self.userTripsCollection(userInfo).document(tripUid).getDocument() { (querySnapshot, err) in
            if let err = err {
                completion(nil, err.localizedDescription)
            } else {
                if let data: [String: Any] = querySnapshot?.data() {
                    let userTrip = try! FirebaseDecoder().decode(UserTrip.self, from: data)
                    completion(userTrip, nil)
                } else {
                    completion(nil, nil)
                }
            }
        }
    }
    
}
