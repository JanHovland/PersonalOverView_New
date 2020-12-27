//
//  PersonBirthdayView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 10/10/2020.
//

import SwiftUI
import CloudKit

struct PersonBirthdayView: View {
    
    /// Skjuler scroll indicators.
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var persons = [Person]()
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    let barTitle = NSLocalizedString("Birthday", comment: "PersonBirthdayView")
    @State private var searchText: String = ""
    @State private var indicatorShowing = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    /// ActivityIndicator setter opp en ekstra tom linje for seg selv
                    ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                }
                .padding(.top, 10)
                .padding(.bottom, -20)
                SearchBar(text: $searchText)
                    .keyboardType(.asciiCapable)
                    .padding(.top, 20)
                List {
                    ForEach(persons.filter({ searchText.isEmpty ||
                                            $0.firstName.localizedStandardContains (searchText)    })) {
                        person in
                        NavigationLink(destination: PersonView(person: person)) {
                            showPersonBirthday(person: person)
                        }
                    }
                }
                /// Noen ganger kan det være lurt å legge .id(UUID()) på List for hurtig oppdatering
                /// .id(UUID())
            }
            .navigationBarTitle(Text(barTitle) , displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        ReturnFromMenuView(text: NSLocalizedString("SignInView", comment: "PersonBirthdayView"))
                                    })
                                , trailing:
                                    Button(action: {
                                        refresh()
                                    }, label: {
                                        Text("Refresh")
                                            .font(Font.headline.weight(.light))
                                    })
            )
            
        }
        .onAppear {
            refresh()
        }
    }
    
    /// Rutine for å friske opp bildet
    func refresh() {
        /// Sletter alt tidligere innhold i person
        persons.removeAll()
        /// Fetch all persons from CloudKit
        let predicate = NSPredicate(value: true)
        CloudKitPerson.fetchPerson(predicate: predicate)  { (result) in
            switch result {
            case .success(let person):
                persons.append(person)
                /// Sortering
                persons.sort(by: {$0.firstName < $1.firstName})
                persons.sort(by: {$0.dateMonthDay < $1.dateMonthDay})
                
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }
    
    /// Et eget View for å vise person detail view
    struct showPersonBirthday: View {
        
        var person: Person
        
        @State private var message: String = ""
        @State private var alertIdentifier: AlertID?
        @State private var sendMail = false
        
        /* Dato formateringer:
         Wednesday, Feb 26, 2020            EEEE, MMM d, yyyy
         02/26/2020                         MM/dd/yyyy
         02-26-2020 12:30                   MM-dd-yyyy HH:mm
         Feb 26, 12:30 PM                   MMM d, h:mm a
         February 2020                      MMMM yyyy
         Feb 26, 2020                       MMM d, yyyy
         Wed, 26 Feb 2020 12:30:24 +0000    E, d MMM yyyy HH:mm:ss Z
         2020-02-26T12:30:24+0000           yyyy-MM-dd'T'HH:mm:ssZ
         26.02.20                           dd.MM.yy
         12:30:24.423                       HH:mm:ss.SSS
         */
        
        static let taskDateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.dateFormat = "dd. MMMM"
            return formatter
        }()
        
        var age: String {
            /// Finner aktuell måned
            let currentDate = Date()
            let nameFormatter = DateFormatter()
            nameFormatter.dateFormat = "yy"
            let year = Calendar.current.component(.year, from: currentDate)
            
            /// Finner måned fra personen sin fødselsdato
            let personDate = person.dateOfBirth
            let personFormatter = DateFormatter()
            personFormatter.dateFormat = "yy"
            let yearPerson = Calendar.current.component(.year, from: personDate)
            
            return String(year - yearPerson)
        }
        
        var colour: Color {
            /// Finner aktuell måned
            let currentDate = Date()
            let nameFormatter = DateFormatter()
            nameFormatter.dateFormat = "MMMM"
            let month = Calendar.current.component(.month, from: currentDate)
            
            /// Finner måned fra personen sin fødselsdato
            let personDate = person.dateOfBirth
            let personFormatter = DateFormatter()
            personFormatter.dateFormat = "MMMM"
            let monthPerson = Calendar.current.component(.month, from: personDate)
            
            /// Endrer bakgrunnsfarge dersom personen er født i inneværende måned
            if monthPerson == month {
                return Color(.systemGreen)
            }
            return Color(.clear)
        }
        
        var body: some View {
            HStack (spacing: 10) {
                if person.image != nil {
                    Image(uiImage: person.image!)
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
                Text("\(person.dateOfBirth, formatter: showPersonBirthday.taskDateFormat)")
                    .background(colour)
                    .font(.custom("Andale Mono Normal", size: 16))
                Text(age)
                    .foregroundColor(.accentColor)
                Text(person.firstName)
                    .font(Font.body.weight(.ultraLight))
                Spacer(minLength: 5)
                Image("message")
                    /// Formatet er : tel:<phone><&body>
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                    .gesture(
                        TapGesture()
                            .onEnded({ _ in
                                if person.phoneNumber.count > 0 {
                                    personSendSMS(person: person)
                                } else {
                                    message = NSLocalizedString("Missing phonenumber", comment: "PersonBirthdayView")
                                    alertIdentifier = AlertID(id: .first)
                                }
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
                    return Alert(title: Text(message))
                }
            }
        }
    }
    
}
