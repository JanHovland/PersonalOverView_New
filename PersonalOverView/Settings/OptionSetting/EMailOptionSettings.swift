//
//  EMailOptionSettings.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI

/// Denne setter aktivereingen for e-post
struct EMailOptionSettings : View {
    var eMailChoises: [eMailOptions] = [.deaktivert, .aktivert]
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    
    var body: some View {
        Form {
            Section(header: Text(NSLocalizedString("EMAIL", comment: "SettingView")),
                    footer: Text(NSLocalizedString("You must activate the email in order to send an email", comment: "SettingView"))) {
                Picker(NSLocalizedString("Email option", comment: "SettingView"), selection: $settingsStore.eMailOptionSelected) {
                    ForEach(eMailChoises, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationBarTitle(Text(NSLocalizedString("Email option", comment: "SettingView")), displayMode: .inline)
        }
    }
}

