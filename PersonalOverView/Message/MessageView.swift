//
//  MessageView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 20/10/2020.
//

/// Dette virker ikke mht. sending, når en trykker på send, skjer ingenting!

import MessageUI
import SwiftUI

struct MessageView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MFMessageComposeViewController
    
    @Binding var isShowing: Bool
    @Binding var recipients: [String]
    @Binding var subject: String
    @Binding var messageBody: String
    @Binding var result: Result<MessageComposeResult, Error>?
    
    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        
        @Binding var isShowing: Bool
        @Binding var result: Result<MessageComposeResult, Error>?
        
        init(isShowing: Binding<Bool>,
             result: Binding<Result<MessageComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            switch (result) {
            case .cancelled:
                let _ = "Message was cancelled"
            case .failed:
                let _ = "Message failed"
            case .sent:
                let _ = "Message was sent" 
            default:
                break
            }
        }
        
//        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//            defer {
//                isShowing = false
//            }
//            self.result = .success(result)
//        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing,
                           result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MessageView>) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        
        vc.recipients = recipients
        vc.subject = subject
        vc.body = messageBody
//        vc.messageComposeDelegate = true as? MFMessageComposeViewControllerDelegate
         vc.messageComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: UIViewControllerRepresentableContext<MessageView>) {
        
    }
    
    
    
}

