//
//  FindPostNummer.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/10/2020.
//

import SwiftUI
import CloudKit

struct FindPostNummer: View {

    var city: String
    @Binding var cityNumber: String
    @Binding var municipalityNumber: String
    @Binding var municipality: String

    @Environment(\.presentationMode) var presentationMode

    @State private var postNumre = [PostNummer]()
    @State private var selection = 0
    @State private var pickerVisible = false
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    
    var defaultWheelPickerItemHeight = 6  /// Ser ikke ut til å ha noen innvirkning

    var body: some View {
        VStack {
            Spacer(minLength: 40)
            Text("Velg postnummer")
                .font(.title)
            Spacer()
            List {
                HStack {
                    Text(city)
                    Spacer()
                    if postNumre.count > 0 {
                        Button(postNumre[selection].postalNumber) {
                            pickerVisible.toggle()
                        }
                        .foregroundColor(pickerVisible ? .red : .blue)
                    }
                }
                if pickerVisible {
                    Picker(selection: $selection, label: EmptyView()) {
                        ForEach((0..<postNumre.count), id: \.self) { ix in
                            HStack (alignment: .center) {
                                Text(postNumre[ix].postalNumber).tag(ix)
                            }
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                        /// Denne sørger for å vise det riktige "valget" pålinje 2
                        .id(UUID().uuidString)
                        .onTapGesture {
                            /// postNumre oblir resatt av: .onAppear
                            if postNumre[selection].postalNumber.count > 0,
                               postNumre[selection].municipalityNumber.count > 0,
                               postNumre[selection].municipalityName.count > 0 {
                               cityNumber = postNumre[selection].postalNumber
                               municipalityNumber = postNumre[selection].municipalityNumber
                               municipality = postNumre[selection].municipalityName.lowercased()
                               municipality = municipality.capitalizingFirstLetter()
                            }
                            pickerVisible.toggle()
                            selection = 0
                            /// Avslutter bildet
                            presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationBarTitle("Postnummer", displayMode: .inline)
        .onAppear {
            if city.count > 0 {
                zoomPostNummer(value: city)
            } else {
                message = NSLocalizedString("You must enter a city", comment: "FindPostNummerNewPerson")
                alertIdentifier = AlertID(id: .first)
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
        .overlay(
            HStack {
                Spacer()
                VStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.none)
                    })
                        .padding(.trailing, 20)
                        .padding(.top, 47)
                    Spacer()
                }
            }
        )
    }

    /// Rutine for å finne postnummeret
    func zoomPostNummer(value: String) {
        /// Sletter alt tidligere innhold
        postNumre.removeAll()
        /// Dette predicate gir følgende feilmelding: Your request contains 4186 items which is more than the maximum number of items in a single request (400)
        /// Dersom operation.resultsLimit i CloudKitPostNummer er for høy verdi 500 er OK
        /// let predicate = NSPredicate(value: true)
        /// Dette predicate gir ikke noen feilmelding
        let predicate = NSPredicate(format: "postalName == %@", value.uppercased())
        /// Dette predicate gir ikke noen feilmelding
        /// let predicate = NSPredicate(format:"postalName BEGINSWITH %@", value.uppercased())
        CloudKitPostNummer.fetchPostNummer(predicate: predicate) { (result) in
            switch result {
            case .success(let postNummer):
                /// S = Servicepostnummer (disse postnumrene er ikke i bruk til postadresser)
                if postNummer.category != "S" {
                    postNumre.append(postNummer)
                    /// Sortering
                    postNumre.sort(by: {$0.postalName < $1.postalName})
                    postNumre.sort(by: {$0.postalNumber < $1.postalNumber})
                }
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    }

}

/// Funksjon for å sette første bokstav til uppercase
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
}


