//
//  SettingsSheet.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 24/09/2020.
//

import SwiftUI

class SettingsSheet: SheetState<SettingsSheet.State> {
    enum State {
        case acountOverview              /// Dprecated
        case acountOverviewIndexed
        case email
        case imagePicker
        case imagePickerVer01
        case imageSelect
//        case mapView
        case personDelete
        case newPerson
        case newUser
        case personBirthday
        case personsOverview             /// Deprecated
        case personsOverviewIndexed
        case personPostalCodeIndexed
        case postNummer
        case postNummerIndexed
        case settings
        case signUp
        case toDo
        case userDelete
    }
}
