//
//  UserDefaults.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 16/11/2020.
//

import SwiftUI

extension UserDefaults {
    
    /// Passord
    static var showPassword: Bool {
        get { return UserDefaults.standard.bool(forKey: "showPassword") }
        set { UserDefaults.standard.set(newValue, forKey: "showPassword") }
    }
    
    /// Melding
    static var smsOption: smsOptions {
        
        get {
            if let smsOptionValue = UserDefaults.standard.string(forKey: "smsOptionSelected"),
               let type = smsOptions(rawValue: smsOptionValue) {
                return type
            } else {
                return smsOptions(rawValue: "Deaktivert")!
            }
        }
        
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "smsOptionSelected") }
    }
    
    /// e-post
    static var eMailOption: eMailOptions {
        
        get {
            if let eMailOptionValue = UserDefaults.standard.string(forKey: "eMailOptionSelected"),
               let type = eMailOptions(rawValue: eMailOptionValue) {
                return type
            } else {
                return eMailOptions(rawValue: "Deaktivert")!
            }
        }
        
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "eMailOptionSelected") }
    }
    
    /// json Firebase
    static var jsonFirebaseOption: jsonFirebaseOptions {
        
        get {
            if let jsonFirebaseOptionValue = UserDefaults.standard.string(forKey: "jsonFirebaseOptionSelected"),
               let type = jsonFirebaseOptions(rawValue: jsonFirebaseOptionValue) {
                return type
            } else {
                return jsonFirebaseOptions(rawValue: "Deaktivert")!
            }
        }
        
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "jsonFirebaseOptionSelected") }
    }
    
    /// json Person
    static var jsonPersonOption: jsonPersonOptions {
        
        get {
            if let jsonPersonOptionValue = UserDefaults.standard.string(forKey: "jsonPersonOptionSelected"),
               let type = jsonPersonOptions(rawValue: jsonPersonOptionValue) {
                return type
            } else {
                return jsonPersonOptions(rawValue: "Deaktivert")!
            }
        }
        
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "jsonPersonOptionSelected") }
    }
    
    /// json User
    static var jsonUserOption: jsonUserOptions {
        
        get {
            if let jsonUserOptionValue = UserDefaults.standard.string(forKey: "jsonUserOptionSelected"),
               let type = jsonUserOptions(rawValue: jsonUserOptionValue) {
                return type
            } else {
                return jsonUserOptions(rawValue: "Deaktivert")!
            }
        }
        
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "jsonUserOptionSelected") }
    }
    
}
