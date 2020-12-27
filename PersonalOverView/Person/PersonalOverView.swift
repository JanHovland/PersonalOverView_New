//
//  PeronalOverView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 21/09/2020.
//

/// Det hender at det tar vekdug lang tid fra Build Succeeded til applikasjonen vises på iPhone eller iPad:
/// 🟢  Slå av iMac
/// 🟢  Start Clean My Mac X og kjør System Junc
///    Pass på at det ikke ligger noe igjen for Xcode
///    Sjekk Hung Applications og Heavy Consumers
/// 🟢   Det ser ikke ut at Adobe forårsaker tregheten

import SwiftUI

struct PersonalOverView: View {
    
    var body: some View {
        LazyVStack {
            SignInView()
        }
    }
}

   
//    @State private var selection = 0
//
//    var body: some View {
//        TabView(selection: $selection) {
//            SignInView()
//                .tabItem {
//                    Image(systemName: "keyboard")
//                    Text(NSLocalizedString("SignInView", comment: "SignInView"))
//                }
//                .tag(0)
//
//            SettingView()
//                .tabItem {
//                    Image(systemName: "gear")
//                    Text(NSLocalizedString("Settings", comment: "SignInView"))
//                }
//                .tag(1)
//
//            PersonBirthdayView()
//                .tabItem {
//                    Image(systemName: "gift")
//                    Text(NSLocalizedString("PersonBirthday", comment: "SignInView"))
//                }
//                .tag(2)
//
//            PersonsOverViewIndexed()
//                .tabItem {
//                    Image(systemName: "person.2")
//                    Text(NSLocalizedString("Qwerty_PersonsOverview", comment: "SignInView"))
//                }
//                .tag(3)
//
//            UserOverViewIndexed()
//                .tabItem {
//                    Image(systemName: "rectangle.stack.person.crop")
//                    Text(NSLocalizedString("Account overview", comment: "SignInView"))
//                }
//                .tag(4)
//        }
//        // .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
//        // .tabViewStyle(PageTabViewStyle())
//        // .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//    }
//}


