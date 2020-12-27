//
//  SignUpView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

import SwiftUI
import CloudKit

struct SignUpView : View {
    
    var returnSignIn: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    @State private var image: UIImage? = nil
    @State private var userItem = UserRecord(name: "", email: "", password: "", image: nil)
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 54)
                /// Plasser ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                /// hvor det ikke kommer warning : Result of 'ActivityIndicator' initializer is unused
                /// Sett verdien av indicatorShowing til true for å starte ActivityIndicator
                /// Sett verdien av indicatorShowing til false for å avslutte ActivityIndicator
                ZStack {
                    if image != nil {
                        SwiftUI.Image(uiImage: image!)
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    } else {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .font(Font.title.weight(.ultraLight))
                    }
                    
                }
                .padding(10)
                Button(
                    action: { selectImage() },
                    label: {
                        HStack {
                            Text(NSLocalizedString("Choose Profile Image", comment: "SignUpView"))
                        }
                    }
                )
                ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                Spacer(minLength: 10)
                VStack {
                    List {
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("Your name", comment: "SignUpiew"),
                                       placeHolder: NSLocalizedString("Enter your name", comment: "SignUpView"),
                                       value: $userItem.name)
                            .autocapitalization(.words)
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("eMail address", comment: "SignUpView"),
                                       placeHolder: NSLocalizedString("Enter your email address", comment: "SignUpView"),
                                       value: $userItem.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                       checkPhone: false,
                                       secure: true,
                                       heading: NSLocalizedString("Password", comment: "SignUpView"),
                                       placeHolder: NSLocalizedString("Enter your password", comment: "SignUpView"),
                                       value: $userItem.password)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                /// Fjerner linjer mellom elementene
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular)
            }
            .navigationBarTitle(NSLocalizedString("Add a new User", comment: "SignUpView"), displayMode:  .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        /// Rutine for å returnere til personoversikten
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        HStack {
                                            ReturnFromMenuView(text: NSLocalizedString("Users", comment: "NewPersonView"))
                                        }
                                    })
                                ,trailing:
                                    LazyHStack {
                                         Button(action: {
                                            /// Rutine for å legge til en bruker
                                            if userItem.name.count > 0, userItem.email.count > 0, userItem.password.count > 0 {
                                                /// Starte ActivityIndicator
                                                indicatorShowing = true
                                                CloudKitUser.doesUserExist(email: userItem.email,
                                                                           password: userItem.password) { (result) in
                                                    if result != "OK" {
                                                        CloudKitUser.saveUser(item: userItem) { (result) in
                                                            switch result {
                                                            case .success:
                                                                let message1 = NSLocalizedString("Added new user:", comment: "SignUpView")
                                                                message = message1 + " '\(userItem.name)'"
                                                                userItem.name = ""
                                                                userItem.email = ""
                                                                userItem.password = ""
                                                                userItem.image = nil
                                                                image = nil
                                                                /// Avslutte ActivityIndicator
                                                                indicatorShowing = false
                                                                alertIdentifier = AlertID(id: .first)
                                                            case .failure(let err):
                                                                message = err.localizedDescription
                                                                alertIdentifier = AlertID(id: .first)
                                                            }
                                                        }
                                                    } else {
                                                        message = NSLocalizedString("This email and this password already exists on an other user.", comment: "SignUpView")
                                                        alertIdentifier = AlertID(id: .first)
                                                    }
                                                }
                                            } else {
                                                message = NSLocalizedString("Name, eMail or Password must all contain a value.", comment: "SignUpView")
                                                alertIdentifier = AlertID(id: .first)
                                            }
                                        }, label: {
                                            Text("Add user")
                                                .font(Font.headline.weight(.light))
                                        })
                                    }
            )
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
            /// Sette image til det bildet som ble valgt
            .onReceive(ImagePicker.shared.$image) { image in
                self.image = image
            }
            /// Slette bildet ved oppstart
            .onAppear {
                image = nil
            }
            /// Ta bort tastaturet når en klikker utenfor feltet
            .modifier(DismissingKeyboard())
            /// Flytte opp feltene slik at keyboard ikke skjuler aktuelt felt
            .modifier(AdaptsToSoftwareKeyboard())
        }
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
    }
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .imageSelect {
            ImagePicker.shared.view
        } else {
            EmptyView()
        }
    }
    
    /// Her legges det inn akyuell sheet.state
    func selectImage() {
        sheet.state = .imageSelect
    }
    
}

struct ContentViewHover: View {
    
    @State private var overImage = false
    @State private var text = ""
    
    /// Virker best om musen flyttes oppover
    var body: some View {
        VStack {
            Text(text)
            Image(systemName: "gear")
                .onHover { over in
                    self.overImage = over
                    if over {
                        text = "Hjelpe tekst for knapp A"
                    } else {
                        text = ""
                    }
                }
        }
    }
    
}



