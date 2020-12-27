//
//  PersonDeleteView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 06/12/2020.
//

import SwiftUI
import CloudKit

struct PersonDeleteView: View {
    var person: Person
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var recordID: CKRecord.ID?
    @State private var indicatorShowing = false
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var cityNumber: String = ""
    @State private var city: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    /// ActivityIndicator setter opp en ekstra tom linje for seg selv
                    ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                    ZStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .font(Font.title.weight(.ultraLight))
                        if person.image != nil {
                            Image(uiImage: person.image!)
                                .resizable()
                                .frame(width: 80, height: 80, alignment: .center)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        }
                    }
                    Form {
                        List {
                            OutputTextField(secure: false,
                                            heading: NSLocalizedString("First name", comment: "PersonDeleteView"),
                                            value: $firstName)
                            
                            OutputTextField(secure: false,
                                            heading: NSLocalizedString("Last name", comment: "PersonDeleteView"),
                                            value: $lastName)
                            
                            OutputTextField(secure: false,
                                            heading: NSLocalizedString("Phone Number", comment: "PersonDeleteView"),
                                            value: $phoneNumber)
                            
                            OutputTextField(secure: false,
                                            heading: NSLocalizedString("Address", comment: "PersonDeleteView"),
                                            value: $address)
                            
                            HStack (alignment: .center, spacing: 20) {
                                
                                OutputTextField(secure: false,
                                                heading: NSLocalizedString("Postnummer", comment: "PersonDeleteView"),
                                                value: $cityNumber)
                                
                                Spacer()
                                
                                OutputTextField(secure: false,
                                                heading: NSLocalizedString("City", comment: "PersonDeleteView"),
                                                value: $city)
                            }
                        }
                        
                    } /// Form
                    .padding(.top, 10)
                    .padding(.bottom, -20)
                    Spacer(minLength: 100)
                    let message = NSLocalizedString("Press the 'Delete' key to delete a Person", comment:"PersonDeleteView")
                    BottomView(message: message)
                } /// Vstack
                .navigationBarTitle(NSLocalizedString("Delete person index", comment: "PersonDeleteView"), displayMode: .inline)
                .navigationBarItems(leading:
                                        Button(action: {
                                            /// Rutine for å returnere til personoversikten
                                            presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            ReturnFromMenuView(text: NSLocalizedString("Person overview", comment: "PersonDeleteView"))
                                        })
                                    ,trailing:
                                        LazyHStack {
                                            Button(action: {
                                                /// Slett personen
                                                recordID = person.recordID
                                                title = NSLocalizedString("Delete person", comment: "PersonDeleteView")
                                                message = NSLocalizedString("Are you sure you want to delete this person?", comment: "PersonDeleteView")
                                                let message = NSLocalizedString("Delete #1", comment: "PersonDeleteView")
                                                choise = message + " " + person.firstName + " " + person.lastName
                                                result = NSLocalizedString("Successfully deleted a person", comment: "PersonDeleteView")
                                                /// Aktivere alert
                                                alertIdentifier = AlertID(id: .third )
                                            }, label: {
                                                Text(NSLocalizedString("Delete", comment:  "PersonDeleteView"))
                                                    .foregroundColor(.blue)
                                                    .font(Font.headline.weight(.light))
                                            })
                                        }
                )
            } /// Vstack
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
                                                                CloudKitPerson.deletePerson(recordID: recordID!) { (res) in
                                                                    switch res {
                                                                    case .success :
                                                                        /// Starte ActivityIndicator
                                                                        indicatorShowing = false
                                                                        message = result
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    case .failure(let err):
                                                                        message = err.localizedDescription
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    }
                                                                }
                                                             }),
                                 secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "PersonDeleteView"))))
                }
            }
        } /// NavigationView
        /// For å få riktig visning både på iPhone og på IPad:
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            firstName = person.firstName
            lastName = person.lastName
            address = person.address
            phoneNumber = person.phoneNumber
            cityNumber = person.cityNumber
            city = person.city
        }
        .modifier(DismissingKeyboard())
    } /// Body
    
    struct BottomView: View {
        var message: String
        
        var body: some View {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Text(message)
                    .multilineTextAlignment(.center)
            }
            .padding(.leading, 50)
            .padding(.trailing, 50)
            .padding(.bottom, 50)
        }
    }
    
    
}
