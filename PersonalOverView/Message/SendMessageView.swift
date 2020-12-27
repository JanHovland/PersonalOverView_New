//
//  SendMessageView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 20/10/2020.
//

/// Dette virker ikke mht. sending, når en trykker på send, skjer ingenting!

import SwiftUI
import MessageUI

struct SendMessageView: View {
    
    @State var isShowingMailView = false
    @State var recipients: [String] = []
    @State var subject: String = ""
    @State var name: String = ""
    @State var messageBody: String = ""
    @State var result: Result<MessageComposeResult, Error>? = nil
    
    var body: some View {
        LazyVStack {
            if MFMailComposeViewController.canSendMail() {
                Button(NSLocalizedString("Send Email", comment: "NewPersonView")) {
//                    let recipients = ""
//                    let subject = ""
//                    let name = ""
//                    let body = ""
//                    EmailInit(mailToRecipients: recipients,
//                              mailSubject: subject,
//                              mailName: name,
//                              mailMessageBody: body)
                    self.isShowingMailView.toggle()
                }
            } else {
                Text(NSLocalizedString("Can't send messages from this device", comment: "NewPersonView")) 
            }
        }
        .sheet(isPresented: $isShowingMailView) {
            MessageView(isShowing: $isShowingMailView,
                        recipients: $recipients,
                        subject: $subject,
                        messageBody: $messageBody,
                        result: $result)
        }
    }
    
//    func emailInit(mailToRecipients: String,
//                   mailSubject: String,
//                   mailName: String,
//                   mailMessageBody: String) {
//        toRecipients = [mailToRecipients]
//        subject = mailSubject
//        name = mailName
//        messageBody = mailMessageBody
//    }
    
}
