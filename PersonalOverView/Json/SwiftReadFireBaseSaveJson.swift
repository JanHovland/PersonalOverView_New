//
//  SwiftReadFireBaseSaveJson.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 26/10/2020.
//

import SwiftUI
import CloudKit

/// Sjekke json: https://jsonformatter.curiousconcept.com/#

// MARK: - PersonElement
struct PersonElement: Codable, Identifiable {
    var id: String
    var author: Author
    var personData: PersonData
    var timestamp: Int64
}

// MARK: - Author
struct Author:Codable {
    var email: String
    var photoURL: String
    var uid: String
    var username: String
}

// MARK: - PersonData
struct PersonData:Codable {
    var address: String
    var city: String
    var dateOfBirth1: String
    var dateOfBirth2: String
    var firstName: String
    var gender: Int
    var lastName: String
    var municipality: String
    var municipalityNumber: String
    var name: String
    var personEmail: String
    var phoneNumber: String
    var photoURL: String
    var postalCodeNumber: String
}

struct SwiftReadFireBaseSaveJson: View {
    
    @State private var persons = [Person]()
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var saveNumber: Int = 0
    @State private var tmpFirstName: String = ""
    @State private var saveCloudKit = NSLocalizedString("Firebase save Persons", comment: "SwiftReadFireBaseSaveJson")
    @State var personElement : [PersonElement] = []
    @State private var indicatorShowing = false

    let jsonFile = "FirebaseData.json"
    
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
            Text(NSLocalizedString("Press the 'Update' button to update Persons from a Json file", comment: "SwiftReadFireBaseSaveJson"))
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
                return Alert(title: Text(message))
            }
        }
        .navigationBarTitle(Text(saveCloudKit), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    /// Starte ActivityIndicator
                                    indicatorShowing = true
                                    findFirebaseUpdate()
                                    /// Stoppe ActivityIndicator
                                    indicatorShowing = false
                                }, label: {
                                    Text(NSLocalizedString("Update", comment: "SwiftReadFireBaseSaveJson"))
                                        .font(Font.headline.weight(.light))
                                })
        )
        .onAppear {
            parseJson()
        }
    }
    
    func parseJson() {
        if let url = Bundle.main.url(forResource: jsonFile, withExtension: nil) {
            if let data = try? Data(contentsOf: url){
                let jsondecoder = JSONDecoder()
                do{
                    let result = try jsondecoder.decode([PersonElement].self, from: data)
                    self.personElement = result
                }
                catch {
                    message = NSLocalizedString("Error trying parse json", comment: "parseJson")
                    alertIdentifier = AlertID(id: .first)
                    return
                }
            }
        } else {
            message =  NSLocalizedString("Unknown json file", comment: "parseJson")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
    /// "29. 05 1977" -> 1977-05-29 00:00:00 +0000
    /// Månedene må være på engelsk
    func convertStringToDate(dateIn: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MM y"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateIn)!
    }
    
    /// Rutine for å legge til en person fra JSON tilen til Firebase
    /// Denne rutinen må kun kunne kjøres en gang,
    /// Sjekker derfor om en person finnes fra før.
    func importPersonDataFromFireBaseJson() {
        
        for index in 0..<personElement.count {
            let date = convertStringToDate(dateIn: personElement[index].personData.dateOfBirth1)
            let person = Person(
                firstName: personElement[index].personData.firstName,
                lastName: personElement[index].personData.lastName,
                personEmail: personElement[index].personData.personEmail,
                address: personElement[index].personData.address,
                phoneNumber: personElement[index].personData.phoneNumber,
                cityNumber: personElement[index].personData.postalCodeNumber,
                city: personElement[index].personData.city,
                municipalityNumber: personElement[index].personData.municipalityNumber,
                municipality: personElement[index].personData.municipality,
                dateOfBirth: date,
                dateMonthDay: personElement[index].personData.dateOfBirth2,
                gender: personElement[index].personData.gender,
                image: nil)
            CloudKitPerson.savePerson(item: person) { (result) in
                switch result {
                case .success:
                    let _ = "Saved"
                case .failure(let err):
                    message = err.localizedDescription
                    alertIdentifier = AlertID(id: .first)
                }
            }
        }
        message = NSLocalizedString("All persons saved from Firebase Json file", comment: "importPersonDataFromFireBaseJson")
        alertIdentifier = AlertID(id: .first)
    }
    
    func findFirebaseUpdate() {
        /// Må bare kjøres en gang
        if UserDefaults.standard.string(forKey: "jsonFirebaseOptionSelected") == "Aktivert" {
            importPersonDataFromFireBaseJson()
        } else {
            let message1 = NSLocalizedString("You must activate the ", comment: "savePersonsCloudKit")
            let message2 = NSLocalizedString("Firebase save Persons option", comment: "savePersonsCloudKit")
            let message3 = NSLocalizedString(" to be able to update the Person table in CloudKit.", comment: "savePersonsCloudKit")
            message = message1 + "\"" + message2 + "\" " + message3
            alertIdentifier = AlertID(id: .first)
        }
    }
    
}

