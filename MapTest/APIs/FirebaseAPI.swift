//
//  FirebaseAPI.swift
//  MapTest
//
//  Created by Oleksii Shulzhenko on 28.01.2018.
//  Copyright © 2018 Oleksii Shulzhenko. All rights reserved.
//

import Firebase
import FirebaseAuth
import GooglePlaces

class FirebaseAPI {
    
    private var uID: String!
    
    private static let _instance = FirebaseAPI()
    static var instance: FirebaseAPI { return _instance }
    
    var mainRef: DatabaseReference { return Database.database().reference() }
    private var changeUserRefHandle: DatabaseHandle?
    private var newUserRefHandle: DatabaseHandle?
    private lazy var userRef: DatabaseReference = mainRef.child(FIR_CHILD_USER)
    
    let FIR_CHILD_USER = "user"
    
    func saveUser(uid: String, name: String, email: String) {
        let profile: Dictionary<String, AnyObject> = ["name" : name as AnyObject, "email" : email as AnyObject, "userID" : uid as AnyObject]
        mainRef.child(FIR_CHILD_USER).child(uid).child("profile").setValue(profile)
    }
    
    func newUser(withEmail: String, password: String, name: String, _ completionBlock: @escaping (_ success: Bool, _ errorMessage: String) -> ()) {
        Auth.auth().createUser(withEmail: withEmail, password: password) { [weak self](user, error) in
            guard let strongSelf = self else {completionBlock(false, ""); return}
            if let e = error {
                completionBlock(false, strongSelf.getErrorString(error: e))
            } else {
                strongSelf.saveUser(uid: user!.uid, name: name, email: withEmail)
                strongSelf.login(withEmail: withEmail, password: password, completionBlock)
            }
        }
    }
    
    func login(withEmail: String, password: String, _ completionBlock: @escaping (_ success: Bool, _ errorMessage: String) -> ()) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { [weak self](user, error) in
            guard let strongSelf = self else {completionBlock(false, ""); return}
            if let e = error {
                completionBlock(false, strongSelf.getErrorString(error: e))
            } else {
                strongSelf.uID = user!.uid
                completionBlock(true, "")
            }
        })
    }
    
    private func getErrorString(error: Error) -> String {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch errorCode {
            case .invalidEmail:
                return "Invalid email address"
            case .wrongPassword:
                return "Invalid password"
            case .emailAlreadyInUse, .accountExistsWithDifferentCredential:
                return "Could not create account. Email allready in use"
            case .weakPassword:
                return "You entered a weak password. Try again."
            default:
                return "There was a problem authenticating. Try again."
            }
        } else {
            return "There was a problem authenticating. Try again."
        }
    }
    
    func setSelfLocation(coordinate: CLLocationCoordinate2D, lastUpdate: NSDate) {
        let coordinate: Dictionary<String, AnyObject> = ["latitude" : coordinate.latitude as AnyObject, "longitude" : coordinate.longitude as AnyObject]
        mainRef.child(FIR_CHILD_USER).child(uID).child("profile").child("coordinate").setValue(coordinate)
        mainRef.child(FIR_CHILD_USER).child(uID).child("profile").child("lastUpdate").setValue(lastUpdate.timeIntervalSinceReferenceDate as AnyObject)
    }
    
    func getUsers(_ completionBlock: @escaping (_ users: [UserModel]) -> ()) {
        userRef.observeSingleEvent(of: .value) { [weak self](snapshot) in
            guard let strongSelf = self else {completionBlock([UserModel]()); return}
            completionBlock(strongSelf.parseUsers(from: snapshot))
        }
    }
    
    func observeChangeUsers(_ completionBlock: @escaping (_ users: [UserModel]) -> ()) {
        let userQuery = userRef.queryOrderedByValue()
        changeUserRefHandle = userQuery.observe(.childChanged, with: { [weak self](snapshot) in
            guard let strongSelf = self else {completionBlock([UserModel]()); return}
            completionBlock(strongSelf.parseUsers(from: snapshot))
        })
    }
    
    func observeNewUsers(_ completionBlock: @escaping (_ users: [UserModel]) -> ()) {
        let userQuery = userRef.queryOrderedByValue()
        
        newUserRefHandle = userQuery.observe(.childAdded, with: { [weak self](snapshot) in
            guard let strongSelf = self else {completionBlock([UserModel]()); return}
            completionBlock(strongSelf.parseUsers(from: snapshot))
        })
    }
    
    func removeObservers() {
        userRef.removeAllObservers()
    }
    
    private func parseUsers(from dataSnapshot: DataSnapshot) -> [UserModel] {
        var users = [UserModel]()
        guard let userData = dataSnapshot.value as? [String: AnyObject] else {return users}
        for iD in userData {
            do {
                guard let profile = iD.value["profile"] as? [String: AnyObject] else {break}
                let data = try JSONSerialization.data(withJSONObject: profile, options: [])
                let user = try JSONDecoder().decode(UserModel.self, from: data)
                users.append(user)
            } catch let error {
                print(error)
                break
            }
        }
        return users
    }
}
