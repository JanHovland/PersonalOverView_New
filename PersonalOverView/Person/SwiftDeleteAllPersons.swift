//
//  SwiftDeleteAllPersons.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 12/11/2020.
//

import SwiftUI

struct SwiftDeleteAllPersons: View {
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
            Text(NSLocalizedString("Press the 'Delete' button to delete all Persons", comment: "SwiftDeleteAllPersons"))
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
                                                            DispatchQueue.global().async {
                                                                /// Starte ActivityIndicator
                                                                indicatorShowing = true
                                                                CloudKitPerson.deleteAllPersons()
                                                                /// Stoppe ActivityIndicator
                                                                indicatorShowing = false
                                                            }
                                                            message = result
                                                            alertIdentifier = AlertID(id: .first)
                                                         }),
                            secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "PersonsOverView"))))
            }
        }
        Spacer(minLength: 50)
        .navigationBarTitle(NSLocalizedString("CloudKit Delete all Persons", comment: "SwiftDeleteAllPersons"), displayMode:  .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    /// Må bare kjøres en gang
                                    if UserDefaults.standard.string(forKey: "jsonPersonOptionSelected") == "Aktivert" {
                                        title = NSLocalizedString("1 Delete all persons", comment: "SwiftDeleteAllPersons")
                                        message = NSLocalizedString("Are you sure you want to delete all persons?", comment: "SwiftDeleteAllPersons")
                                        choise = NSLocalizedString("2 Delete all persons", comment: "SwiftDeleteAllPersons")
                                        result = NSLocalizedString("All persons are deleted.", comment: "SwiftDeleteAllPersons")
                                        alertIdentifier = AlertID(id: .third)
                                    } else {
                                        let message1 = NSLocalizedString("You must activate the ", comment: "SwiftDeleteAllPersons")
                                        let message2 = NSLocalizedString("CloudKit save Persons option", comment: "SwiftDeleteAllPersons")
                                        let message3 = NSLocalizedString("to be able to delete all Persons in CloudKit.", comment: "SwiftDeleteAllPersons")
                                        message = message1 + "\"" + message2 + "\"" + message3
                                        alertIdentifier = AlertID(id: .first)
                                    }
                                }, label: {
                                    Text(NSLocalizedString("Delete", comment: "SwiftDeleteAllPersons"))
                                        .font(Font.headline.weight(.light))
                                })
        )

    }
}
