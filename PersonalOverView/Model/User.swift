//
//  User.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 21/09/2020.
//

import SwiftUI
import CloudKit

class User: ObservableObject {
    @Published var recordID: CKRecord.ID?
    @Published var name = "Jan Hovland"
    @Published var email = "jan.hovland@lyse.net"
    @Published var password = "qwerty"
    @Published var image: UIImage?
}


