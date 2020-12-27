//
//  PersonalOverViewApp.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 21/09/2020.
//

import SwiftUI

@main
struct PersonalOverViewApp: App {
    var body: some Scene {
        WindowGroup {
            PersonalOverView().environmentObject(User()).environmentObject(PersonInfo())
        }
    }
}
