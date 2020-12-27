//
//  CloudKitPerson.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/10/2020.
//

//  Block comment : Ctrl + Cmd + / (on number pad)
//  Indent        : Ctrl + Cmd + * (on number pad)

import CloudKit
import SwiftUI

struct CloudKitPerson {
    struct RecordType {
        static let Person = "Person"
    }
    /// MARK: - errors
    enum CloudKitHelperError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    /// MARK: - saving to CloudKit
    static func savePerson(item: Person, completion: @escaping (Result<Person, Error>) -> ()) {
        let itemRecord = CKRecord(recordType: RecordType.Person)
        itemRecord["firstName"] = item.firstName as CKRecordValue
        itemRecord["lastName"] = item.lastName as CKRecordValue
        itemRecord["personEmail"] = item.personEmail as CKRecordValue
        itemRecord["address"] = item.address as CKRecordValue
        itemRecord["phoneNumber"] = item.phoneNumber as CKRecordValue
        itemRecord["cityNumber"] = item.cityNumber as CKRecordValue
        itemRecord["city"] = item.city as CKRecordValue
        itemRecord["municipalityNumber"] = item.municipalityNumber as CKRecordValue
        itemRecord["municipality"] = item.municipality as CKRecordValue
        itemRecord["dateOfBirth"] = item.dateOfBirth as CKRecordValue
        itemRecord["dateMonthDay"] = monthDay(date: item.dateOfBirth) as CKRecordValue
        itemRecord["gender"] = item.gender as CKRecordValue
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
                guard let firstName = record["firstName"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let lastName = record["lastName"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let personEmail = record["personEmail"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let address = record["address"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let phoneNumber = record["phoneNumber"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let cityNumber = record["cityNumber"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let city = record["city"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let municipalityNumber = record["municipalityNumber"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let municipality = record["municipality"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let dateOfBirth = record["dateOfBirth"] as? Date else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let dateMonthDay = record["dateMonthDay"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let gender = record["gender"] as? Int else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                /// MARK: - "image" kan være nil, dersom det ikke er valgt noe bilde
                /// guard (record["image"] as? CKAsset) != nil else {
                ///     completion(.failure(CloudKitHelperError.castFailure))
                ///     return
                /// }
                let person = Person(recordID: recordID,
                                    firstName: firstName,
                                    lastName: lastName,
                                    personEmail: personEmail,
                                    address: address,
                                    phoneNumber: phoneNumber,
                                    cityNumber: cityNumber,
                                    city: city,
                                    municipalityNumber: municipalityNumber,
                                    municipality: municipality,
                                    dateOfBirth: dateOfBirth,
                                    dateMonthDay: dateMonthDay,
                                    gender: gender)
                
                completion(.success(person))
            }
        }
    }
    
    // MARK: - check if the person record exists
    static func doesPersonExist(firstName: String,
                                lastName: String,
                                completion: @escaping (Bool) -> ()) {
        var result = false
        let predicate = NSPredicate(format: "firstName == %@ AND lastName = %@", firstName, lastName)
        let query = CKQuery(recordType: RecordType.Person, predicate: predicate)
        /// inZoneWith: nil : Specify nil to search the default zone of the database.
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, er) in
            DispatchQueue.main.async {
                result = false
                if results != nil {
                    if results!.count >= 1 {
                        result = true
                    }
                }
                completion(result)
            }
        })
    }
    
    // MARK: - fetching from CloudKit
    static func fetchPerson(predicate:  NSPredicate, completion: @escaping (Result<Person, Error>) -> ()) {
        
        let sort1 = NSSortDescriptor(key: "firstName", ascending: true)
        let sort2 = NSSortDescriptor(key: "lastName", ascending: true)
        let query = CKQuery(recordType: RecordType.Person, predicate: predicate)
        query.sortDescriptors = [sort1, sort2]
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["firstName",
                                 "lastName",
                                 "personEmail",
                                 "address",
                                 "phoneNumber",
                                 "cityNumber",
                                 "city",
                                 "municipalityNumber",
                                 "municipality",
                                 "dateOfBirth",
                                 "dateMonthDay",
                                 "gender",
                                 "image"]
        operation.resultsLimit = 500
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                /// Dersom en oppretter poster i Person tabellen i CloudKit Dashboard og det ikke legges inn verdier,
                /// vil feltene  fra Person tabellen være tomme dvs. nil
                if record["firstName"] == nil { record["firstName"] = "" }
                if record["lastName"] == nil  { record["lastName"] = "" }
                if record["personEmail"] == nil { record["personEmail"] = "" }
                if record["address"] == nil { record["address"] = "" }
                if record["phoneNumber"] == nil { record["phoneNumber"] = "" }
                if record["cityNumber"] == nil { record["cityNumber"] = "" }
                if record["city"] == nil { record["city"] = "" }
                if record["municipalityNumber"] == nil { record["municipalityNumber"] = "" }
                if record["municipality"] == nil { record["municipality"] = "" }
                if record["dateOfBirth"] == nil { record["dateOfBirth"] = Date() }
                if record["gender"] == nil { record["gender"] = 0 }
                
                guard let firstName  = record["firstName"] as? String else { return }
                guard let lastName = record["lastName"] as? String else { return }
                guard let personEmail = record["personEmail"] as? String else { return }
                guard let address = record["address"] as? String else { return }
                guard let phoneNumber = record["phoneNumber"] as? String else { return }
                guard let cityNumber = record["cityNumber"] as? String else { return }
                guard let city = record["city"] as? String else { return }
                guard let municipalityNumber = record["municipalityNumber"] as? String else { return }
                guard let municipality = record["municipality"] as? String else { return }
                guard let dateOfBirth = record["dateOfBirth"] as? Date else { return }
                let dateMonthDay = monthDay(date: dateOfBirth)
                guard let gender = record["gender"] as? Int else { return }
                if let image = record["image"], let imageAsset = image as? CKAsset {
                    if let imageData = try? Data.init(contentsOf: imageAsset.fileURL!) {
                        let image = UIImage(data: imageData)
                        let person = Person(recordID: recordID,
                                            firstName: firstName,
                                            lastName: lastName,
                                            personEmail: personEmail,
                                            address: address,
                                            phoneNumber: phoneNumber,
                                            cityNumber: cityNumber,
                                            city: city,
                                            municipalityNumber: municipalityNumber,
                                            municipality: municipality,
                                            dateOfBirth: dateOfBirth,
                                            dateMonthDay: dateMonthDay,
                                            gender: gender,
                                            image: image)
                        completion(.success(person))
                    }
                }
                else {
                    let person = Person(recordID: recordID,
                                        firstName: firstName,
                                        lastName: lastName,
                                        personEmail: personEmail,
                                        address: address,
                                        phoneNumber: phoneNumber,
                                        cityNumber: cityNumber,
                                        city: city,
                                        municipalityNumber: municipalityNumber,
                                        municipality: municipality,
                                        dateOfBirth: dateOfBirth,
                                        dateMonthDay: dateMonthDay,
                                        gender: gender,
                                        image: nil)
                    completion(.success(person))
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
    
    // MARK: - delete person from CloudKit
    static func deletePerson(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
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
    static func modifyPerson(item: Person, completion: @escaping (Result<Person, Error>) -> ()) {
        guard let recordID = item.recordID else { return }
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) {
            record, err in
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
            record["firstName"] = item.firstName as CKRecordValue
            record["lastName"] = item.lastName as CKRecordValue
            record["personEmail"] = item.personEmail as CKRecordValue
            record["address"] = item.address as CKRecordValue
            record["phoneNumber"] = item.phoneNumber as CKRecordValue
            record["cityNumber"] = item.cityNumber as CKRecordValue
            record["city"] = item.city as CKRecordValue
            record["municipalityNumber"] = item.municipalityNumber as CKRecordValue
            record["municipality"] = item.municipality as CKRecordValue
            record["dateOfBirth"] = item.dateOfBirth as CKRecordValue
            record["dateMonthDay"] = monthDay(date: item.dateOfBirth) as CKRecordValue
            record["gender"] = item.gender as CKRecordValue
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
                    guard let firstName = record["firstName"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let lastName = record["lastName"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let personEmail = record["personEmail"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let address = record["address"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let phoneNumber = record["phoneNumber"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let cityNumber = record["cityNumber"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let city = record["city"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let municipalityNumber = record["municipalityNumber"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let municipality = record["municipality"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let dateOfBirth = record["dateOfBirth"] as? Date else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let dateMonthDay = record["dateMonthDay"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let gender = record["gender"] as? Int else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    let person = Person(recordID: recordID,
                                        firstName: firstName,
                                        lastName: lastName,
                                        personEmail: personEmail,
                                        address: address,
                                        phoneNumber: phoneNumber,
                                        cityNumber: cityNumber,
                                        city: city,
                                        municipalityNumber: municipalityNumber,
                                        municipality: municipality,
                                        dateOfBirth: dateOfBirth,
                                        dateMonthDay: dateMonthDay,
                                        gender: gender)
                    
                    completion(.success(person))
                }
            }
        }
    }
    
    // MARK: - delete all Persons from CloudKit
    static func deleteAllPersons() {
        
        let privateDb =  CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Person", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        var counter = 0
        DispatchQueue.main.async {
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
                    let _ = NSLocalizedString("Records deleted:", comment: "SettingView")
                } else {
                    let _ = error!.localizedDescription
                }
            }
        }
    }

}


