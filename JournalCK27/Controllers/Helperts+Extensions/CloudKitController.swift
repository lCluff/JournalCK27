//
//  CloudKitController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitController {
    
    static let shared = CloudKitController()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD
    // Create
    func save(record: CKRecord, database: CKDatabase, completion: @escaping (CKRecord?) -> Void) {
        // save the record passed in, complete with an optional error
        database.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
            }
            print(#function)
            completion(record)
        }
    }
    
    // Read
    func fetchSingleRecord(ofType type: String, withPredicate predicate: NSPredicate, database: CKDatabase, completion: @escaping([CKRecord]?) -> Void ) {
        let query = CKQuery(recordType: type, predicate: predicate)
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("there was an error fetching record,\(error)" )
                completion(nil)
                return
            }
            guard let records = records
                else { completion(nil) ; return}
            completion(records)
        }
    }
    
    func fetchRecordsOf(type: String, database: CKDatabase, completion: @escaping ([CKRecord]?, Error?) -> Void) {
        // Conditions of query, conditions to be return all found values
        let predicate = NSPredicate(value: true)
        // defines the record type we want to find, applies our predicate conditions
        let query = CKQuery(recordType: type, predicate: predicate)
        // Perform query, complete with our optional records and optional error
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) /n---/n \(error)")
                completion(nil, error)
            }
            if let records = records {
                completion(records, nil)
            }
        }
    }
    
    func fetchAppleUserReference() -> CKRecord.Reference? {
        var reference: CKRecord.Reference?
        CKContainer.default().fetchUserRecordID { (appleUserReferenceID, error) in
            if let error = error {
                print( "There was an error fetching the apple user reference \(error); \(error.localizedDescription)")
                return
            }
            guard let recordID = appleUserReferenceID else { return }
            let appleUserReference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            reference = appleUserReference
        }
        return reference
    }
    
    // Update
    func update(record: CKRecord, database: CKDatabase, completion: @escaping (Bool) -> Void) {
        let operation = CKModifyRecordsOperation()
        operation.recordsToSave = [record]
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.queuePriority = .high
        operation.completionBlock = {
            completion(true)
        }
        database.add(operation)
    }
    
    // Delete
    func delete(recordID: CKRecord.ID, database: CKDatabase, completion: @escaping (Bool) -> Void) {
        database.delete(withRecordID: recordID) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) /n---/n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
}
