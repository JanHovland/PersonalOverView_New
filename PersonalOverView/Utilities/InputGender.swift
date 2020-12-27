//
//  InputGender.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/10/2020.
//

import SwiftUI

struct InputGender: View {
    var heading: String
    var genders: [String]
    @Binding var value: Int
    
    var body: some View {
        VStack {
            HStack (alignment: .center, spacing: 90) {
                Text(heading)
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .padding(-5)
                Picker(selection: $value, label: Text("")) {
                    ForEach(0..<genders.count) { index in
                        Text(genders[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}
