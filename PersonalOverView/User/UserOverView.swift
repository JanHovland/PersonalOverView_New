//
//  UserOverView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 24/09/2020.
//

import SwiftUI
import CloudKit

struct UserOverView: View {
    
    /// Skjuler scroll indicators.
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    @Environment(\.presentationMode) var presentationMode
    @State private var UserOverView = NSLocalizedString("UserOverView", comment: "UserOverView")
    
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
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .keyboardType(.asciiCapable)
                    .padding(.top, 10)
                   .padding(.bottom, 10)
                  List {
                    ForEach(users.filter({ searchText.isEmpty ||
                                            $0.name.localizedStandardContains (searchText) })) {
                        user in
                        NavigationLink(destination: UserDetailOverView(userRecord: user)) {
                            showUsers(user: user)
                        }
                    }
                    .onDelete { (indexSet) in
                        indexSetDelete = indexSet
                        recordID = users[indexSet.first!].recordID
                        title = NSLocalizedString("Delete User?", comment: "UserOverView")
                        message = NSLocalizedString("If you delete this user, if not available anymore.", comment: "UserOverView")
                        choise = NSLocalizedString("Delete this user", comment: "UserOverView")
                        result = NSLocalizedString("Successfully deleted this user", comment: "UserOverView")
                        alertIdentifier = AlertID(id: .third)
                    }
                    Spacer()
                }
            }
            /// Fjerner ekstra tomt felt med tilhørede linje
            .listStyle(InsetListStyle())
            .navigationBarTitle(UserOverView, displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        /// Rutine for å friske opp bruker oversikten
                                        refreshUsers()
                                    }, label: {
                                        Text(NSLocalizedString("Refresh", comment: "UserOverView"))
                                            .font(Font.headline.weight(.light))
                                    })
                                , trailing:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        Image(systemName: "chevron.down.circle.fill")
                                    })
            )
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(message))
            case .third:
                return Alert(title: Text(title),
                             message: Text(message),
                             primaryButton: .destructive(Text(choise),
                                                         action: {
                                                            CloudKitUser.deleteUser(recordID: recordID!) { (result) in
                                                                switch result {
                                                                case .success :
                                                                    message = NSLocalizedString("Successfully deleted an user", comment: "UserOverView")
                                                                    alertIdentifier = AlertID(id: .first)
                                                                case .failure(let err):
                                                                    message = err.localizedDescription
                                                                    alertIdentifier = AlertID(id: .first)
                                                                }
                                                            }
                                                            /// Sletter den valgte raden
                                                            users.remove(atOffsets: indexSetDelete)
                                                            
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "PersonsOverView"))))
            }
        }
        .onAppear(perform: {
            refreshUsers()
        })
    }
    
    func refreshUsers() {
        /// Sletter alt tidligere innhold i person
        users.removeAll()
        /// Fetch all persons from CloudKit
        let predicate = NSPredicate(value: true)
        CloudKitUser.fetchUser(predicate: predicate)  { (result) in
            switch result {
            case .success(let user):
                users.append(user)
                /// Sortering
                users.sort(by: {$0.name < $1.name})
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }
    
    struct showUsers: View {
        var user: UserRecord
        
        var body: some View {
            HStack (spacing: 10) {
                if user.image != nil {
                    Image(uiImage: user.image!)
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
                Text(user.name)
                Spacer(minLength: 5)
            }
            .padding(5)
        }
    }
}

