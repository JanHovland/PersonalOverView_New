//
//  CloudKitUser.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

//
//  CloudKitUser.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

import CloudKit
import SwiftUI

struct CloudKitUser {
    
    /// Inneholder:
    ///     doesUserExist
    ///     fetchUser
    ///     saveUser
    ///     modifyUser
    
    struct RecordType {
        static let user = "User"
    }
    
    /// MARK: - errors
    enum CloudKitHelperError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    // MARK: - check if the user record exists
    static func doesUserExist(email: String,
                              password: String,
                              completion: @escaping (String) -> ()) {
        var result = "OK"
        let predicate = NSPredicate(format: "email == %@ AND password = %@", email, password)
        let query = CKQuery(recordType: RecordType.user, predicate: predicate)
        DispatchQueue.main.async {
            /// inZoneWith: nil : Specify nil to search the default zone of the database.
            CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, er) in
                DispatchQueue.main.async {
                    let description = "\(String(describing: er))"
                    if description != "nil" {
                        if description.contains("authentication token") {
                            result = NSLocalizedString("Couldn't get an authentication token", comment: "SignInView")
                        } else if description.contains("authenticated account") {
                            result = NSLocalizedString("This request requires an authenticated account", comment: "SignInView")
                        }
                        completion(result)
                    } else {
                        if results?.count == 0 {
                            result = NSLocalizedString("This email and password doesn't belong to a registered user", comment: "CloudKitUser")
                        } else {
                            result = "OK"
                        }
                        completion(result)
                    }
                }
            })
        }
    }
    
    // MARK: - fetching from CloudKit
    /// Legg merke til følgende:
    ///     UserRecord defineres slik: struct UserElement: Identifiable
    ///     User defineres slik:             class User: ObservableObject
    static func fetchUser(predicate:  NSPredicate, completion: @escaping (Result<UserRecord, Error>) -> ()) {
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: RecordType.user, predicate: predicate)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["name","email","password","image"]
        operation.resultsLimit = 500
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                guard let name = record["name"] as? String else { return }
                guard let email = record["email"] as? String else { return }
                guard let password = record["password"] as? String else { return }
                
                if let image = record["image"], let imageAsset = image as? CKAsset {
                    if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {
                        let image = UIImage(data: imageData)
                        let userRecord = UserRecord(recordID: recordID,
                                                    name: name,
                                                    email: email,
                                                    password: password,
                                                    image: image)
                        completion(.success(userRecord))
                    }
                }
                else {
                    let userRecord = UserRecord(recordID: recordID,
                                                name: name,
                                                email: email,
                                                password: password,
                                                image: nil)
                    completion(.success(userRecord))
                }
            }
        }
        operation.queryCompletionBlock = { ( _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    /// MARK: - saving to CloudKit
    static func saveUser(item: UserRecord, completion: @escaping (Result<UserRecord, Error>) -> ()) {
        let itemRecord = CKRecord(recordType: RecordType.user)
        itemRecord["name"] = item.name as CKRecordValue
        itemRecord["email"] = item.email as CKRecordValue
        itemRecord["password"] = item.password as CKRecordValue
        if ImagePicker.shared.imageFileURL != nil {
            itemRecord["image"] = CKAsset(fileURL: ImagePicker.shared.imageFileURL!)
        }
        CKContainer.default().privateCloudDatabase.save(itemRecord) { (record, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let record = record else {
                    completion(.failure(CloudKitHelperError.recordFailure))
                    return
                }
                let recordID = record.recordID
                guard let name = record["name"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let email = record["email"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let password = record["password"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                /// MARK: - "image" kan være nil, dersom det ikke er valgt noe bilde
                /// guard (record["image"] as? CKAsset) != nil else {
                ///     completion(.failure(CloudKitHelperError.castFailure))
                ///     return
                /// }
                
                let userRecord = UserRecord(recordID: recordID,
                                            name: name,
                                            email: email,
                                            password: password)
                completion(.success(userRecord))
            }
        }
    }
    
    // MARK: - delete user from CloudKit
    static func deleteUser(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().privateCloudDatabase.delete(withRecordID: recordID) { (recordID, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let recordID = recordID else {
                    completion(.failure(CloudKitHelperError.recordIDFailure))
                    return
                }
                completion(.success(recordID))
            }
        }
    }
    
    // MARK: - modify in CloudKit
    static func modifyUser(item: UserRecord, completion: @escaping (Result<UserRecord, Error>) -> ()) {
        guard let recordID = item.recordID else { return }
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) { record, err in
            if let err = err {
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }
            guard let record = record else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitHelperError.recordFailure))
                }
                return
            }
            record["name"] = item.name as CKRecordValue
            record["email"] = item.email as CKRecordValue
            record["password"] = item.password as CKRecordValue
            if ImagePicker.shared.imageFileURL != nil {
                /// Her lagres det et komprimertbilde
                record["image"] = CKAsset(fileURL: ImagePicker.shared.imageFileURL!)
            }
            
            CKContainer.default().privateCloudDatabase.save(record) { (record, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    guard let record = record else {
                        completion(.failure(CloudKitHelperError.recordFailure))
                        return
                    }
                    let recordID = record.recordID
                    guard let name = record["name"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let email = record["email"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let password = record["password"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    let userRecord = UserRecord(recordID: recordID,
                                                name: name,
                                                email: email,
                                                password: password)
                    
                    completion(.success(userRecord))
                }
            }
        }
    }
    
    // MARK: - delete all Users from CloudKit
    static func deleteAllUsers() {
        let privateDb =  CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "User", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        var counter = 0
        privateDb.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                for record in records! {
                    privateDb.delete(withRecordID: record.recordID, completionHandler: { (recordId, error) in
                        if error == nil {
                            _ = 0
                        }
                    })
                    counter += 1
                }
                let message1 = NSLocalizedString("Records deleted:", comment: "SettingView")
                let _ = message1 + " " + "\(counter)"
            } else {
                let _ = error!.localizedDescription 
            }
        }
    }
    
}

