//
//  UserController.swift
//  JournalCK27
//
//  Created by Leah Cluff on 7/10/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    // Singleton
    static let sharedInstance = UserController()
    
    // Source of truth
    var currentUser: User?
    
    //MARK: - CRUD Functions
    func createUserWith(username: String, email: String, completion: @escaping(User?)-> Void) {
        guard let appleUserReference = CloudKitController.shared.fetchAppleUserReference() else {
            completion(nil) ;  return}
        let newUser = User(username: username, email: email, appleUserReference: appleUserReference)
        let userRecord = CKRecord(user: newUser)
        let database = CloudKitController.shared.privateDB
        
        CloudKitController.shared.save(record: userRecord, database: database) { (record) in
            guard let record = record,
                let user = User(record: record) else { completion(nil) ; return}
            self.currentUser = user
        }
    }
    
    func fetchUser(completion: @escaping(Bool) -> Void) {
        guard let appleUserReference = CloudKitController.shared.fetchAppleUserReference()
            else { completion(false) ; return }
        
        let predicate = NSPredicate(format: "appleUserReference == %@", appleUserReference)
        let database = CloudKitController.shared.privateDB
        
        CloudKitController.shared.fetchSingleRecord(ofType: UserConstants.typeKey, withPredicate: predicate, database: database) { (records) in
            
            guard let records = records,
                let record = records.first
            else { completion(false) ; return}
            
            self.currentUser = User(record: record)
            completion(true)
        }
        
    }
}
