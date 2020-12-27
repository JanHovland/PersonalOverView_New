//
//  SendSMSView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 18/10/2020.
//

import SwiftUI

struct SendSMSView: View {
    
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    
    var body: some View {
        LazyVStack {
            Text("Send a message")
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
        .navigationBarTitle(NSLocalizedString("Send message", comment: "NewPersonView"), displayMode:  .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    let prefix = "sms:"
                                    let message = prefix
                                    if UserDefaults.standard.string(forKey: "smsOptionSelected") == "Aktivert" {
                                        if let url = URL(string:  message) {
                                            UIApplication.shared.open(url, options: [:])
                                        }
                                    } else {
                                        self.message = NSLocalizedString("You must activate the sending of a message.", comment: "SendSMSView")
                                        alertIdentifier = AlertID(id: .first)
                                    }
                                }, label: {
                                    Text(NSLocalizedString("Send", comment: "SendSMSView"))
                                        .font(Font.headline.weight(.light))
                                })
        )
    }
}
