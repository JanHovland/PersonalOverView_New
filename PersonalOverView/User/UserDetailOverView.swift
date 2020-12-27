//
//  UserDetailOverView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 14/11/2020.
//

import SwiftUI
import CloudKit

struct UserDetailOverView: View {
    
    var userRecord: UserRecord
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            HStack (alignment: .center, spacing: 50) {
                if userRecord.image != nil {
                    Image(uiImage: userRecord.image!)
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .font(Font.title.weight(.ultraLight))
                }
                Text(userRecord.name)
            }
            List {
                OutputTextField(secure: false,
                                heading: NSLocalizedString("eMail address", comment: "UserDetailOverView"),
                                value: $email)
                OutputTextField(secure: true,
                                heading: NSLocalizedString("Password", comment: "UserDetailOverView"),
                                value: $password)
            }
        }
        .navigationBarTitle(NSLocalizedString("User detail View", comment: "PersonView"), displayMode: .inline)
        .onAppear {
            email = userRecord.email
            password = userRecord.password
        }
    }
    
}



