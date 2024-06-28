//
//  MacropadApp.swift
//  Macropad
//
//  Created by S2Ler on 11.11.23.
//

import SwiftUI

@main
struct MacropadApp: App {
  var body: some Scene {
    MenuBarExtra {
      SettingsLink()
    } label: {
      Text("SKeyboard")
    }
    .menuBarExtraStyle(.menu)

    Settings {
      ContentView()
        .environment(\.state, .empty)
    }
  }
}
