//
//  Deprecated UserMaintenanceView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 23/09/2020.
//

import SwiftUI

struct UserMaintenanceView: View {
    
    @EnvironmentObject var user: User
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var newRecord = UserRecord(name: "", email: "", password: "", image: nil)
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer(minLength: 30)
                ZStack {
                    if user.image == nil {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .font(Font.title.weight(.ultraLight))
                    } else {
                        Image(uiImage: user.image!)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                }
                .padding(.bottom)
                Button(
                    action: {
                        Image_Select()
                    },
                    label: {
                        HStack {
                            Text(NSLocalizedString("Choose Profile Image", comment: "UserMaintenanceView"))
                        }
                    }
                )
                ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                VStack {
                    List {
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("Your name", comment: "UserMaintenanceView"),
                                       placeHolder: NSLocalizedString("Enter your name", comment: "UserMaintenanceView"),
                                       value: $user.name)
                            .autocapitalization(.words)
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                       checkPhone: false,
                                       secure: false,
                                       heading: NSLocalizedString("eMail address", comment: "UserMaintenanceView"),
                                       placeHolder: NSLocalizedString("Enter your email address", comment: "UserMaintenanceView"),
                                       value: $user.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                       checkPhone: false,
                                       secure: true,
                                       heading: NSLocalizedString("Password", comment: "UserMaintenanceView"),
                                       placeHolder: NSLocalizedString("Enter your password", comment: "UserMaintenanceView"),
                                       value: $user.password)
                            .keyboardType(.emailAddress)  
                            .autocapitalization(.none)
                    }
                    .padding(.bottom)
                    /// Fjerner linjer mellom elementene
                    .listStyle(GroupedListStyle())
                    .environment(\.horizontalSizeClass, .regular)
                    /// Legge inn tekst på bummen av skjermen
                    Spacer()
                    Text(NSLocalizedString("Press the 'Save' button to save the new data for this User", comment: "UserMaintenanceView"))
                        .padding(.leading, 50)
                        .padding(.trailing, 50)
                        .padding(.bottom, 50)
                }
            }
            .navigationBarTitle(NSLocalizedString("User maintenance", comment: "UserMaintenanceView"), displayMode:  .inline)
            .navigationBarItems(trailing:
                                    LazyHStack {
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            Image(systemName: "chevron.down.circle.fill")
                                        })
                                        Button(action: {
                                            title = NSLocalizedString("Do you want to update this user?", comment: "UserMaintenanceView")
                                            message = NSLocalizedString("If you do that, the user will now contain the new values.", comment: "UserMaintenanceView")
                                            choise = NSLocalizedString("Update this user", comment: "UserMaintenanceView")
                                            result = NSLocalizedString("Successfully modified this user", comment: "UserMaintenanceView")
                                            /// Aktivere alert
                                            alertIdentifier = AlertID(id: .third )
                                        }, label: {
                                            Text(NSLocalizedString("Save", comment: "UserMaintenanceView"))
                                        })
                                        .font(Font.headline.weight(.light))
                                    }
            )
        }
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        .onReceive(ImagePicker.shared.$image) { image in
            user.image = image
        }
        .onAppear {
            let email = user.email
            CloudKitUser.doesUserExist(email: user.email, password: user.password) { (result) in
                if result != "OK" {
                    message = result
                    alertIdentifier = AlertID(id: .first)
                } else {
                    let predicate = NSPredicate(format: "email == %@", email)
                    CloudKitUser.fetchUser(predicate: predicate) { (result) in
                        switch result {
                        case .success(let userItem):
                            if userItem.image != nil {
                                user.image = userItem.image!
                            }
                        case .failure(let err):
                            message = err.localizedDescription
                            alertIdentifier = AlertID(id: .first)
                        }
                    }
                }
            }
        }
        .modifier(DismissingKeyboard())
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
                                                            if user.name.count > 0, user.email.count > 0, user.password.count > 0 {
                                                                /// Starte ActivityIndicator
                                                                indicatorShowing = true
                                                                newRecord.name = user.name
                                                                newRecord.email = user.email
                                                                newRecord.password = user.password
                                                                newRecord.recordID = user.recordID
                                                                if ImagePicker.shared.image != nil {
                                                                    newRecord.image = ImagePicker.shared.image
                                                                }
                                                                /// MARK: - modify in CloudKit
                                                                CloudKitUser.modifyUser(item: newRecord) { (res) in
                                                                    switch res{
                                                                    case .success:
                                                                        /// Stop ActivityIndicator
                                                                        indicatorShowing = false
                                                                        message = result
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    case .failure(let err):
                                                                        message = err.localizedDescription
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    }
                                                                }
                                                            } else {
                                                                message = NSLocalizedString("Missing parameters", comment: "UserMaintenanceView")
                                                                alertIdentifier = AlertID(id: .first)
                                                            }
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "UserMaintenanceView"))))
            }
        }
    }
    
    /// Her legges det inn knytning til aktuelle view som er knyttet til et sheet
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .imageSelect {
            ImagePicker.shared.view
        } else {
            EmptyView()
        }
    }
    
    /// Her legges det inn aktuelel sheet.state
    func Image_Select() {
        sheet.state = .imageSelect
    }
    
}
