//
//  PersonsOverView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/10/2020.
//

import SwiftUI
import CloudKit
import MapKit

struct PersonsOverView: View {
    
    /// Map: /
    /// https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html#//apple_ref/doc/uid/TP40007899-CH5-SW1

    /// Skjuler scroll indicators.
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var searchText: String = ""
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var persons = [Person]()
    @State private var personsOverview = NSLocalizedString("Persons overview", comment: "PersonsOverView")
    @State private var indexSetDelete = IndexSet()
    @State private var recordID: CKRecord.ID?
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
                List  {
                    /// Søker etter personer som inneholder $searchText i for- eller etternavnet
                    ForEach(persons.filter({ searchText.isEmpty ||
                                            $0.firstName.localizedStandardContains (searchText)    })) {
                        person in
                        NavigationLink(destination: PersonView(person: person)) {
                            ShowPerson(deletePerson: false,
                                       person: person)
                        }
                    }
                    /// Sletter  valgt person og oppdaterer CliudKit
                    .onDelete { (indexSet) in
                        indexSetDelete = indexSet
                        recordID = persons[indexSet.first!].recordID
                        title = NSLocalizedString("Delete person", comment: "PersonsOverView")
                        message = NSLocalizedString("Are you sure you want to delete this person?", comment: "PersonsOverView")
                        choise = NSLocalizedString("Delete this person", comment: "PersonsOverView")
                        result = NSLocalizedString("Successfully deleted a person", comment: "PersonsOverView")
                        /// Starte ActivityIndicator
                        indicatorShowing = true
                        /// Aktivere alert
                        alertIdentifier = AlertID(id: .third )
                    }
                }
                /// Fjerner ekstra tomt felt med tilhørede linje
                .listStyle(InsetListStyle())
            }
            .navigationBarTitle(personsOverview, displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        /// Rutine for å friske opp personoversikten
                                        refresh()
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
                                        Button(action: {
                                            /// Rutine for å legge til en person
                                            new_Person_View()
                                        }, label: {
                                            Text("Add")
                                                .font(Font.headline.weight(.light))
                                        })
                                    }
            )
        }
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
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
                                                            CloudKitPerson.deletePerson(recordID: recordID!) { (res) in
                                                                switch res {
                                                                case .success :
                                                                    /// Starte ActivityIndicator
                                                                    indicatorShowing = false
                                                                    message = result
                                                                    alertIdentifier = AlertID(id: .first)
                                                                case .failure(let err):
                                                                    message = err.localizedDescription
                                                                    alertIdentifier = AlertID(id: .first)
                                                                }
                                                            }
                                                            /// Sletter den valgte raden
                                                            persons.remove(atOffsets: indexSetDelete)
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "PersonsOverView"))))
            }
        }
        .onAppear {
            refresh()
        }
        /// Ta bort tastaturet når en klikker utenfor feltet
        .modifier(DismissingKeyboard())
        /// Flytte opp feltene slik at keyboard ikke skjuler aktuelt felt
        .modifier(AdaptsToSoftwareKeyboard())
    }
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .newPerson {
            PersonNewView()
        } else {
            EmptyView()
        }
    }
    
    func new_Person_View() {
        sheet.state = .newPerson
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
                persons.sort(by: {$0.firstName < $1.firstName})
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }
    
}

/// Et eget View for å vise person detail view
struct ShowPerson: View {
    var deletePerson: Bool
    var person: Person
    
    @ObservedObject var sheet = SettingsSheet()
    @EnvironmentObject var personInfo: PersonInfo
    
    static let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var showMap = false
    @State private var locationOnMap: String = ""
    @State private var address: String = ""
    @State private var subtitle: String = ""
    @State private var makePhoneCall = false
    @State private var greeting = ""
    @State private var mailSubject = ""
    @State private var mailBody = ""
    @State private var showEmail = false
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                if person.image != nil {
                    Image(uiImage: person.image!)
                        .resizable()
                        .frame(width: 50, height: 50, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .font(.system(size: 16, weight: .ultraLight, design: .serif))
                        .frame(width: 50, height: 50, alignment: .center)
                }
                VStack (alignment: .leading, spacing: 5) {
                    Text(person.firstName)
                        .font(Font.title.weight(.ultraLight))
                    Text(person.lastName)
                        .font(Font.body.weight(.ultraLight))
                    Text("\(person.dateOfBirth, formatter: ShowPerson.taskDateFormat)")
                        .font(.custom("system", size: 17))
                    HStack {
                        Text(person.address)
                            .font(.custom("system", size: 17))
                    }
                    HStack {
                        Text(person.cityNumber)
                        Text(person.city)
                    }
                    .font(.custom("system", size: 17))
                }
            } /// HStack
            HStack(alignment: .center, spacing:  deletePerson ? 20 : 30) {
                if deletePerson {
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .resizable()
                        .frame(width: 36, height: 32)
                        .font(Font.title.weight(.ultraLight))
                        .foregroundColor(.red)
                        .gesture(
                            TapGesture()
                                .onEnded({_ in
                                    /// Rutine for å slette en person
                                    person_Delete_View()
                                })
                        )
                }
                Image("map")
                    .resizable()
                    .frame(width: 36, height: 36, alignment: .center)
                    .gesture(
                        TapGesture()
                            .onEnded({_ in
                                /// https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html#//apple_ref/doc/uid/TP40007899-CH5-SW1
                                mapAddress(address: person.address,
                                           cityNumber: person.cityNumber,
                                           city: person.city)
                            })
                    )
                Image("phone")
                    /// Formatet er : tel:<phone>
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                    .gesture(
                        TapGesture()
                            .onEnded({_ in
                                if person.phoneNumber.count >= 8 {
                                    /// 1: Eventuelle blanke tegn må fjernes
                                    /// 2: Det ringes ved å kalle UIApplication.shared.open(url)
                                    let prefix = "tel:"
                                    let phoneNumber1 = prefix + person.phoneNumber
                                    let phoneNumber = phoneNumber1.replacingOccurrences(of: " ", with: "")
                                    guard let url = URL(string: phoneNumber) else { return }
                                    UIApplication.shared.open(url)
                                } else {
                                    message = NSLocalizedString("Missing phonenumber", comment: "ShowPersons")
                                    alertIdentifier = AlertID(id: .first)
                                }
                            })
                    )
                Image("message")
                    /// Formatet er : tel:<phone><&body>
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)
                    .gesture(
                        TapGesture()
                            .onEnded({ _ in
                                if person.phoneNumber.count >= 8 {
                                    personSendSMS(person: person)
                                } else {
                                    message = NSLocalizedString("Missing phonenumber", comment: "ShowPersons")
                                    alertIdentifier = AlertID(id: .first)
                                }
                            })
                    )
                Image("mail")
                    .resizable()
                    .frame(width: 36, height: 36, alignment: .center)
                    .gesture(
                        TapGesture()
                            .onEnded({ _ in
                                if person.personEmail.count > 5 {
                                    /// Lagrer personens navn og e-post adresse i @EnvironmentObject personInfo
                                    personInfo.email = person.personEmail
                                    personInfo.name = person.firstName
                                    person_Send_Email_View()
                                } else {
                                    message = NSLocalizedString("Missing personal email", comment: "ShowPersons")
                                    alertIdentifier = AlertID(id: .first)
                                }
                            })
                    )
            } /// HStack
            .padding(.leading, 57)
        } /// VStack
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
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        /// Ta bort tastaturet når en klikker utenfor feltet
        .modifier(DismissingKeyboard())
    } /// body
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .email {
            PersonSendEmailView()
        } else if sheet.state == .personDelete {
            PersonDeleteView(person: person)
        }
        else {
            EmptyView()
        }
    }
    
    /// Her legges det inn aktuelle sheet.state
    func person_Send_Email_View() {
        sheet.state = .email
    }
    
    func person_Delete_View() {
        sheet.state = .personDelete
    }
    
} /// struct

func textDeleteFirstEmoji(firstName : String) -> some View {
    let index0 = firstName.index(firstName.startIndex, offsetBy: 0)
    let index1 = firstName.index(firstName.startIndex, offsetBy: 1)
    
    let firstChar = String(firstName[index0...index0])
    
    if firstChar.containsEmoji  {
        return Text(firstName[index1...])
    }
    
    return Text(firstName)
}

/// The simplest, cleanest, and swiftiest way to accomplish this is to simply check the Unicode code points for each character in the string against known emoji and dingbats ranges, like so:
extension String {
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
}

func mapAddress (address: String,
                 cityNumber: String,
                 city: String) {
    let b = "http://maps.apple.com/?address=" + address + " "
        + cityNumber + " "
        + city + " " + "&t=s"
    let a = b.replacingOccurrences(of: " ", with: ",")
    UIApplication.shared.open(URL(string: a)!)
}

