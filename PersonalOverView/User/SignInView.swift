//
//  SignInView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

/// Dokumentasjon på hvordan en kan ha mange sheets
/// joemasilotti/Multiple sheets in SwiftUI.md
/// https://gist.github.com/joemasilotti/b90d89cc8e78440bf21c25ce512a72b1

import SwiftUI
import Network

struct SignInView: View {
    
    @ObservedObject var user = User()
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var showOptionMenu = false
    @State private var showSignUpView = false
    @State private var message: String = ""
    
    @State private var alertIdentifier: AlertID?
    
    @State private var device = ""
    @State private var indicatorShowing = false

    let optionMenu = NSLocalizedString("Options Menu", comment: "SignInView")
    
    let internetMonitor = NWPathMonitor()
    let internetQueue = DispatchQueue(label: "InternetMonitor")
    @State private var hasConnectionPath = false
    
    var body: some View {
        let menuItems = ContextMenu {
            
            /// Legger inn de forskjellige menypunktene
            Button(
                action: { setting_View() },
                label: {
                    HStack {
                        Text(NSLocalizedString("Settings", comment: "SignInView"))
                        Image(systemName: "gear")
                    }
                }
            )
            
            Button(
                action: { to_Do_View() },
                label: {
                    HStack {
                        Text(NSLocalizedString("To do", comment: "SignInView"))
                        Image(systemName: "square.and.pencil")
                    }
                }
            )
            
            Button(
                action: { persons_Over_View_Indexed() },
                label: {
                    HStack {
                        Text(NSLocalizedString("Qwerty_PersonsOverview", comment: "SignInView"))
                        Image(systemName: "person.2")
                    }
                }
            )
            
            Button(
                action: { person_Birthday_View() },
                label: {
                    HStack {
                        Text(NSLocalizedString("PersonBirthday", comment: "SignInView"))
                        Image(systemName: "gift")
                    }
                }
            )
            
            Button(
                action: { user_Over_View_Indexed() },
                label: {
                    HStack {
                        Text(NSLocalizedString("Account overview", comment: "SignInView"))
                        Image(systemName: "rectangle.stack.person.crop")
                    }
                }
            )
            
        }
        
        ScrollView (.vertical, showsIndicators: false) {
            
            ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
            
            VStack {
                Spacer(minLength: 37)
                HStack {
                    Text(NSLocalizedString("Sign in CloudKit", comment: "SignInView"))
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                Spacer(minLength: 37)
                ZStack {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .font(Font.title.weight(.ultraLight))
                    if user.image != nil {
                        Image(uiImage: user.image!)
                            .resizable()
                            .frame(width: 80, height: 80, alignment: .center)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                }
                .padding(10)
                /// Legger inn menuItems i .contextMenu (iOS 14)
                VStack {
                    LazyHStack {
                        Text(showOptionMenu ? optionMenu: "")
                    }
                    .padding()
                    .foregroundColor(.accentColor)
                    .contextMenu(showOptionMenu ? menuItems : nil)
                }
                
                Spacer(minLength: 25)
                VStack (alignment: .leading) {
                    OutputTextField(secure: false,
                                    heading: NSLocalizedString("Your name", comment: "SignInView"),
                                    value: $user.name)
                        
                        .autocapitalization(.words)
                    Spacer(minLength: 22)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("eMail address", comment: "SignInView"),
                                   placeHolder: NSLocalizedString("Enter your email address", comment: "SignInView"),
                                   value: $user.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Spacer(minLength: 20)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: true,
                                   heading: NSLocalizedString("Password",  comment: "SignInView"),
                                   placeHolder: NSLocalizedString("Enter your password", comment: "SignInView"),
                                   value: $user.password)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Spacer(minLength: 20)
                }
                .padding(10)
                VStack {
                    Button(action: {
                        /// Sjekker om det er forbindelse til Internett
                        if hasInternet() == false {
                            if UIDevice.current.localizedModel == "iPhone" {
                                device = "iPhone"
                            } else if UIDevice.current.localizedModel == "iPad" {
                                device = "iPad"
                            }
                            let message1 = NSLocalizedString("No Internet connection for this ", comment: "SignInView")
                            message = message1 + device + "."
                            alertIdentifier = AlertID(id: .first)
                        }
                        else {
                            if user.email.count > 0, user.password.count > 0 {
                                /// Starter ActivityIndicator
                                indicatorShowing = true
                                /// Skjuler OptionMenu
                                showOptionMenu = false
                                let email = user.email
                                /// Check different predicates at :   https://nspredicate.xyz
                                /// %@ : an object (eg: String, date etc), whereas %i will be substituted with an integer.
                                let predicate = NSPredicate(format: "email == %@", email)
                                CloudKitUser.doesUserExist(email: user.email, password: user.password) { (result) in
                                    if result != "OK" {
                                        message = result
                                        alertIdentifier = AlertID(id: .first)
                                    } else {
                                        CloudKitUser.fetchUser(predicate: predicate) { (result) in
                                            switch result {
                                            case .success(let userItem):
                                                user.email = userItem.email
                                                user.password = userItem.password
                                                user.name = userItem.name
                                                /// Avslutter x ActivityIndicator
                                                indicatorShowing = false
                                                if userItem.image != nil {
                                                    user.image = userItem.image!
                                                } else {
                                                    user.image = nil
                                                }
                                                user.recordID = userItem.recordID
                                                /// Viser OptionMenu
                                                showOptionMenu = true
                                            case .failure(let err):
                                                message = err.localizedDescription
                                                alertIdentifier = AlertID(id: .first)
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                message = NSLocalizedString("Both email and Password must have a value", comment: "SignInView")
                                alertIdentifier = AlertID(id: .first)
                            }
                            
                        }
                    }) {
                        Text(NSLocalizedString("Sign In", comment: "SignInView"))
                    }
                }
                Spacer(minLength: 120)
                HStack (alignment: .center, spacing: 60) {
                    Text(NSLocalizedString("Create a new account?", comment: "SignInView"))
                    Button(action: { sign_Up_View() },
                           label: {
                            HStack {
                                Text(NSLocalizedString("New user", comment: "SignInView"))
                            }
                            .foregroundColor(.blue)
                           })
                }
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
            .onAppear {
                startInternetTracking()
            }
        }
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        /// Ta bort tastaturet når en klikker utenfor feltet
        .modifier(DismissingKeyboard())
        /// Flytte opp feltene slik at keyboard ikke skjuler aktuelt felt
        .modifier(AdaptsToSoftwareKeyboard())
    }
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .settings {
            SettingView()
        } else if sheet.state == .toDo {
            ToDoView()
        } else if sheet.state == .personsOverviewIndexed {
            PersonsOverViewIndexed()
        } else if sheet.state == .personBirthday {
            PersonBirthdayView()
        } else if sheet.state == .acountOverviewIndexed{
            UserOverViewIndexed()
        } else if sheet.state == .signUp {
            SignUpView(returnSignIn: true)
        } else {
            EmptyView()
        }
    }
    
    /// Her legges det inn aktuelle sheet.state
    func setting_View() {
        sheet.state = .settings
    }
    
    func to_Do_View() {
        sheet.state = .toDo
    }
    
    func persons_Over_View_Indexed() {
        sheet.state = .personsOverviewIndexed
    }
    
    func person_Birthday_View() {
        sheet.state = .personBirthday
    }
    
    func user_Over_View_Indexed() {
        sheet.state = .acountOverviewIndexed
    }
    
    /// Må legge inn en ny sheet.state for å kalle "SignUpView"
    func sign_Up_View() {
        sheet.state = .signUp
    }
    
    func startInternetTracking() {
        // Only fires once
        guard internetMonitor.pathUpdateHandler == nil else {
            return
        }
        internetMonitor.pathUpdateHandler = { update in
            if update.status == .satisfied {
                self.hasConnectionPath = true
            } else {
                self.hasConnectionPath = false
            }
        }
        internetMonitor.start(queue: internetQueue)
    }
    
    /// Will tell you if the device has an Internet connection
    /// - Returns: true if there is some kind of connection
    func hasInternet() -> Bool {
        return hasConnectionPath
    }
    
    
    
}
