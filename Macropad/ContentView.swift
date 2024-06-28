//
//  ContentView.swift
//  Macropad
//
//  Created by S2Ler on 11.11.23.
//

import SwiftUI
import SwiftData
import KeyboardKit

var keyboard: Keyboard?

struct ContentView: View {
  var body: some View {
    NavigationSplitView {
      List {
        NavigationLink("Layers mapping") {
          LayersMappingView()
        }
        NavigationLink("Language mapping") {
          LanguageMappingView()
        }
        NavigationLink("Control Center") {
          Button("Go") {
            keyboard = .init(info: .init(vendorId: .init(rawValue: <#T##UInt16#>), productId: <#T##HidDevice.ProductId#>, usagePage: <#T##HidDevice.UsagePage#>, usage: <#T##HidDevice.Usage#>), configuration: <#T##Keyboard.Configuration#>)
          }
        }
      }
      .navigationSplitViewColumnWidth(min: 180, ideal: 200)
      .listStyle(.sidebar)
    } detail: {
      Text("details default")
    }
  }
}
