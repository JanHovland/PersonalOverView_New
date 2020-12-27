//
//  SettingStore.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI
import Combine

final class SettingsStore: ObservableObject {
    /// Passord
    let showPasswordIsActivate = PassthroughSubject<Void, Never>()
    
    var showPasswordActivate: Bool = UserDefaults.showPassword {
        willSet {
            UserDefaults.showPassword = newValue
            showPasswordIsActivate.send()
        }
    }
    
    /// Melding
    let smsOption = PassthroughSubject<Void, Never>()
    
    var smsOptionSelected: smsOptions = UserDefaults.smsOption {
        willSet {
            UserDefaults.smsOption = newValue
            smsOption.send()
        }
    }
    
    /// e-post
    let eMailOption = PassthroughSubject<Void, Never>()
    
    var eMailOptionSelected: eMailOptions = UserDefaults.eMailOption {
        willSet {
            UserDefaults.eMailOption = newValue
            eMailOption.send()
        }
    }
    
    /// Json Firebase
    let jsonFirebaseOption = PassthroughSubject<Void, Never>()
    
    var jsonFirebaseOptionSelected: jsonFirebaseOptions = UserDefaults.jsonFirebaseOption {
        willSet {
            UserDefaults.jsonFirebaseOption = newValue
            jsonFirebaseOption.send()
        }
    }
    
    /// Json Person
    let jsonPersonOption = PassthroughSubject<Void, Never>()
    
    var jsonPersonOptionSelected: jsonPersonOptions = UserDefaults.jsonPersonOption {
        willSet {
            UserDefaults.jsonPersonOption = newValue
            jsonPersonOption.send()
        }
    }
    
    /// Json User
    let jsonUserOption = PassthroughSubject<Void, Never>()
    
    var jsonUserOptionSelected: jsonUserOptions = UserDefaults.jsonUserOption {
        willSet {
            UserDefaults.jsonUserOption = newValue
            jsonUserOption.send()
        }
    }
}

