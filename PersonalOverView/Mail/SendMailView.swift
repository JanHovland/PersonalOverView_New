//
//  SendMailView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 10/10/2020.
//

import SwiftUI
import MessageUI

struct SendMailView: View {
    
    @State var isShowingMailView = false
    @State var toRecipients: [String] = []
    @State var subject: String = ""
    @State var name: String = ""
    @State var messageBody: String = ""
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?

    @State private var sendMail = NSLocalizedString("Send Email", comment: "SendMailView")
    
    var body: some View {
        LazyVStack {
            if MFMailComposeViewController.canSendMail() {
                Button(NSLocalizedString("Send an Email", comment: "SendMailView")) {
                }
            } else {
                Text(NSLocalizedString("Can't send emails from this device", comment: "SendMailView"))
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
        .navigationBarTitle(Text(sendMail), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    if UserDefaults.standard.string(forKey: "eMailOptionSelected") == "Aktivert" {
                                    self.isShowingMailView.toggle()
                                    } else {
                                        self.message = NSLocalizedString("You must activate the sending of an email.", comment: "SendMailView")
                                        alertIdentifier = AlertID(id: .first)

                                    }
                                }, label: {
                                    Text(NSLocalizedString("Send", comment: "SendMailView"))
                                        .font(Font.headline.weight(.light))
                                })
        )
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: self.$isShowingMailView,
                     toRecipients: self.$toRecipients,
                     subject: self.$subject,
                     messageBody: self.$messageBody,
                     result: self.$result)
        }
    }
    
}
