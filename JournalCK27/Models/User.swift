//
//  User.swift
//  JournalCK27
//
//  Created by Leah Cluff on 7/10/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

struct UserConstants {
    static let typeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let emailKey = "email"
    fileprivate static let appleUserReferenceKey = "appleUserReference"
}

class User {
    //Class Properties
    var username: String
    var email: String
    //Cloud Properties
    let recordID: CKRecord.ID
    let appleUserReference: CKRecord.Reference
    
    ///Initiallizes a new User object
    init(username: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference) {
        self.username = username
        self.email = email
        self.recordID = recordID
        self.appleUserReference = appleUserReference
    }
}

extension User {
    /// Initializes an existing User objext from a CKRecord
    convenience init?(record: CKRecord) {
        guard let username = record[UserConstants.appleUserReferenceKey] as? String,
            let email = record[UserConstants.emailKey] as? String,
            let appleUserReference = record[UserConstants.appleUserReferenceKey] as? CKRecord.Reference
            else { return nil }
        self.init(username: username, email: email, recordID: record.recordID, appleUserReference: appleUserReference)
    }
}

extension CKRecord {
    /// Initializes a CKRecord from an existing User object
    convenience init(user: User) {
        self.init(recordType: UserConstants.typeKey, recordID: user.recordID)
        self.setValue(user.email, forKey: UserConstants.emailKey)
        self.setValue(user.username, forKey: UserConstants.usernameKey)
        self.setValue(user.appleUserReference, forKey: UserConstants.appleUserReferenceKey)
    }
}
