//
//  SwiftJsonUserBackup.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI

/// Sjekke json: https://jsonformatter.curiousconcept.com/#

struct SwiftJsonUserBackup: View {
    
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var users = [UserRecord]()
    @State private var backupJsonUser = NSLocalizedString("User backup til Json fil", comment: "SwiftJsonUserBackup")
    @Environment(\.presentationMode) var presentationMode
    
    let jsonFile = "UserBackup.json"
    
    var body: some View {
        LazyVStack {
            Text("User backup til Json fil")
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(message))
            case .third:
                return Alert(title: Text(message))
            }
        }
        .navigationBarTitle(Text(backupJsonUser), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    DispatchQueue.global().async {
                                        writeJsonUserBackup()
                                        /// sleep() takes secons
                                        /// sleep(4)
                                        /// usleep() takes millionths of a second
                                        usleep(1)
                                    }
                                }, label: {
                                    Text(NSLocalizedString("Backup", comment: "SwiftJsonUserBackup"))
                                        .font(Font.headline.weight(.light))
                                })
        )
        .onAppear {
            refreshUser()
        }
    }
    
    func refreshUser() {
        /// Sletter alt tidligere innhold i person
        users.removeAll()
        /// Fetch all users from CloudKit
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
    
    func getDocumentsDirectory() -> URL {
        /// Find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        /// Just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func writeJsonUserBackup() {
        /// Opprette en fil i Document directory
        /// https://www.hackingwithswift.com/books/ios-swiftui/writing-data-to-the-documents-directory
        /// For å få tak i filen som blir opprette og kunne se denne i "Filer" på iPhone:
        ///     Legg til disse i Info.plist:
        ///     Application supports iTunes file sharing     YES
        ///     Supports opening documents in place        YES
        ///
        /// Dersom en skriver ut "", blankes innholdet ut.
        ///
        let url = getDocumentsDirectory().appendingPathComponent(jsonFile)
        saveUsertToJasonFile(url: url)
    }
    
    func saveUsertToJasonFile(url: URL) {
        var index = -1
        var str = ""
        
        /// Resetter innholdet Json filen
        do {
            let str = ""
            try str.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            let _ = error.localizedDescription
        }
        
        if users.count > 0 {
            /// Lagrer personene i Json filen
            for user in users {
                index += 1
                do {
                    if index == 0 {
                        let fileHandle = try FileHandle(forWritingTo: url)
                        if users.count == 1 {
                            str = "[\n" + formatJsonUser(user: user)
                        }
                        else {
                            str = "[\n" + formatJsonUser(user: user) + ","
                        }
                        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                        if users.count == 1 {
                            let fileHandle = try FileHandle(forWritingTo: url)
                            let str = "\n]"
                            let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    } else if index == (users.count - 1) {
                        let fileHandle = try FileHandle(forWritingTo: url)
                        let str = "\n" + formatJsonUser(user: user) + "\n]"
                        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    } else {
                        let fileHandle = try FileHandle(forWritingTo: url)
                        let str = "\n" + formatJsonUser(user: user) + ","
                        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } catch {
                    let _ = error.localizedDescription 
                }
                message = NSLocalizedString("Finished backup of all users to the Json file.", comment: "saveUsertToJasonFile")
                alertIdentifier = AlertID(id: .first)
            }
        } else {
            message = NSLocalizedString("The User table in CloudKit is empty.", comment: "saveUsertToJasonFile")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
    func formatJsonUser(user: UserRecord) -> String {
        var string = ""
        var string1 = ""
        var string2 = ""
        var string3 = ""
        var string4 = ""
        var string5 = ""
        var string6 = ""
        var string7 = ""
        
        /// "\"" + UUID().uuidString + "\"" ----> "79587E0B-A7C2-41AF-B42E-934C223AC456"
        string1 = "\t{\n\t\t" + "\"" + "id" + "\"" + ": " + "\"" + UUID().uuidString + "\"" + " ,"
        string2 = "\n\t\t" + "\"" + "userData" + "\"" + " : {\n\t\t\t"
        string3 = "\"name\" : " + "\"" + user.name + "\",\n\t\t\t"
        if user.email.count == 0 {
            string4 = "\"email\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string4 = "\"email\" : " + "\"" + user.email + "\"" + ",\n\t\t\t"
        }
        if user.password.count == 0 {
            string5 = "\"password\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string5 = "\"password\" : " + "\"" + user.password + "\"" + ",\n\t\t\t"
        }
        if user.image == nil {
            string6 = "\"image\" : " + "\"" + " " + "\"" + "\n\t\t}"
        } else {
            string6 = "\"image\" : " + "\"" + "\(user.image! as UIImage)"  + "\"" + "\n\t\t}"
        }
        string7 = "\n\t}"
        string = string1 + string2 + string3 + string4 + string5 + string6 + string7
        return string
    }
    
}
