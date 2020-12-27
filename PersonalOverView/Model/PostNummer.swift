//
//  PostNummer.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 01/10/2020.
//

import SwiftUI
import CloudKit

struct PostNummer: Identifiable {
   var id = UUID()
   var recordID: CKRecord.ID?
   var postalNumber: String = ""
   var postalName: String = ""
   var municipalityNumber: String = ""
   var municipalityName: String = ""
   var category: String = ""
}
