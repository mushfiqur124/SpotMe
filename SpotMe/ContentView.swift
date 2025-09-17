//
//  ContentView.swift
//  SpotMe
//
//  Main content view - entry point to the chat interface
//  Updated to use ChatView for fitness tracking conversations
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        ChatView()
            .environment(\.managedObjectContext, viewContext)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
