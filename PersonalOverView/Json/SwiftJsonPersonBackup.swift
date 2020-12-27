//
//  SwiftJsonBackup.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 01/11/2020.
//

import SwiftUI
import CloudKit

struct SwiftJsonPersonBackup: View {
    
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var persons = [Person]()
    @State private var backupJson = NSLocalizedString("Person backup to Json file", comment: "SwiftJsonBackup")
    
    let jsonFile = "PersonalBackup.json"
    
    var body: some View {
        LazyVStack {
            Text("Person backup to Json file")
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
        .navigationBarTitle(Text(backupJson), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    writeJsonPersonBackup()
                                    /// sleep() takes secons
                                    /// sleep(4)
                                    /// usleep() takes millionths of a second
                                    /// usleep(1)
                                }, label: {
                                    Text(NSLocalizedString("Backup", comment: "SwiftJsonBackup"))
                                        .font(Font.headline.weight(.light))
                                })
        )
        .onAppear {
            refreshPerson()
        }
    }
    
    func refreshPerson() {
        /// Sletter alt tidligere innhold i person
        persons.removeAll()
        /// Fetch all persons from CloudKit
        let predicate = NSPredicate(value: true)
        CloudKitPerson.fetchPerson(predicate: predicate)  { (result) in
            switch result {
            case .success(let person):
                persons.append(person)
                persons.sort(by: {$0.firstName < $1.firstName})
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
    
    func writeJsonPersonBackup() {
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
        savePersonToJasonFile(url: url)
    }
    
    func savePersonToJasonFile(url: URL) {
        var index = -1
        var str = ""
        
        /// Resetter innholdet Json filen
        do {
            let str = ""
            try str.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            let _ = error.localizedDescription
        }
        
        if persons.count > 0 {
            /// Lagrer personene i Json filen
            for person in persons {
                index += 1
                do {
                    if index == 0 {
                        let fileHandle = try FileHandle(forWritingTo: url)
                        if persons.count == 1 {
                            str = "[\n" + formatJsonPerson(person: person)
                        } else {
                            str = "[\n" + formatJsonPerson(person: person) + ","
                        }
                        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                        if persons.count == 1 {
                            let fileHandle = try FileHandle(forWritingTo: url)
                            let str = "\n]"
                            let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(data)
                            fileHandle.closeFile()
                        }
                    } else if index == (persons.count - 1) {
                        let fileHandle = try FileHandle(forWritingTo: url)
                        let str = "\n" + formatJsonPerson(person: person) + "\n]"
                        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    } else {
                        let fileHandle = try FileHandle(forWritingTo: url)
                        let str = "\n" + formatJsonPerson(person: person) + ","
                        let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(data)
                        fileHandle.closeFile()
                    }
                } catch {
                    let _ = error.localizedDescription 
                }
                message = NSLocalizedString("Finished backup of all persons to the Json file.", comment: "savePersonToJasonFile")
                alertIdentifier = AlertID(id: .first)
            }
        } else {
            message = NSLocalizedString("The Person table in CloudKit is empty.", comment: "savePersonToJasonFile")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
    func formatJsonPerson(person: Person) -> String {
        var string = ""
        var string1 = ""
        var string2 = ""
        var string3 = ""
        var string4 = ""
        var string5 = ""
        var string6 = ""
        var string7 = ""
        var string8 = ""
        var string9 = ""
        var string10 = ""
        var string11 = ""
        var string12 = ""
        var string13 = ""
        var string14 = ""
        var string15 = ""
        var string16 = ""
        
        /// "\"" + UUID().uuidString + "\"" ----> "79587E0B-A7C2-41AF-B42E-934C223AC456"
        string1 = "\t{\n\t\t" + "\"" + "id" + "\"" + ": " + "\"" + UUID().uuidString + "\"" + " ,"
        string2 = "\n\t\t" + "\"" + "personData" + "\"" + " : {\n\t\t\t"
        string3 = "\"firstName\" : " + "\"" + person.firstName + "\",\n\t\t\t"
        string4 = "\"lastName\" : "  + "\"" + person.lastName  + "\"" + ",\n\t\t\t"
        if person.personEmail.count == 0 {
            string5 = "\"personEmail\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string5 = "\"personEmail\" : " + "\"" + person.personEmail + "\"" + ",\n\t\t\t"
        }
        if person.address.count == 0 {
            string6 = "\"address\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string6 = "\"address\" : " + "\"" + person.address + "\"" + ",\n\t\t\t"
        }
        if person.phoneNumber.count == 0 {
            string7 = "\"phoneNumber\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string7 = "\"phoneNumber\" : " + "\"" + person.phoneNumber + "\"" + ",\n\t\t\t"
        }
        if person.cityNumber.count == 0 {
            string8 = "\"cityNumber\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string8 = "\"cityNumber\" : " + "\"" + person.cityNumber + "\"" + ",\n\t\t\t"
        }
        if person.city.count == 0 {
            string9 = "\"city\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string9 = "\"city\" : " + "\"" + person.city + "\"" + ",\n\t\t\t"
        }
        if person.municipalityNumber.count == 0 {
            string10 = "\"municipalityNumber\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string10 = "\"municipalityNumber\" : " + "\"" + person.municipalityNumber + "\"" + ",\n\t\t\t"
        }
        if person.municipality.count == 0 {
            string11 = "\"municipality\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string11 = "\"municipality\" : " + "\"" + person.municipality + "\"" + ",\n\t\t\t"
        }
        string12 = "\"dateOfBirth\" : " + "\"" + "\(person.dateOfBirth as Any)" + "\"" + ",\n\t\t\t"
        if person.dateMonthDay.count == 0 {
            string13 = "\"dateMonthDay\" : " + "\"" + " " + "\"" + ",\n\t\t\t"
        } else {
            string13 = "\"dateMonthDay\" : " + "\"" + person.dateMonthDay + "\"" + ",\n\t\t\t"
        }
        string14 = "\"gender\" : " + "\(person.gender as Any)" + ",\n\t\t\t"
        
        if person.image == nil {
            string15 = "\"image\" : " + "\"" + " " + "\"" + "\n\t\t}"
        } else {
            string15 = "\"image\" : " + "\"" + "\(person.image! as UIImage)"  + "\"" + "\n\t\t}"
        }
        string16 = "\n\t}"
        string = string1 + string2 + string3 + string4 + string5 + string6 + string7 + string8 + string9 + string10 + string11 + string12 + string13 + string14 + string15 + string16
        return string
    }
    
}
