//
//  PersonSendEmailView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 11/10/2020.
//

import SwiftUI
import MessageUI

struct PersonSendEmailView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var personInfo: PersonInfo
    
    @State var isShowingMailView = false
    @State var toRecipients: [String] = []
    @State var subject: String = ""
    @State var name: String = ""
    @State var messageBody: String = ""
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        VStack {
            if MFMailComposeViewController.canSendMail() {
                Button(action: {
                    toRecipients = [personInfo.email]
                    subject = NSLocalizedString("Birthday greetings",comment: "PersonSendEmailView")
                    name = personInfo.name
                    let message = NSLocalizedString("Congratulation so much on your birthday, ", comment: "PersonSendEmailView")
                    messageBody = message + name + ",🇳🇴 😀"
                    isShowingMailView.toggle()
                }, label: {
                    Image(systemName: "envelope.fill")
                        .imageScale(.large)
                    Text(NSLocalizedString("Show mail view", comment: "PersonSendEmailView"))
                })
                .foregroundColor(Color.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            } else {
                Text(NSLocalizedString("Can't send emails from this device", comment: "PersonSendEmailView"))
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
            MailView(isShowing: $isShowingMailView,
                     toRecipients: $toRecipients,
                     subject: $subject,
                     messageBody: $messageBody,
                     result: $result)
        }
    }
}
