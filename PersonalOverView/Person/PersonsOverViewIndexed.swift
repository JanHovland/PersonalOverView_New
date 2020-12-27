//
//  PersonsOverViewIndexed.swift
//  Shared
//
//  Created by Jan Hovland on 01/12/2020.
//

// Original article here: https://www.fivestars.blog/code/section-title-index-swiftui.html

import SwiftUI
import CloudKit
import MapKit

struct PersonsOverViewIndexed: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()

    @State private var searchText: String = ""
    @State private var persons = [Person]()
    @State private var sectionHeader = [String]()
    @State private var indexSetDelete = IndexSet()
    @State private var recordID: CKRecord.ID?
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false
    
    @State private var cityNumber: String = ""
    @State private var city: String = ""
    @State private var municipalityNumber: String = ""
    @State private var municipality: String = ""
    
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
                            .padding(.top, 20)
                        /// ActivityIndicator setter opp en ekstra tom linje for seg selv
                        
                        ForEach(sectionHeader, id: \.self) { letter in
                            Section(header: SectionHeader(letter: letter)) {
                                /// Her er kopligen mellom letter pg person
                                ForEach(persons.filter( {
                                    (person) -> Bool in
                                    person.firstName.prefix(1) == letter
                                })
                                )
                                { person in
                                    NavigationLink(destination: PersonView(person: person)) {
                                        ShowPerson(deletePerson: true, person: person)
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
                            return Alert(title: Text(message))
                            
                        }
                    }
                    .navigationBarTitle(NSLocalizedString("Persons Overview", comment: "PersonsOverViewIndexed"), displayMode: .inline)
                    .navigationBarItems(leading:
                                            Button(action: {
                                                /// Rutine for å friske opp personoversikten
                                                refreshPersonsIndexed()
                                            }, label: {
                                                Text("Refresh")
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
                                                    /// Rutine for å legge til en person
                                                    person_New_View()
                                                }, label: {
                                                    Text("Add")
                                                        .font(Font.headline.weight(.light))
                                                })
                                            }
                    )
                    
                } /// ScrollView
                .overlay(sectionIndexTitles(proxy: proxy,
                                            titles: sectionHeader))
            } /// ScrollViewReader
            .padding(.leading, 5)
        } // NavigationView
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        .onAppear{
            indicatorShowing = true
            refreshPersonsIndexed()
            indicatorShowing = false
        }
    } /// Body
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .newPerson {
            PersonNewView()
        } else if sheet.state == .postNummerIndexed {
            PersonFindPostalCodesViewIndexed(city: $city,
                                             cityNumber: $cityNumber,
                                             municipalityNumber: $municipalityNumber,
                                             municipality: $municipality)
        } else {
            EmptyView()
        }
    }
    
    func person_New_View() {
        sheet.state = .newPerson
    }
    
    func person_Postal_Codes_View_Indexed() {
        sheet.state = .postNummerIndexed
    }
    
    /// Rutine for å friske opp bildet
    func refreshPersonsIndexed() {
        var char = ""
        /// Sletter alt tidligere innhold i person
        persons.removeAll()
        /// slette alt innhold i sectionHeader[]
        sectionHeader.removeAll()
        /// Fetch all persons from CloudKit
        /// llet predicate = NSPredicate(value: true)
        let predicate = NSPredicate(format:"firstName BEGINSWITH %@", searchText)
        CloudKitPerson.fetchPerson(predicate: predicate)  { (result) in
            switch result {
            case .success(let person):
                /// Tester på searchText
                if searchText.isEmpty ||
                    person.firstName.localizedCaseInsensitiveContains (searchText) {
                    /// finner første bokstaven i firstName
                    char = String(person.firstName.prefix(1))
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
                    persons.append(person)
                    persons.sort(by: {$0.firstName < $1.firstName})
                }
            case .failure(let err):
                let _ = err.localizedDescription
            }
        }
    }

}
    
