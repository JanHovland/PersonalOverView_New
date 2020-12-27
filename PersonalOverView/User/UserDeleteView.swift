//
//  UserDeleteView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 23/09/2020.
//

import SwiftUI
import CloudKit

struct UserDeleteView: View {
    var user1: UserRecord
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var recordID: CKRecord.ID?
    @State private var newRecordtem = UserRecord(name: "", email: "", password: "", image: nil)
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    /// ActivityIndicator setter opp en ekstra tom linje for seg selv
                    ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                    ZStack {
                        if user1.image == nil {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .font(Font.title.weight(.ultraLight))
                        } else {
                            Image(uiImage: user1.image!)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        }
                    }
                    Form {
                        List {
                            OutputTextField(secure: false,
                                            heading: NSLocalizedString("Your name", comment: "UserDeleteView"),
                                            value: $name)
                            
                            OutputTextField(secure: false,
                                            heading: NSLocalizedString("eMail address", comment: "UserDeleteView"),
                                            value: $email)
                            
                            OutputTextField(secure: true,
                                            heading: NSLocalizedString("Password", comment: "UserDeleteView"),
                                            value: $password)
                        }
                    } /// Form
                    .padding(.top, 10)
                    .padding(.bottom, -20)
                    Spacer(minLength: 100)
                    let message = NSLocalizedString("Press the 'Delete' key to delete a Person", comment:"UserDeleteView")
                    BottomView(message: message)
                } // VStack
                .navigationBarTitle(NSLocalizedString("Delete user 2", comment: "UserDeleteView"), displayMode:  .inline)
                .navigationBarItems(leading:
                                        Button(action: {
                                            /// Rutine for å returnere til personoversikten
                                            presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            ReturnFromMenuView(text: NSLocalizedString("Users", comment: "UserDeleteView"))
                                        })
                                    ,trailing:
                                        LazyHStack {
                                            Button(action: {
                                                /// Slett personen
                                                recordID = user1.recordID
                                                title = NSLocalizedString("Delete an user 4", comment: "UserDeleteView")
                                                message = NSLocalizedString("Are you sure you want to delete this user?", comment: "UserDeleteView")
                                                let message = NSLocalizedString("Delete #1", comment: "UserDeleteView")
                                                choise = message + " " + user1.name
                                                result = NSLocalizedString("Successfully deleted an user", comment: "UserDeleteView")
                                                /// Aktivere alert
                                                alertIdentifier = AlertID(id: .third )
                                            }, label: {
                                                Text(NSLocalizedString("Delete", comment: "UserDeleteView"))
                                                    .foregroundColor(.blue)
                                                    .font(Font.headline.weight(.light))
                                            })
                                        }
                )
            } /// VStack
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
                                                                if user1.name.count > 0, user1.email.count > 0, user1.password.count > 0 {
                                                                    /// Starte ActivityIndicator
                                                                    indicatorShowing = true
                                                                    /// MARK: - delete user in CloudKit
                                                                    CloudKitUser.deleteUser(recordID: user1.recordID!) { (result) in
                                                                        switch result {
                                                                        case .success:
                                                                            /// Starte ActivityIndicator
                                                                            indicatorShowing = false
                                                                            let message1 = NSLocalizedString("User", comment: "UserDeleteView")
                                                                            let message2 = NSLocalizedString("deleted", comment: "UserDeleteView")
                                                                            message = message1 + " '\(user1.name)'" + " " + message2
                                                                            alertIdentifier = AlertID(id: .first)
                                                                        case .failure(let err):
                                                                            message = err.localizedDescription
                                                                            alertIdentifier = AlertID(id: .first)
                                                                        }
                                                                    }
                                                                } else {
                                                                    message = NSLocalizedString("Missing parameters", comment: "UserDeleteView")
                                                                    alertIdentifier = AlertID(id: .first)
                                                                }
                                                             }),
                                 secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "PersonsOverView"))))
                }
            }
        } /// NavigationView
        /// For å få riktig visning både på iPhone og på IPad:
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            name = user1.name
            email = user1.email
            password = user1.password
        }
        .modifier(DismissingKeyboard())
        
    } //Body
    
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


