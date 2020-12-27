//
//  PersonSendMessageView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 20/10/2020.
//

/// Dette virker ikke mht. sending, når en trykker på send, skjer ingenting!

import SwiftUI
import MessageUI

struct PersonSendMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var personInfo: PersonInfo
    
    @State var isShowingMailView = false
    @State var recipients: [String] = []
    @State var subject: String = ""
    @State var name: String = ""
    @State var messageBody: String = ""
    @State var result: Result<MessageComposeResult, Error>? = nil
    
    var body: some View {
        VStack {
            if MFMessageComposeViewController.canSendText() {
                Button(action: {
                    recipients = ["40005430"]          // personInfo.phoneNumber]
                    subject = NSLocalizedString("Birthday greetings",comment: "PersonSendEmailView")
                    name = "Jan" // personInfo.name
                    let message = NSLocalizedString("Congratulation so much on your birthday, ", comment: "PersonSendMessageView")
                    messageBody = message + name + ",🇳🇴 😀"
                    isShowingMailView.toggle()
                }, label: {
                    Image(systemName: "envelope.fill")
                        .imageScale(.large)
                    Text(NSLocalizedString("Show message view", comment: "PersonSendMessageView"))
                })
                .foregroundColor(Color.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            } else {
                Text(NSLocalizedString("Can't send messages from this device", comment: "PersonSendMessageView"))
            }
        }
        .overlay(
            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.none)
                    })
                    .padding(.leading, 280)
                    .padding(.top, -250)
                    Spacer()
                }
            }
        )
        .sheet(isPresented: $isShowingMailView) {
            MessageView(isShowing: $isShowingMailView,
                        recipients: $recipients,
                        subject: $subject,
                        messageBody: $messageBody,
                        result: $result)
        }
    }
}
