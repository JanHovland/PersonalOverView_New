//
//  UserOverViewIndexed.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 13/12/2020.
//

import SwiftUI
import CloudKit

struct UserOverViewIndexed: View {
    
    /// Skjuler scroll indicators.
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var UserOverView = NSLocalizedString("UserOverView", comment: "UserOverViewIndexed")
    
    @State private var users = [UserRecord]()
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var indexSetDelete = IndexSet()
    @State private var recordID: CKRecord.ID?
    @State private var indicatorShowing = false
    @State private var searchText: String = ""
    @State private var sectionHeader = [String]()
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack (alignment: .center) {
                        ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, -20)
                    LazyVStack (alignment: .leading) {
                        SearchBar(text: $searchText)
                            .keyboardType(.asciiCapable)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        ForEach(sectionHeader, id: \.self) { letter in
                            Section(header: SectionHeader(letter: letter)) {
                                /// Her er kopligen mellom letter pg person
                                ForEach(users.filter( {
                                    (user) -> Bool in
                                    user.name.prefix(1) == letter
                                })
                                )
                                { user in
                                    NavigationLink(destination: UserView(user: user)) {
                                        ShowUser(deleteUser: true,
                                                 user1: user)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                            .font(Font.system(.body).bold())
                            .padding(.top,2)
                            .padding(.leading,5)
                            .padding(.bottom,2)
                        }
                    }
                    .alert(item: $alertIdentifier) { alert in
                        switch alert.id {
                        case .first:
                            return Alert(title: Text(message))
                        case .second:
                            return Alert(title: Text(message))
                        case .third:
                            return Alert(title: Text(title))
                        }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarTitle(UserOverView, displayMode: .inline)
                    .navigationBarItems(leading:
                                            Button(action: {
                                                /// Rutine for å friske opp bruker oversikten
                                                refreshUsersIndexed()
                                            }, label: {
                                                Text(NSLocalizedString("Refresh", comment: "UserOverViewIndexed"))
                                                    .font(Font.headline.weight(.light))
                                            })
                                        , trailing:
                                            LazyHStack {
                                                Button(action: {
                                                    presentationMode.wrappedValue.dismiss()
                                                }, label: {
                                                    Image(systemName: "chevron.down.circle.fill")
                                                })
                                                Button(action: {
                                                    sign_Up_View()
                                                }, label: {
                                                    Text(NSLocalizedString("New user", comment: "UserOverViewIndexed"))
                                                        .font(Font.headline.weight(.light))
                                                })
                                            }
                    )
                } /// ScrollView
                .overlay(sectionIndexTitles(proxy: proxy,
                                            titles: sectionHeader))
            } // ScrollViewReader
            .padding(.leading, 5)
        } // NavigationView
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        .onAppear(perform: {
            refreshUsersIndexed()
        })
    } /// Body
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .signUp {
            SignUpView(returnSignIn: false)
        } else {
            EmptyView()
        }
    }
    
    func sign_Up_View() {
        sheet.state = .signUp
    }
    
    func refreshUsersIndexed() {
        var char = ""
        /// Sletter alt tidligere innhold i users
        users.removeAll()
        sectionHeader.removeAll()
        /// Fetch all persons from CloudKit
        /// let predicate = NSPredicate(value: true)
        let predicate = NSPredicate(format:"name BEGINSWITH %@", searchText)
        CloudKitUser.fetchUser(predicate: predicate)  { (result) in
            switch result {
            case .success(let user):
                if searchText.isEmpty ||
                    user.name.localizedCaseInsensitiveContains(searchText) {
                    /// finner første bokstaven i name
                    char = String(user.name.prefix(1))
                    /// Oppdatere sectionHeader[]
                    if sectionHeader.contains(char) == false {
                        sectionHeader.append(char)
                        /// Dette må gjøre for å få sectionHeader riktig sortert
                        /// Standard sortering gir ikke norsk sortering
                        let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
                        let language = Locale(identifier: region!)
                        let sectionHeader1 = sectionHeader.sorted {
                            $0.compare($1, locale: language) == .orderedAscending
                        }
                        sectionHeader = sectionHeader1
                    }
                    users.append(user)
                    users.sort(by: {$0.name < $1.name})
                }
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }
    
    
}

struct ShowUser: View {
    var deleteUser: Bool
    var user1: UserRecord
    
    @ObservedObject var sheet = SettingsSheet()
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .center, spacing: 20) {
                if deleteUser{
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .font(Font.title.weight(.ultraLight))
                        .foregroundColor(.red)
                        .gesture(
                            TapGesture()
                                .onEnded({_ in
                                    /// Rutine for å slette en bruker
                                    user_Delete_View()
                                })
                        )
                        .padding(.trailing, 10)
                }
                if user1.image != nil {
                    Image(uiImage: user1.image!)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .font(.system(size: 16, weight: .ultraLight))
                        .frame(width: 30, height: 30, alignment: .center)
                }
                
                VStack (alignment: .leading, spacing: 5) {
                    Text(user1.name)
                        .font(Font.title.weight(.ultraLight))
                    Text(user1.email)
                        .font(Font.body.weight(.ultraLight))
                }
                Spacer()
            } /// VStack
            .padding(5)
        } /// body
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        /// Her legges det inn knytning til aktuelle view
        
    } // struct
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .userDelete {
            UserDeleteView(user1: user1)
        } else if sheet.state == .signUp {
            SignUpView(returnSignIn: false)
        } else {
            EmptyView()
        }
    }
    
    /// Her legges det inn aktuelle sheet.state
    func user_Delete_View() {
        sheet.state = .userDelete
    }
}
