//
//  SwiftDeleteAllUsers.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI

struct SwiftDeleteAllUsers: View {
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false

    var body: some View {
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
            Text(NSLocalizedString("Press the 'Delete' button to delete all Users", comment: "SwiftDeleteAllPersons"))
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
                                                            CloudKitUser.deleteAllUsers()
                                                            /// Stop ActivityIndicator
                                                            indicatorShowing = false
                                                            message = result
                                                            alertIdentifier = AlertID(id: .first)
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "PersonsOverView"))))
            }
        }
        .navigationBarTitle(NSLocalizedString("Delete all Users", comment: "SwiftDeleteAllUsers"), displayMode:  .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    /// Må bare kjøres en gang
                                    if UserDefaults.standard.string(forKey: "jsonUserOptionSelected") == "Aktivert" {
                                        title = NSLocalizedString("Delete all users 1", comment: "SwiftDeleteAllPersons")
                                        message = NSLocalizedString("AAre you sure you want to delete all users?", comment: "SwiftDeleteAllPersons")
                                        choise = NSLocalizedString("Delete all users 2", comment: "SwiftDeleteAllPersons")
                                        result = NSLocalizedString("All users are deleted 1.", comment: "SwiftDeleteAllPersons")
                                        alertIdentifier = AlertID(id: .third)
                                    } else {
                                        let message1 = NSLocalizedString("You must activate the ", comment: "SwiftDeleteAllUsers")
                                        let message2 = NSLocalizedString("CloudKit save User option", comment: "SwiftDeleteAllUsers")
                                        let message3 = NSLocalizedString("to be able to delete all Users in CloudKit.", comment: "SwiftDeleteAllUsers")
                                        message = message1 + "\"" + message2 + "\"" + message3
                                        alertIdentifier = AlertID(id: .first)
                                    }
                                }, label: {
                                    Text(NSLocalizedString("Delete", comment: "SwiftDeleteAllUsers"))
                                        .font(Font.headline.weight(.light))
                                })
        )
    }
}
