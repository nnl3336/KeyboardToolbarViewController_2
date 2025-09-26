//
//  KeyboardToolbarViewController_2App.swift
//  KeyboardToolbarViewController_2
//
//  Created by Yuki Sasaki on 2025/09/26.
//

import SwiftUI

@main
struct KeyboardToolbarViewController_2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
