//
//  UserRecord.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

import SwiftUI
import CloudKit

struct UserRecord: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var name: String
    var email: String
    var password: String
    var image: UIImage?
}


