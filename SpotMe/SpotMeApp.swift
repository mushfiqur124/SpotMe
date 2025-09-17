//
//  SpotMeApp.swift
//  SpotMe
//
//  Created by Mushfiqur Rahman on 2025-09-16.
//

import SwiftUI

@main
struct SpotMeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
