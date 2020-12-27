//
//  OutputTextField.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

import SwiftUI

import SwiftUI
import Foundation

struct OutputTextField: View {

    @Environment(\.presentationMode) var presentationMode

    @State private var showPassword: Bool = false
    @State private var secureValue: String = ""

    var secure: Bool
    var heading: String
    @Binding var value: String

    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                Text(heading)
                    .padding(-4)
                    .font(Font.caption.weight(.semibold))
                    .foregroundColor(.accentColor)
                if secure {
                    if showPassword == false {
                        Text(secureValue)
                            .font(Font.system(size: 9, design: .default))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                    } else {
                         Text(secureValue)
                        .padding(.horizontal, 7)
                    }
                } else {
                    Text(value)
                        .padding(.horizontal, 7)
                }
            }
        }
        .onAppear {
            showPassword = UserDefaults.standard.bool(forKey: "showPassword")
            if showPassword == false {
                if secure {
                    secureValue = ""
                    if value.count > 0 {
                        for _ in 0..<value.count {
                            secureValue = secureValue + "●"
                        }
                    }
                }
            } else {
                secureValue = value
            }
        }
    }
}
