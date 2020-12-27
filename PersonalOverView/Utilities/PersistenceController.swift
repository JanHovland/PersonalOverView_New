//
//  PersistenceController.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentCloudKitContainer
    init(inMemory: Bool = false) {
        /// The name of the container must be the same as the Bundle Identifier ("TestTwo")
        /// You can change the Bundle Identifier to use another Container
        container = NSPersistentCloudKitContainer(name: "TestTwo")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                let _ = error.localizedDescription
            }
        })
    }
}

