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
  @AppStorage("last_serial_number") private var newItemSerialNumber: String = ""
  @AppStorage("last_usage_page") private var newItemUsagePage: Int = 0
  @AppStorage("last_usage") private var newItemUsage: Int = 0


  var body: some View {
    NavigationSplitView {
      List {
        ForEach(storage.items) { item in
          NavigationLink {
            if item.usage != nil,  item.usagePage != nil {
              DeviceWithUsageView(item: item)
            } else {
              DeviceView(item: item)
            }
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
          serialNumber: newItemSerialNumber.isEmpty ? nil : newItemSerialNumber,
          usagePage: newItemUsagePage != 0 ? .init(rawValue: UInt16(newItemUsagePage)) : nil,
          usage: newItemUsage != 0 ? .init(rawValue: UInt16(newItemUsage)) : nil

        )
        storage.insert(newItem)
      }
    } content: {
      Form {
        TextField("Vendor ID", value: $newItemVendorID, formatter: numberFormatter)
        TextField("Product ID", value: $newItemProductId, formatter: numberFormatter)
        TextField("Serial Number", text: $newItemSerialNumber)
        TextField("Usage Page", value: $newItemUsagePage, formatter: numberFormatter)
        TextField("Usage", value: $newItemUsage, formatter: numberFormatter)
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
