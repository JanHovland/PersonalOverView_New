//
//  SwiftReadCloudKitSaveCloudKit.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 11/11/2020.
//

import SwiftUI
import CloudKit

/// Sjekke json: https://jsonformatter.curiousconcept.com/#

// MARK: - PersonElem
struct PersonElem : Codable, Identifiable {
    var id: String
    var personData: PersonDat
}

// MARK: - PersonDat
struct PersonDat: Codable {
    var firstName : String
    var lastName : String
    var personEmail : String
    var address : String
    var phoneNumber : String
    var cityNumber : String
    var city : String
    var municipalityNumber : String
    var municipality : String
    var dateOfBirth : String
    var dateMonthDay : String
    var gender : Int
    var image : String
}

struct
SwiftReadCloudKitSaveCloudKitPerson: View {
    
    @State private var persons = [Person]()
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var saveNumber: Int = 0
    @State private var tmpFirstName: String = ""
    @State private var saveCloudKit = NSLocalizedString("CloudKit save Persons", comment: "SwiftReadCloudKitSaveCloudKit")
    @State private var indicatorShowing = false
    
    let jsonPersonFile = "PersonalBackup.json"
    
    @State var personElem : [PersonElem] = []
    
    var body: some View{
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
            Text(NSLocalizedString("Press the 'Save' button to save Persons from a Json file", comment: "SwiftDeleteAllPersons"))
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
                                                            importPersonDataFromCloudKitJson()
                                                            /// Stoppe ActivityIndicator
                                                            indicatorShowing = false
                                                            message = result
                                                            alertIdentifier = AlertID(id: .first)
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "PersonsOverView"))))
            }
        }
        .navigationBarTitle(Text(saveCloudKit), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    /// Legg merke til at det testes på om det er flere personer i Person tabelle.
                                    /// Er tabellen tom, kan det ikke testes på 0 fordi persons.count ikke er tilgjengelig
                                    if persons.count > 0 {
                                        message = NSLocalizedString("The Person table contains data. You must first delete all persons from the Person table.", comment: "SwiftReadFireBaseSaveJson")
                                        alertIdentifier = AlertID(id: .first)
                                    } else {
                                        if UserDefaults.standard.string(forKey: "jsonPersonOptionSelected") == "Aktivert" {
                                            title = NSLocalizedString("1 CloudKit save Persons", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            message = NSLocalizedString("Are you sure you want to save all persons from a Json file?", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            choise = NSLocalizedString("2 Save Persons", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            result = NSLocalizedString("All persons are saved.", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            alertIdentifier = AlertID(id: .third)
                                        } else {
                                            let message1 = NSLocalizedString("You must activate the ", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            let message2 = NSLocalizedString("CloudKit save Persons option", comment: "SwiftDeleteAlSwiftReadCloudKitSaveCloudKitPersonlPersons")
                                            let message3 = NSLocalizedString("to be able to save all Persons in CloudKit.", comment: "SwiftReadCloudKitSaveCloudKitPerson")
                                            message = message1 + "\"'" + message2 + "\" " + message3
                                            alertIdentifier = AlertID(id: .first)
                                        }
                                    }
                                }, label: {
                                    Text(NSLocalizedString("Update", comment: "SwiftDeleteAllPersons"))
                                        .font(Font.headline.weight(.light))
                                })
        )
        .onAppear {
            parsePersonJson()
        }
    }
    
    func countPersons() {
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
    
    func parsePersonJson()  {
        if let url = Bundle.main.url(forResource: jsonPersonFile, withExtension: nil) {
            if let data = try? Data(contentsOf: url){
                let jsondecoder = JSONDecoder()
                do{
                    let result = try jsondecoder.decode([PersonElem].self, from: data)
                    self.personElem = result
                }
                catch {
                    message = NSLocalizedString("Error trying parse json", comment: "parseJson")
                    alertIdentifier = AlertID(id: .first)
                }
            }
        } else {
            message =  NSLocalizedString("Unknown json file", comment: "parseJson")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
    /// "29. 05 1977" -> 1977-05-29 00:00:00 +0000
    /// Månedene må være på engelsk
    
    /// Dato formateringer:
    /// Wednesday, Feb 26, 2020                EEEE, MMM d, yyyy
    /// 02/26/2020                                        MM/dd/yyyy
    /// 02-26-2020 12:30                              MM-dd-yyyy HH:mm
    /// Feb 26, 12:30 PM                              MMM d, h:mm a
    /// February 2020                                   MMMM yyyy
    /// Feb 26, 2020                                      MMM d, yyyy
    /// Wed, 26 Feb 2020 12:30:24 +0000    E, d MMM yyyy HH:mm:ss Z
    /// 2020-02-26T12:30:24+0000               yyyy-MM-dd'T'HH:mm:ssZ
    /// 26.02.20                                             dd.MM.yy
    /// 12:30:24.423                                      HH:mm:ss.SSS
    func convertStringToDate(dateIn: String) -> Date {
        let formatter = DateFormatter()
        ///                     2005-12-14 00:00:00 +0000
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateIn)!
    }
    
    /// Rutine for å legge til en person fra JSON tilen til CloudKit
    /// Denne rutinen må kun kunne kjøres en gang,
    /// Sjekker derfor om en person finnes fra før.
    
    func importPersonDataFromCloudKitJson() {
        var recordID: CKRecord.ID?
        
        for index in 0..<personElem.count {
            let person = Person(
                firstName: personElem[index].personData.firstName,
                lastName: personElem[index].personData.lastName,
                personEmail: personElem[index].personData.personEmail,
                address: personElem[index].personData.address,
                phoneNumber: personElem[index].personData.phoneNumber,
                cityNumber: personElem[index].personData.cityNumber,
                city: personElem[index].personData.city,
                municipalityNumber: personElem[index].personData.municipalityNumber,
                municipality: personElem[index].personData.municipality,
                dateOfBirth:  convertStringToDate(dateIn: personElem[index].personData.dateOfBirth),
                dateMonthDay: personElem[index].personData.dateMonthDay,
                gender: personElem[index].personData.gender,
                image: nil)
            /// Sjekk om brukeren finnes
            CloudKitPerson.doesPersonExist(firstName: personElem[index].personData.firstName,
                                           lastName: personElem[index].personData.lastName) {
                (result) in
                /// Personen finnes ikke i Person tabellen
                if result == false {
                    CloudKitPerson.savePerson(item: person) { (res) in
                        switch res {
                        case .success:
                            let _ = res
                        case .failure(let err):
                            message = err.localizedDescription
                            alertIdentifier = AlertID(id: .second)
                        }
                    }
                } else {
                    /// Personen finnes i Person tabellen
                    /// Må finne recordID for den enkelte personen
                    let predicate = NSPredicate(format: "firstName == %@ AND lastName = %@", personElem[index].personData.firstName, personElem[index].personData.lastName)
                    CloudKitPerson.fetchPerson(predicate: predicate)  { (result) in
                        switch result {
                        /// Finne recordID for å kunne oppdatere personen
                        case .success(let person):
                            recordID = person.recordID
                            let person = Person(
                                recordID: recordID,
                                firstName: personElem[index].personData.firstName,
                                lastName: personElem[index].personData.lastName,
                                personEmail: personElem[index].personData.personEmail,
                                address: personElem[index].personData.address,
                                phoneNumber: personElem[index].personData.phoneNumber,
                                cityNumber: personElem[index].personData.cityNumber,
                                city: personElem[index].personData.city,
                                municipalityNumber: personElem[index].personData.municipalityNumber,
                                municipality: personElem[index].personData.municipality,
                                dateOfBirth:  convertStringToDate(dateIn: personElem[index].personData.dateOfBirth),
                                dateMonthDay: personElem[index].personData.dateMonthDay,
                                gender: personElem[index].personData.gender,
                                image: nil)
                            /// Oppdatere personen
                            CloudKitPerson.modifyPerson(item: person) { (res) in
                                switch res {
                                case .success:
                                    let _ = res
                                case .failure(let err):
                                    message = err.localizedDescription
                                    alertIdentifier = AlertID(id: .second)
                                }
                            }
                        case .failure(let err):
                            let _ = err.localizedDescription 
                        }
                    }
                }
            }
        }
    }
}

