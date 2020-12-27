//
//  MessageOptionSetting.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI

struct MessageOptionSetting: View {
    var smsChoises: [smsOptions] = [.deaktivert, .aktivert]
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("MESSAGE", comment: "SettingView")),
                    footer: Text(NSLocalizedString("You must activate the message in order to send a message", comment: "SettingView"))) {
                Picker(NSLocalizedString("Message option", comment: "SettingView"), selection: $settingsStore.smsOptionSelected) {
                    ForEach(smsChoises, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationBarTitle(Text(NSLocalizedString("Message option", comment: "SettingView")), displayMode: .inline)
        }
    }
}


