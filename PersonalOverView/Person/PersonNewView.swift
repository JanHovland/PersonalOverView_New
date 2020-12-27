//
//  NewPersonView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/10/2020.
//

import SwiftUI
import CloudKit

struct PersonNewView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var newPerson = NSLocalizedString("New person", comment: "PersonNewView")
    @State private var showingImagePicker = false
    @State private var findPostNummerNewPerson = false
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
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
    @State private var changeButtonText = false
    @State private var recordID: CKRecord.ID?
    @State private var saveNumber: Int = 0
    
    var buttonText1 = NSLocalizedString("Modify", comment: "PersonNewView")
    var buttonText2 = NSLocalizedString("Save", comment: "PersonNewView")
    
    var genders = [NSLocalizedString("Man", comment: "PersonNewView"),
                   NSLocalizedString("Woman", comment: "PersonNewView")]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack (alignment: .center, spacing: 60) {
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
                                Text(NSLocalizedString("Profile Image", comment: "PersonNewView"))
                            }
                        }
                    )
                }
                .padding(.top, 40)
                .onReceive(ImagePicker.shared.$image) { image in
                    self.image = image
                }
                Form {
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("First name", comment: "PersonNewView"),
                                   placeHolder: NSLocalizedString("Enter your first name", comment: "PersonNewView"),
                                   value: $firstName)
                        .autocapitalization(.words)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("Last name", comment: "PersonNewView"),
                                   placeHolder: NSLocalizedString("Enter your last name", comment: "PersonNewView"),
                                   value: $lastName)
                        .autocapitalization(.words)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("eMail", comment: "PersonNewView"),
                                   placeHolder: NSLocalizedString("Enter your email address", comment: "PersonNewView"),
                                   value: $personEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("Address", comment: "PersonNewView"),
                                   placeHolder: NSLocalizedString("Enter your address", comment: "PersonNewView"),
                                   value: $address)
                        .autocapitalization(.words)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                   checkPhone: true,
                                   secure: false,
                                   heading: NSLocalizedString("Phone Number", comment: "PersonNewView"),
                                   placeHolder: NSLocalizedString("Enter your phone number", comment: "PersonNewView"),
                                   value: $phoneNumber)
                    HStack (alignment: .center, spacing: 0) {
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("Postnummer", comment: "PersonNewView"),
                                       placeHolder: NSLocalizedString("Legg inn postnummer", comment: "PersonNewView"),
                                       value: $cityNumber)
                            .keyboardType(.numberPad)
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("City", comment: "PersonNewView"),
                                       placeHolder: NSLocalizedString("Enter city", comment: "PersonNewView"),
                                       value: $city)
                            .autocapitalization(.words)
                        VStack {
                            Button(action: {
                                find_Post_Nummer()
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
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("Municipality number", comment: "PersonNewView"),
                                       placeHolder: NSLocalizedString("Enter Municipality number", comment: "PersonNewView"),
                                       value: $municipalityNumber)
                            .keyboardType(.numberPad)
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "PersonNewView"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("Municipality", comment: "PersonNewView"),
                                       placeHolder: NSLocalizedString("Enter municipality", comment: "PersonNewView"),
                                       value: $municipality)
                            .autocapitalization(.none)
                            .autocapitalization(.words)
                    }
                    DatePicker(
                        selection: $dateOfBirth,
                        // in: ...dato,                  /// Uten in: -> ingen begrensning på datoutvalg
                        displayedComponents: [.date],
                        label: {
                            Text(NSLocalizedString("Date of birth", comment: "PersonNewView"))
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                                .padding(-5)
                        })
                    /// Returning an integer 0 == "Man" 1 == "Women
                    InputGender(heading: NSLocalizedString("Gender", comment: "PersonNewView"),
                                genders: genders,
                                value: $gender)
                }
            }
            .navigationBarTitle(Text(newPerson), displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        /// Rutine for å returnere til personoversikten
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        ReturnFromMenuView(text: NSLocalizedString("Person overview", comment: "PersonNewView"))
                                    })
                                , trailing:
                                    Button(action: {
                                        /// Rutine for å legge til en person
                                        if firstName.count > 0, lastName.count > 0 {
                                            CloudKitPerson.doesPersonExist(firstName: firstName,
                                                                           lastName: lastName) { (result) in
                                                
                                                if result == true {
                                                    
                                                    /// Finner recordID etter å ha lagret den nye personen
                                                    let firstName = self.firstName
                                                    let lastName = self.lastName
                                                    let predicate = NSPredicate(format: "firstName == %@ AND lastName = %@", firstName, lastName)
                                                    CloudKitPerson.fetchPerson(predicate: predicate)  { (result) in
                                                        switch result {
                                                        case .success(let person):
                                                            recordID = person.recordID
                                                        case .failure(let err):
                                                            let _ = err.localizedDescription
                                                        }
                                                    }
                                                    if recordID != nil {
                                                        modifyNewPerson(recordID: recordID,
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
                                                    } else {
                                                        message = NSLocalizedString("Can not modify this person yet, due to missing value for its recordID.\nPlease try again later...", comment: "PersonNewView")
                                                        alertIdentifier = AlertID(id: .third)
                                                    }
                                                } else {
                                                    saveNumber += 1
                                                    if saveNumber == 1 {
                                                        changeButtonText = false
                                                        let person = Person(
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
                                                            dateMonthDay: monthDay(date: dateOfBirth),
                                                            gender: gender,
                                                            image: image)
                                                        CloudKitPerson.savePerson(item: person) { (result) in
                                                            switch result {
                                                            case .success:
                                                                changeButtonText = true
                                                                let person1 = "'\(firstName)" + " \(lastName)'"
                                                                let message1 =  NSLocalizedString("was saved", comment: "PersonNewView")
                                                                message = person1 + " " + message1
                                                                alertIdentifier = AlertID(id: .first)
                                                            case .failure(let err):
                                                                message = err.localizedDescription
                                                                alertIdentifier = AlertID(id: .first)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            message = NSLocalizedString("First name and last name must both contain a value.", comment: "PersonNewView")
                                            alertIdentifier = AlertID(id: .first)
                                        }
                                    }, label: {
                                        Text(changeButtonText ? buttonText1 : buttonText2)
                                            .font(Font.headline.weight(.light))
                                    })
            )}
            
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
            /// Flytte opp feltene slik at keyboard ikke skjuler aktuelt felt
            .modifier(AdaptsToSoftwareKeyboard())
            .onAppear {
                /// Skal bare lagre dersom saveNumber ==0
                saveNumber = 0
                /// Sletter det sist valgte bildet fra ImagePicker
                ImagePicker.shared.image = nil
                /// Sletter også selve image
                image = nil
            }
            .overlay(
                HStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.none)
                        })
                        .padding(.trailing, 20)
                        .padding(.top, 115)
                        Spacer()
                    }
                }
            )
        
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
    
    func modifyNewPerson(recordID: CKRecord.ID?,
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
            person.dateMonthDay = monthDay(date: dateOfBirth)
            person.gender = gender
            /// Først vises det gamle bildet til personen, så kommer det nye bildet opp
            if image != nil {
                person.image = image
            }
            CloudKitPerson.modifyPerson(item: person) { (result) in
                switch result {
                case .success:
                    let person = "'\(person.firstName)" + " \(person.lastName)'"
                    let message1 =  NSLocalizedString("was modified", comment: "PersonNewView")
                    message = person + " " + message1
                    alertIdentifier = AlertID(id: .second)
                case .failure(let err):
                    message = err.localizedDescription
                    alertIdentifier = AlertID(id: .second)
                }
            }
        }
        else {
            message = NSLocalizedString("First name and last name must both contain a value.", comment: "PersonNewView")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
}

