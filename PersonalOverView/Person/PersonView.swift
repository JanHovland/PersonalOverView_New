//
//  PersonView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/10/2020.
//

/// Short cuts made by me:
/// Ctrl + Cmd + / (on number pad)  == Comment or Uncomment
/// Ctrl + Cmd + * (on number pad)  == Indent

import SwiftUI
import CloudKit

struct PersonView : View {
    
    var person: Person
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var recordID: CKRecord.ID?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var personEmail: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var cityNumber: String = ""
    @State private var city: String = ""
    @State private var municipalityNumber: String = ""
    @State private var municipality: String = ""
    @State private var dateOfBirth = Date()
    @State private var gender: Int = 0
    @State private var image: UIImage?
    
    @State private var cityNumberNew: String = ""
    
    var genders = [NSLocalizedString("Man", comment: "PersonView"),
                   NSLocalizedString("Woman", comment: "PersonView")]
    
    var body: some View {
        VStack {
            HStack (alignment: .center, spacing: 50) {
                ZStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .font(Font.title.weight(.ultraLight))
                    if image != nil {
                        Image(uiImage: image!)
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                }
                Button(
                    action: {
                        image_Picker()
                    },
                    label: {
                        HStack {
                            Text(NSLocalizedString("Profile Image", comment: "PersonView"))
                        }
                    }
                )
            }
            .padding(.top, 40)
            .onReceive(ImagePicker.shared.$image) { image in
                self.image = image
            }
            Form {
                InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                               checkPhone: false,
                               secure: false,
                               heading: NSLocalizedString("First name", comment: "PersonView"),
                               placeHolder: NSLocalizedString("Enter your first name", comment: "PersonView"),
                               value: $firstName)
                    
                    .autocapitalization(.words)
                InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                               checkPhone: false,
                               secure: false,
                               heading: NSLocalizedString("Last name", comment: "PersonView"),
                               placeHolder: NSLocalizedString("Enter your last name", comment: "PersonView"),
                               value: $lastName)
                    .autocapitalization(.words)
                InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                               checkPhone: false,
                               secure: false,
                               heading: NSLocalizedString("eMail", comment: "PersonView"),
                               placeHolder: NSLocalizedString("Enter your email address", comment: "PersonView"),
                               value: $personEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                               checkPhone: false,
                               secure: false,
                               heading: NSLocalizedString("Address", comment: "PersonView"),
                               placeHolder: NSLocalizedString("Enter your address", comment: "v"),
                               value: $address)
                    .autocapitalization(.words)
                InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                               checkPhone: true,
                               secure: false,
                               heading: NSLocalizedString("Phone Number", comment: "PersonView"),
                               placeHolder: NSLocalizedString("Enter your phone number", comment: "PersonView"),
                               value: $phoneNumber)
                HStack (alignment: .center, spacing: 0) {
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("Postnummer", comment: "PersonView"),
                                   placeHolder: NSLocalizedString("Legg inn postnummer", comment: "PersonView"),
                                   value: $cityNumber)
                        .keyboardType(.numberPad)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("City", comment: "PersonView"),
                                   placeHolder: NSLocalizedString("Enter city", comment: "PersonView"),
                                   value: $city)
                        .autocapitalization(.words)
                    VStack {
                        Button(action: {
                            person_Postal_Codes_View_Indexed()
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)
                                .foregroundColor(.blue)
                                .font(.title)
                        })
                    }
                }
                HStack (alignment: .center, spacing: 0) {
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("Municipality number", comment: "NewPersonView"),
                                   placeHolder: NSLocalizedString("Enter number", comment: "NewPersonView"),
                                   value: $municipalityNumber)
                        .keyboardType(.numberPad)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("Municipality", comment: "NewPersonView"),
                                   placeHolder: NSLocalizedString("Enter municipality", comment: "NewPersonView"),
                                   value: $municipality)
                        .autocapitalization(.words)
                }
                DatePicker(
                    selection: $dateOfBirth,
                    // in: ...Date(),               /// - Dette gir ubegrenset dato utvalg
                    displayedComponents: [.date],
                    label: {
                        Text(NSLocalizedString("Date of birth", comment: "PersonView"))
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                            .padding(-5)
                    })
                /// Returning an integer 0 == "Man" 1 == "Women
                InputGender(heading: NSLocalizedString("Gender", comment: "PersonView"),
                            genders: genders,
                            value: $gender)
            }
        }
        /// Removes all separators below in the List view
        .listStyle(GroupedListStyle())
        .navigationBarTitle(NSLocalizedString("PersonX", comment: "PersonView"), displayMode:  .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    modifyPerson(recordID: recordID,
                                                 firstName: firstName,
                                                 lastName: lastName,
                                                 personEmail: personEmail,
                                                 address: address,
                                                 phoneNumber: phoneNumber,
                                                 city: city,
                                                 cityNumber: cityNumber,
                                                 municipalityNumber: municipalityNumber,
                                                 municipality: municipality,
                                                 dateOfBirth: dateOfBirth,
                                                 dateMonthDay: monthDay(date: dateOfBirth),
                                                 gender: gender,
                                                 image: image)
                                }, label: {
                                    Text(NSLocalizedString("Modify", comment: "PersonView"))
                                        .font(Font.headline.weight(.light))
                                })
        )
        .onAppear {
            showPerson()
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
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        /// Ta bort tastaturet når en klikker utenfor feltet
        .modifier(DismissingKeyboard())
        /// Flytte opp feltene slik at keyboard ikke skjuler aktuelt felt, men nå krøller feltene seg sammen til en "strek" !!!!!!!!!!!
        /// .modifier(AdaptsToSoftwareKeyboard())
        .onDisappear {
            /// https://stackoverflow.com/questions/60691335/how-to-detect-what-changed-a-published-value-in-swiftui
            /// Lagrer alltid ved retur til oversikt
            /// Legg merke til at det ikke kommer noen melding om at persondata er modifisert, dataene blir lun oppdatert i CloudKit
            modifyPerson(recordID: recordID,
                         firstName: firstName,
                         lastName: lastName,
                         personEmail: personEmail,
                         address: address,
                         phoneNumber: phoneNumber,
                         city: city,
                         cityNumber: cityNumber,
                         municipalityNumber: municipalityNumber,
                         municipality: municipality,
                         dateOfBirth: dateOfBirth,
                         dateMonthDay: monthDay(date: dateOfBirth),
                         gender: gender,
                         image: image)
        }
    }
    
    func showPerson() {
        firstName = person.firstName
        lastName = person.lastName
        let firstName = self.firstName
        let lastName = self.lastName
        let predicate = NSPredicate(format: "firstName == %@ AND lastName == %@", firstName, lastName)
        /// Må finne recordID for å kunne modifisere personen  i  CloudKit
        CloudKitPerson.fetchPerson(predicate: predicate) { (result) in
            switch result {
            case .success(let perItem):
                recordID = perItem.recordID
                self.firstName = perItem.firstName
                self.lastName = perItem.lastName
                personEmail = perItem.personEmail
                address = perItem.address
                phoneNumber = perItem.phoneNumber
                city = perItem.city
                cityNumber = perItem.cityNumber
                cityNumberNew = perItem.cityNumber
                municipalityNumber = perItem.municipalityNumber
                municipality = perItem.municipality
                dateOfBirth = perItem.dateOfBirth
                gender = perItem.gender
                /// Setter image (personens bilde)  til det bildet som er lagret på personen
                image = perItem.image
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }
    
    func modifyPerson(recordID: CKRecord.ID?,
                      firstName: String,
                      lastName: String,
                      personEmail: String,
                      address: String,
                      phoneNumber: String,
                      city: String,
                      cityNumber: String,
                      municipalityNumber: String,
                      municipality: String,
                      dateOfBirth: Date,
                      dateMonthDay: String,
                      gender: Int,
                      image: UIImage?) {
        
        if firstName.count > 0, lastName.count > 0 {
            /// Modify the person in CloudKit
            /// Kan ikke bruke person fordi: Kan ikke inneholde @State private var fordi:  'PersonView' initializer is inaccessible due to 'private' protection level
            var person: Person! = Person()
            person.recordID = recordID
            person.firstName = firstName
            person.lastName = lastName
            person.personEmail = personEmail
            person.address = address
            person.phoneNumber = phoneNumber
            person.city = city
            person.cityNumber = cityNumber
            person.municipalityNumber = municipalityNumber
            person.municipality = municipality
            person.dateOfBirth = dateOfBirth
            person.dateMonthDay = dateMonthDay
            person.gender = gender
            /// Først vises det gamle bildet til personen, så kommer det nye bildet opp
            if image != nil {
                person.image = image
            }
            CloudKitPerson.modifyPerson(item: person) { (result) in
                switch result {
                case .success:
                    let person = "'\(person.firstName)" + " \(person.lastName)'"
                    let message1 =  NSLocalizedString("was modified", comment: "PersonView")
                    message = person + " " + message1
                    alertIdentifier = AlertID(id: .second)
                case .failure(let err):
                    message = err.localizedDescription
                    alertIdentifier = AlertID(id: .second)
                }
            }
        }
        else {
            message = NSLocalizedString("First name and last name must both contain a value.", comment: "PersonView")
            alertIdentifier = AlertID(id: .first)
        }
        
    }
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .imagePicker {
            ImagePicker.shared.view
        } else if sheet.state == .postNummer {
            FindPostNummer(city: city,
                           cityNumber: $cityNumber,
                           municipalityNumber: $municipalityNumber,
                           municipality: $municipality)
        } else if sheet.state == .postNummerIndexed {
            PersonFindPostalCodesViewIndexed(city: $city,
                                             cityNumber: $cityNumber,
                                             municipalityNumber: $municipalityNumber,
                                             municipality: $municipality)
        } else {
            EmptyView()
        }
    }
    
    /// Her legges det inn aktuelle sheet.state
    func image_Picker() {
        sheet.state = .imagePicker
    }
    
    func find_Post_Nummer() {
        sheet.state = .postNummer
    }
    
    func person_Postal_Codes_View_Indexed() {
        sheet.state = .postNummerIndexed
    }
    
}
