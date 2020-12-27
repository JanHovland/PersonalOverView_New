//
//  SwiftReadCloudKitSaveCloudKitUser.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI
import CloudKit

/// Sjekke json: https://jsonformatter.curiousconcept.com/#

// MARK: - UserRec
struct UserRec : Codable, Identifiable {
    var id: String
    var userData: UserDat
}

// MARK: - UserDat
struct UserDat: Codable {
    var name : String
    var email : String
    var password : String
    var image : String
}

struct SwiftReadCloudKitSaveCloudKitUser: View {
    
    @State private var users = [UserRecord]()
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var saveNumber: Int = 0
    @State private var saveCloudKit = NSLocalizedString("CloudKit save Users", comment: "SwiftReadCloudKitSaveCloudKitUser")
    @State private var indicatorShowing = false
    
    let jsonUserFile = "UserBackup.json"
    
    @State var userRec : [UserRec] = []
    
    var body: some View {
        VStack {
            Image(systemName: "person.2.circle")
                .resizable()
                .frame(width: 80, height: 80, alignment: .center)
                .font(Font.title.weight(.ultraLight))
                .padding(.top, 30)
            ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
            /// Ved å bruke Spacer() her. vil teksten nedenfor vises på bunnen av skjermen
            /// https://www.cometchat.com/tutorials/your-first-swiftui-screen-2-7
            Spacer()
            Text(NSLocalizedString("Press the 'Save' button to save Users from a Json file", comment: "SwiftReadCloudKitSaveCloudKitUser"))
                .padding(.leading, 50)
                .padding(.trailing, 50)
                .padding(.bottom, 50)
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(message))
            case .third:
                return Alert(title: Text(title),
                             message: Text(message),
                             primaryButton: .destructive(Text(choise),
                                                         action: {
                                                            /// Starte ActivityIndicator
                                                            indicatorShowing = true
                                                            importUserDataFromCloudKitJson()
                                                            /// Stoppe ActivityIndicator
                                                            indicatorShowing = false
                                                            message = result
                                                            alertIdentifier = AlertID(id: .first)
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "SwiftReadCloudKitSaveCloudKitUser"))))
            }
        }
        .navigationBarTitle(Text(saveCloudKit), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    /// Legg merke til at det testes på om det er flere brukere i User tabellen.
                                    /// Er tabellen tom, kan det ikke testes på 0 fordi user.count ikke er tilgjengelig
                                    if users.count > 0 {
                                        message = NSLocalizedString("The User table contains data. You must first delete all users from the User table.", comment: "SwiftReadCloudKitSaveCloudKitUser")
                                        alertIdentifier = AlertID(id: .first)
                                    } else {
                                        if UserDefaults.standard.string(forKey: "jsonUserOptionSelected") == "Aktivert" {
                                            title = NSLocalizedString("1 CloudKit save Users", comment: "SwiftReadCloudKitSaveCloudKitUser")
                                            message = NSLocalizedString("Are you sure you want to save all users from a Json file?", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            choise = NSLocalizedString("2 Save Users", comment: "SwiftReadCloudKitSaveCloudKitUser")
                                            result = NSLocalizedString("All users are saved.", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            alertIdentifier = AlertID(id: .third)
                                        } else {
                                            let message1 = NSLocalizedString("You must activate the ", comment: "SwiftReadCloudKitSaveCloudKitUser")
                                            let message2 = NSLocalizedString("CloudKit save Users option", comment: "SwiftDeleteAlSwiftReadCloudKitSaveCloudKitPersonlPersons")
                                            let message3 = NSLocalizedString("to be able to save all Users in CloudKit.", comment: "SwiftReadCloudKitSaveCloudKitUser")
                                            message = message1 + "\"" + message2 + "\" " + message3
                                            alertIdentifier = AlertID(id: .first)
                                        }
                                    }
                                }, label: {
                                    Text(NSLocalizedString("Update", comment: "SwiftReadCloudKitSaveCloudKitUser"))
                                        .font(Font.headline.weight(.light))
                                })
        )
        .onAppear {
            parseUserJson()
        }
    }
    
    func parseUserJson() {
        if let url = Bundle.main.url(forResource: jsonUserFile, withExtension: nil) {
            if let data = try? Data(contentsOf: url){
                let jsondecoder = JSONDecoder()
                do{
                    let result = try jsondecoder.decode([UserRec].self, from: data)
                    self.userRec = result
                }
                catch {
                    message = NSLocalizedString("Error trying parse json", comment: "parseUserJson")
                    alertIdentifier = AlertID(id: .first)
                }
            }
        } else {
            message =  NSLocalizedString("Unknown json file", comment: "parseUserJson")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
    func importUserDataFromCloudKitJson() {
        var recordID: CKRecord.ID?
        
        for index in 0..<userRec.count {
            let user = UserRecord(
                name: userRec[index].userData.name,
                email: userRec[index].userData.email,
                password: userRec[index].userData.password,
                image: nil)
            /// Sjekk om brukeren finnes
            CloudKitUser.doesUserExist(email: userRec[index].userData.email,
                                       password: userRec[index].userData.password) { (result) in
                /// Brukeren finne ikke i User tabellen
                if result != "OK" {
                    /// Lagre en ny bruker
                    CloudKitUser.saveUser(item: user) { (result) in
                        switch result {
                        case .success:
                            let _ = result
                        case .failure(let err):
                            message = err.localizedDescription
                            alertIdentifier = AlertID(id: .first)
                        }
                    }
                } else {
                    /// Brukeren finnes fra før i User tabellen
                    /// Må finne recordID for den enkelte brukeren
                    let predicate = NSPredicate(format: "email == %@ AND password = %@", userRec[index].userData.email,
                                                userRec[index].userData.password)
                    CloudKitUser.fetchUser(predicate: predicate)  { (result) in
                        switch result {
                        case .success(let user):
                            /// Her finnes recordID
                            recordID = user.recordID
                            let user = UserRecord(
                                recordID: recordID,
                                name: userRec[index].userData.name,
                                email: userRec[index].userData.email,
                                password: userRec[index].userData.password,
                                image: nil)
                            /// Oppdatere brukeren
                            CloudKitUser.modifyUser(item: user) { (result) in
                                switch result {
                                case .success(let res):
                                    let _ = res
                                case .failure(let err):
                                    message = err.localizedDescription
                                    alertIdentifier = AlertID(id: .first)
                                }
                            }
                        case .failure(let err):
                            message = err.localizedDescription
                            alertIdentifier = AlertID(id: .first)
                        }
                    }
                }
            }
        }
    }
    
    func countUsers() {
        /// Sletter alt tidligere innhold i User tabellen
        users.removeAll()
        /// Fetch all persons from CloudKit
        let predicate = NSPredicate(value: true)
        CloudKitUser.fetchUser(predicate: predicate)  { (result) in
            switch result {
            case .success(let user):
                users.append(user)
                users.sort(by: {$0.name < $1.name})
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }
    
}






















