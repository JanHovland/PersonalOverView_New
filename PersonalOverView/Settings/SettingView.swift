//
//  SettingView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 24/09/2020.
//

import SwiftUI
import Combine

enum smsOptions: String, CaseIterable {
    case deaktivert = "Deaktivert"
    case aktivert = "Aktivert"
}

enum eMailOptions: String, CaseIterable {
    case deaktivert = "Deaktivert"
    case aktivert = "Aktivert"
}

enum jsonFirebaseOptions: String, CaseIterable {
    case deaktivert = "Deaktivert"
    case aktivert = "Aktivert"
}

enum jsonPersonOptions: String, CaseIterable {
    case deaktivert = "Deaktivert"
    case aktivert = "Aktivert"
}

enum jsonUserOptions: String, CaseIterable {
    case deaktivert = "Deaktivert"
    case aktivert = "Aktivert"
}

struct SettingView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showPassword: Bool = false
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    
    @State var smsChoises: [smsOptions] = [.deaktivert, .aktivert]
    @State var eMailChoises: [eMailOptions] = [.deaktivert, .aktivert]
    @State var jsonFirebaseChoises: [jsonFirebaseOptions] = [.deaktivert, .aktivert]
    @State var jsonPersonChoises: [jsonPersonOptions] = [.deaktivert, .aktivert]
    @State var jsonUserChoises: [jsonUserOptions] = [.deaktivert, .aktivert]
    
    var body: some View {
        NavigationView {
            Form {
                /// Vis passord av/på
                NavigationLink(destination: Password()) {
                    HStack {
                        Image(systemName: "lock.circle")
                            .resizable()
                            .frame(width: 29, height: 29)
                            .background(Color.red)
                            .imageScale(.medium)
                            .cornerRadius(5)
                        Text(NSLocalizedString("Password", comment: "SettingView"))
                    }
                }
                
                /// Oppdatere  postnummer
                NavigationLink(destination: PostNummerUpdate(alertIdentifier: $alertIdentifier)) {
                    HStack {
                        Image(systemName: "signpost.right.fill")
                            .resizable()
                            .frame(width: 29, height: 29)
                            .background(Color.blue)
                            .imageScale(.medium)
                            .cornerRadius(5)
                        Text("Postnummer")
                    }
                }
                
                Section(header: Text("E-Mail")) {
                    
                    /// Sette opsjon for e-post
                    NavigationLink(destination: EMailOptionSettings(eMailChoises: eMailChoises,
                                                                    settingsStore: settingsStore)) {
                        HStack {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color.blue)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString( "Email option", comment: "SettingView"))
                        }
                    }
                    
                    /// Sende e-post
                    NavigationLink(destination: SendMailView()) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .frame(width: 29, height: 29)
                                .background(Color.blue)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("Email", comment: "SettingView"))
                        }
                        
                    }
                    
                }
                
                Section(header: Text("MESSAGE")) {
                    
                    /// /// Sette opsjon for e-post
                    NavigationLink(destination: MessageOptionSetting(smsChoises: smsChoises,
                                                                     settingsStore: settingsStore)) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color.green)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("Message option", comment: "SettingView"))
                        }
                    }
                    
                    /// Sende melding
                    NavigationLink(destination: SendSMSView()) {
                        HStack {
                            Image(systemName: "bubble.left.fill")
                                .frame(width: 29, height: 29)
                                .background(Color.green)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("Message", comment: "SettingView"))
                        }
                    }
                }
                
                Section(header: Text("PERSONS AND CLOUDKIT")) {
                    
                    /// /// Sette opsjon for å lagre Person i CloudKit
                    NavigationLink(destination: JsonPersonOptionSetting(jsonPersonChoises: jsonPersonChoises,
                                                                        settingsStore: settingsStore)) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color.orange)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("CloudKit save Persons option", comment: "SettingView"))
                        }
                    }
                    
                    /// /// Slette alle personer i CloudKit
                    NavigationLink(destination: SwiftDeleteAllPersons()) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "filemenu.and.cursorarrow")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color.orange)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("CloudKit delete all Persons", comment: "SettingView"))
                        }
                    }
                    
                    NavigationLink(destination: SwiftReadCloudKitSaveCloudKitPerson()) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "filemenu.and.cursorarrow")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color.orange)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("CloudKit save Persons", comment: "SettingView"))
                        }
                    }
                    
                }
                
                Section(header: Text("USER AND CLOUDKIT")) {
                    
                    /// /// Sette opsjon for å lagre Person i CloudKit
                    NavigationLink(destination: JsonUserOptionSetting(jsonUserChoises: jsonUserChoises,
                                                                      settingsStore: settingsStore)) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color(red: 245/255, green: 216/255, blue: 59/255))
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("CloudKit save User option", comment: "SettingView"))
                        }
                    }
                    
                    /// /// Slette alle brukerne i CloudKit
                    NavigationLink(destination: SwiftDeleteAllUsers()) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "filemenu.and.cursorarrow")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color(red: 245/255, green: 216/255, blue: 59/255))
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("CloudKit delete all Users", comment: "SettingView"))
                        }
                    }
                    
                    /// Legge inn alle brukerne i CloudKit
                    NavigationLink(destination: SwiftReadCloudKitSaveCloudKitUser()) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "filemenu.and.cursorarrow")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color(red: 245/255, green: 216/255, blue: 59/255))
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("CloudKit save Users", comment: "SettingView"))
                        }
                    }
                    
                }
                
                
                Section(header: Text("FIREBASE PERSONS AND CLOUDKIT (DEPRECATED)")) {
                    
                    /// /// Sette opsjon for json Firebase
                    NavigationLink(destination: JsonFirebaseOptionSetting(jsonFirebaseChoises: jsonFirebaseChoises,
                                                                          settingsStore: settingsStore)) {
                        LazyHStack {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color.red)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("Firebase save Persons option", comment: "SettingView"))
                        }
                    }
                    
                    /// Må bare kjøres en gang
                    /// Lese fra Firebase sin Json fil og legge dataene inn i CloudKit
                    NavigationLink(destination: SwiftReadFireBaseSaveJson()) {
                        LazyHStack {
                            Image(systemName: "filemenu.and.cursorarrow")
                                .resizable()
                                .frame(width: 29, height: 29)
                                .background(Color.red)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("Firebase save Persons", comment: "SettingView"))
                        }
                    }
                    
                }
                
                Section(header: Text(NSLocalizedString("PERSON BACKUP TO JSON FILE", comment: "SettingView"))) {
                    
                    /// Backup fra CloudKit til Json Person fil
                    NavigationLink(destination: SwiftJsonPersonBackup()) {
                        HStack {
                            Image(systemName: "doc.plaintext.fill")
                                .frame(width: 29, height: 29)
                                .background(Color.purple)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("Person backup to Json file", comment: "SettingView"))
                        }
                    }
                }
                
                Section(header: Text(NSLocalizedString("USER BACKUP TO JSON FILE", comment: "SettingView"))) {
                    
                    /// Backup fra CloudKit til Json Person fil
                    NavigationLink(destination: SwiftJsonUserBackup()) {
                        HStack {
                            Image(systemName: "doc.plaintext.fill")
                                .frame(width: 29, height: 29)
                                .background(Color.purple)
                                .imageScale(.medium)
                                .cornerRadius(5)
                            Text(NSLocalizedString("User backup to Json file", comment: "SettingView"))
                        }
                    }
                }
            }
            
            .navigationBarTitle("Settings", displayMode:  .inline)
            .navigationBarItems(leading:
                                    HStack {
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            ReturnFromMenuView(text: NSLocalizedString("SignInView", comment: "SettingView"))
                                        })
                                    }
            )
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(NSLocalizedString("Slett postnummer", comment: "SettingView")),
                             message: Text(NSLocalizedString("Er du sikker på at du vil slette postnummer?", comment: "SettingView")),
                             primaryButton: .destructive(Text(NSLocalizedString("Yes", comment: "SettingView")),
                                                         action: {
                                                            CloudKitPostNummer.deleteAllPostNummer()
                                                         }),
                             secondaryButton: .cancel(Text(NSLocalizedString("No", comment: "SettingView"))))
            case .third:
                return Alert(title: Text(NSLocalizedString("Lagre Postnummer", comment: "SettingView")),
                             message: Text(NSLocalizedString("Er du sikker på at du vil lagre postmumrene?", comment: "SettingView")),
                             primaryButton: .destructive(Text(NSLocalizedString("Yes", comment: "SettingView")),
                                                         action: {
                                                            updatePostNummerFromCSV()
                                                         }),
                             secondaryButton: .cancel(Text(NSLocalizedString("No", comment: "SettingView"))))
            }
        }
    }
    
    struct Password: View {
        @ObservedObject var settingsStore: SettingsStore = SettingsStore()
        var body: some View {
            Form {
                Section(header: Text(NSLocalizedString("PASSWORD", comment: "SettingView")),
                        footer: Text(NSLocalizedString("Choose to show or hide the password", comment: "SettingView"))) {
                    Toggle(isOn: $settingsStore.showPasswordActivate) {
                        Text(NSLocalizedString("Show password", comment: "SettingView"))
                    }
                }
            }
            .navigationBarTitle(Text(NSLocalizedString("Password", comment: "SettingView")), displayMode: .inline)
        }
    }
    
    struct PostNummerUpdate: View {
        @Binding var alertIdentifier: AlertID?
        @ObservedObject var settingsStore: SettingsStore = SettingsStore()
        var body: some View {
            Form {
                Section(header: Text(NSLocalizedString("POSTNUMMER", comment: "SettingView")),
                        footer: Text(NSLocalizedString("Velg å slette eller oppdatere postnummer", comment: "SettingView"))) {
                    Text(NSLocalizedString("Slett postnummer (100 om gangen)", comment: "SettingView"))
                        .onTapGesture {
                            alertIdentifier  = AlertID(id: .second)
                        }
                        .foregroundColor(.accentColor)
                    Text(NSLocalizedString("Lagre postnummer", comment: "SettingView"))
                        .onTapGesture {
                            alertIdentifier  = AlertID(id: .third)
                        }
                        .foregroundColor(.accentColor)
                }
            }
            .navigationBarTitle(Text(NSLocalizedString("PostNummer", comment: "SettingView")), displayMode: .inline)
            
        }
        
    }
    
    func parseCSV (contentsOfURL: URL,
                   delimiter: String) -> [(PostNummer)]? {
        
        /// Finne det rette formatet på Postnummerregister-ansi.txt filen:
        /// Gå til https://www.bring.no/tjenester/adressetjenester/postnummer
        ///
        /// Hent: Tab-separerte felter (ANSI)
        /// Kopier direkte fra det som vises på skjermen
        /// Erstatt disse tegnene med:
        ///  ∆ mrd  Æ
        ///  ÿ med  Ø
        ///  ≈ med  Å
        ///  ¡ med   O    9716    BÿRSELV    5436    PORSANGER PORS¡NGU PORSANKI    G
        ///  Ferdig!
        
        var postNummer: PostNummer! = PostNummer()
        var postNumre: [(PostNummer)]?
        
        do {
            let content = try String(contentsOf: contentsOfURL)
            
            postNumre = []
            let lines: [String] = content.components(separatedBy: .newlines)
            for line in lines {
                var values:[String] = []
                if line != "" {
                    values = line.components(separatedBy: delimiter)
                    postNummer.postalNumber = values[0]
                    postNummer.postalName = values[1]
                    postNummer.municipalityNumber = values[2]
                    postNummer.municipalityName = values[3]
                    postNummer.category = values[4]
                    postNumre?.append(postNummer)
                }
            }
        } catch {
            let _ = error.localizedDescription
        }
        return postNumre
    }
    
    func updatePostNummerFromCSV() {
        
        var index = 0
        /// Finner URL fra prosjektet
        guard let contentsOfURL = Bundle.main.url(forResource: "Postnummerregister-ansi", withExtension: "txt") else { return }
        /// Må bruke encoding == ascii (utf8 virker ikke)
        let postNumre = parseCSV (contentsOfURL: contentsOfURL,
                                  delimiter: "    ")
        let maxNumber =  postNumre!.count
        repeat {
            let postNummer = postNumre![index]
            CloudKitPostNummer.savePostNummer(item: postNummer) { (result) in
                switch result {
                case .success:
                    _ = 1
                case .failure(let err):
                    let _ = err.localizedDescription
                }
            }
            index += 1
        } while index < maxNumber
        let _ = "Poster lagret: \(index)"
    }
}

struct ReturnFromMenuView: View {
    var text: String
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .resizable()
                .frame(width: 11, height: 18, alignment: .center)
            Text(text)
        }
        .foregroundColor(.none)
        .font(Font.headline.weight(.regular))
    }
}
