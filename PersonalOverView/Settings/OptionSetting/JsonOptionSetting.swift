//
//  JsonOptionSetting.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI

struct JsonFirebaseOptionSetting: View {
    var jsonFirebaseChoises: [jsonFirebaseOptions] = [.deaktivert, .aktivert]
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    var body: some View {
        Form {
            let message1 = NSLocalizedString("You must activate the ", comment: "JsonFirebaseOptionSetting")
            let message2 = NSLocalizedString("Firebase save Persons option", comment: "JsonFirebaseOptionSetting")
            let message3 = NSLocalizedString(" to be able to update the Person table in CloudKit.", comment: "JsonPersonOptionSetting")
            let message4 = message1 + "\"" + message2 + "\"" + message3
            Section(header: Text(NSLocalizedString("JSON FIREBASE SAVE TO CLOUDKIT", comment: "JsonFirebaseOptionSetting")),
                    footer: Text(message4)) {
                Picker(NSLocalizedString("Json Firebase option", comment: "JsonOptionSetting"), selection: $settingsStore.jsonFirebaseOptionSelected) {
                    ForEach(jsonFirebaseChoises, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationBarTitle(Text(NSLocalizedString("Firebase save Persons option", comment: "JsonFirebaseOptionSetting")), displayMode: .inline)
        }
    }
}

struct JsonPersonOptionSetting: View {
    var jsonPersonChoises: [jsonPersonOptions] = [.deaktivert, .aktivert]
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    var body: some View {
        Form {
            let message1 = NSLocalizedString("You must activate the ", comment: "JsonPersonOptionSetting")
            let message2 = NSLocalizedString("CloudKit save Persons option", comment: "JsonPersonOptionSetting")
            let message3 = NSLocalizedString(" to be able to update the Person table in CloudKit.", comment: "JsonPersonOptionSetting")
            let message4 = message1 + "\"" + message2 + "\"" + message3
            Section(header: Text(NSLocalizedString("CLOUDKIT SAVE PERSONS OPTION", comment: "JsonPersonOptionSetting")),
                    footer: Text(message4)) {
                Picker(NSLocalizedString("Json Person option", comment: "JsonPersonOptionSetting"), selection: $settingsStore.jsonPersonOptionSelected) {
                    ForEach(jsonPersonChoises, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationBarTitle(Text(NSLocalizedString("CloudKit save Persons option", comment: "JsonPersonOptionSetting")), displayMode: .inline)
        }
    }
}

struct JsonUserOptionSetting: View {
    var jsonUserChoises: [jsonUserOptions] = [.deaktivert, .aktivert]
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    var body: some View {
        Form {
            let message1 = NSLocalizedString("You must activate the ", comment: "JsonUserOptionSetting")
            let message2 = NSLocalizedString("CloudKit save User option", comment: "JsonUserOptionSetting")
            let message3 = NSLocalizedString(" to be able to update the User table in CloudKit.", comment: "JsonUserOptionSetting")
            let message4 = message1 + "\"" + message2 + "\"" + message3
            Section(header: Text(NSLocalizedString("CLOUDKIT SAVE USER OPTION", comment: "JsonUserOptionSetting")),
                    footer: Text(message4)) {
                Picker(NSLocalizedString("Json User option", comment: "JsonUserOptionSetting"), selection: $settingsStore.jsonUserOptionSelected) {
                    ForEach(jsonUserChoises, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .navigationBarTitle(Text(NSLocalizedString("CloudKit save User option", comment: "JsonUserOptionSetting")), displayMode: .inline)
        }
    }
}
