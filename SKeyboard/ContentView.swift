//
//  ContentView.swift
//  SKeyboard
//
//  Created by S2Ler on 22.08.23.
//

import SwiftUI

struct ContentView: View {
  @Environment(Storage.self) private var storage

  @State private var numberFormatter: NumberFormatter = {
    var nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.allowsFloats = false
    nf.usesGroupingSeparator = false
    nf.maximumFractionDigits = 0
    return nf
  }()

  // MARK: New Item
  @State private var newItem: Item?
  @State private var newItemSheet: Bool = false
  @AppStorage("last_vendor_id") private var newItemVendorID: Int = 0
  @AppStorage("last_product_id") private var newItemProductId: Int = 0
  @State private var newItemSerialNumber: String = ""

  var body: some View {
    NavigationSplitView {
      List {
        ForEach(storage.items) { item in
          NavigationLink {
            DeviceView(item: item)
          } label: {
            Text(item.deviceLabel)
          }
          .contextMenu {
            Button("Delete") {
              deleteItem(item: item)
            }
          }
        }
      }
    } detail: {
      Text("Select an item")
    }
    .sheet(isPresented: $newItemSheet) {
      withAnimation {
        let newItem = Item(
          vendorId: .init(rawValue: UInt16(newItemVendorID)),
          productId: .init(rawValue: UInt16(newItemProductId)),
          serialNumber: newItemSerialNumber.isEmpty ? nil : newItemSerialNumber
        )
        storage.insert(newItem)
      }
    } content: {
      Form {
        TextField("Vendor ID", value: $newItemVendorID, formatter: numberFormatter)
        TextField("Product ID", value: $newItemProductId, formatter: numberFormatter)
        TextField("Serial Number", text: $newItemSerialNumber)
        Button("Done") {
          newItemSheet = false
        }
      }
      .frame(width: 200)
      .padding()
    }
    .toolbar {
      ToolbarItem {
        Button {
          newItemSheet = true
          newItem = nil
        } label: {
          Label("Add Item", systemImage: "plus")
        }
      }
    }
  }

  private func deleteItem(item: Item) {
    withAnimation {
      storage.delete(item)
    }
  }
}
