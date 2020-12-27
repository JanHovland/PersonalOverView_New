//
//  PersonPostalCodesViewIndexed.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 10/12/2020.
//

import SwiftUI
import CloudKit

struct PersonFindPostalCodesViewIndexed: View {
    
    @Binding var city: String
    @Binding var cityNumber: String
    @Binding var municipalityNumber: String
    @Binding var municipality: String
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var searchText: String = ""
    @State private var postalCodes = [PostNummer]()
    @State private var sectionHeader = [String]()
    @State private var indexSetDelete = IndexSet()
    @State private var recordID: CKRecord.ID?
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false
    
    let information = NSLocalizedString("Enter the first letters of a city and then press the 'Refresh' button.\n\nTap on a cell to return to the PersonsOverView with the selected values.", comment: "NSLocalizedString")
    
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
                        if searchText.isEmpty {
                            
                        } else {
                            /// ActivityIndicator setter opp en ekstra tom linje for seg selv
                            ForEach(sectionHeader, id: \.self) { letter in
                                Section(header: SectionHeader(letter: letter)) {
                                    /// Her er kopligen mellom letter pg person
                                    ForEach(postalCodes.filter( {
                                        (postalCode) -> Bool in
                                        postalCode.postalName.prefix(1) == letter
                                    })
                                    )
                                    { postalCode in
                                        ShowPostalCodes(postalCode: postalCode)
                                            .onTapGesture {
                                                city = postalCode.postalName
                                                cityNumber = postalCode.postalNumber
                                                municipalityNumber = postalCode.municipalityNumber
                                                municipality = postalCode.municipalityName
                                                presentationMode.wrappedValue.dismiss()
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
                        Text(information)
                            .padding()
                            .font(Font.callout.weight(.regular))
                            .foregroundColor(.accentColor)
                            .multilineTextAlignment(.leading)
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
                    .navigationBarTitle(NSLocalizedString("PostalCodeOverview", comment: "PersonPostalCodesViewIndexed"), displayMode: .inline)
                    .navigationBarItems(leading:
                                            Button(action: {
                                                /// Sletter alt tidligere innhold i PostalCode
                                                refreshPostalsCodeIndexed(searchText: searchText)
                                            }, label: {
                                                Text("Refresh")
                                                    .font(Font.headline.weight(.light))
                                            })
                                        , trailing:
                                            LazyHStack {
                                                /// Her må -sheet kalles på gamle måten. Er dette en feil FEIL??
                                                Button(action: {
                                                    presentationMode.wrappedValue.dismiss()
                                                }, label: {
                                                    Image(systemName: "chevron.down.circle.fill")
                                                })
                                            }
                    )
                    
                }
            }
        }
    }
    
    /// Rutine for å friske opp bildet med alle PostalCodes
    func refreshPostalsCodeIndexed (searchText: String) {
        var char = ""
        
        var array = [String]()
        /// Sletter alt tidligere innhold i PostalCodes
        postalCodes.removeAll()
        /// Sletter alt tidligere innhold i sectionHrader
        sectionHeader.removeAll()
        
        if searchText.isEmpty {
            return
        } else {
            array.removeAll()
            array.append(searchText)
        }
        
        for string in array {
            let predicate = NSPredicate(format:"postalName BEGINSWITH %@", string.uppercased())
            CloudKitPostNummer.fetchPostNummer(predicate: predicate)  { (result) in
                switch result {
                case .success(let postalCode):
                    /// Tester på searchText
                    if searchText.isEmpty ||
                        postalCode.postalName.localizedStandardContains (searchText) {
                        /// finner første bokstaven i postalName
                        char = String(postalCode.postalName.prefix(1))
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
                        postalCodes.append(postalCode)
                        /// På denne måten sorteres postalName med stigende postalNumber
                        /// AVALDSNES  4262
                        /// AVALDSNES  4299
                        postalCodes.sort(by: {$0.postalNumber < $1.postalNumber})
                        postalCodes.sort(by: {$0.postalName < $1.postalName})
                    }
                case .failure(let err):
                    let _ = err.localizedDescription
                }
            }
        }
    }
    
}

struct ShowPostalCodes: View {
    
    var postalCode: PostNummer
    
    var body: some View {
        HStack (alignment: .center) {
            Text(postalCode.postalName)
                .font(Font.callout.weight(.regular))
            Spacer(minLength: 10)
            Text(postalCode.postalNumber)
                .font(.custom("SF Mono Light", size: 17))
        }
        .padding(.leading, 10)
        .padding(.trailing, 50)
    }
}



