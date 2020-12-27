//
//  CloudKitPostNummer.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 01/10/2020.
//

import CloudKit
import SwiftUI

struct CloudKitPostNummer {
    
    struct RecordType {
        static let PostNummer = "PostNummer"
    }
    /// MARK: - errors
    enum CloudKitHelperError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    
    /// MARK: - saving to CloudKit
    static func savePostNummer(item: PostNummer, completion: @escaping (Result<PostNummer, Error>) -> ()) {
        let itemRecord = CKRecord(recordType: RecordType.PostNummer)
        itemRecord["postalNumber"] = item.postalNumber as CKRecordValue
        itemRecord["postalName"] = item.postalName as CKRecordValue
        itemRecord["municipalityNumber"] = item.municipalityNumber as CKRecordValue
        itemRecord["municipalityName"] = item.municipalityName as CKRecordValue
        itemRecord["category"] = item.category as CKRecordValue
        CKContainer.default().privateCloudDatabase.save(itemRecord) { (record, err) in
            if let err = err {
                completion(.failure(err))
                return
            }
            guard let record = record else {
                completion(.failure(CloudKitHelperError.recordFailure))
                return
            }
            let recordID = record.recordID
            guard let postalNumber = record["postalNumber"] as? String else {
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            guard let postalName = record["postalName"] as? String else {
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            guard let municipalityNumber = record["municipalityNumber"] as? String else {
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            guard let municipalityName = record["municipalityName"] as? String else {
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            guard let category = record["category"] as? String else {
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            let postNummer = PostNummer(recordID: recordID,
                                        postalNumber: postalNumber,
                                        postalName: postalName,
                                        municipalityNumber: municipalityNumber,
                                        municipalityName: municipalityName,
                                        category: category)
            
            completion(.success(postNummer))
        }
    }
    
    // MARK: - fetching from CloudKit
    static func fetchPostNummer(predicate:  NSPredicate, completion: @escaping (Result<PostNummer, Error>) -> ()) {
        let query = CKQuery(recordType: RecordType.PostNummer, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["postalNumber",
                                 "postalName",
                                 "municipalityNumber",
                                 "municipalityName",
                                 "category"]
        operation.resultsLimit = 3000
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                guard let postalNumber  = record["postalNumber"] as? String else { return }
                guard let postalName = record["postalName"] as? String else { return }
                guard let municipalityNumber = record["municipalityNumber"] as? String else { return }
                guard let municipalityName = record["municipalityName"] as? String else { return }
                guard let category = record["category"] as? String else { return }
                let postNummer = PostNummer(recordID: recordID,
                                            postalNumber: postalNumber,
                                            postalName: postalName,
                                            municipalityNumber: municipalityNumber,
                                            municipalityName: municipalityName,
                                            category: category)
                completion(.success(postNummer))
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
    
    // MARK: - delete from CloudKit
    static func deletePostNummer(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
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
    
    // MARK: - delete all PostNummer from CloudKit
    static func deleteAllPostNummer() {
        let privateDb =  CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "PostNummer", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
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


