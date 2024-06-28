//
//  SKeyboardApp.swift
//  SKeyboard
//
//  Created by S2Ler on 22.08.23.
//

import SwiftUI

@main
struct SKeyboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
              .environment(storage)
              .task {
                _ = k
              }
        }
    }
}
