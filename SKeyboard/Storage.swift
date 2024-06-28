//
//  Storage.swift
//  SKeyboard
//
//  Created by S2Ler on 7.11.23.
//

import Foundation

@MainActor
let storage = Storage()

@Observable
@MainActor
final class Storage {
  private(set) var items: [Item] = [] {
    didSet {
      save()
    }
  }

  fileprivate init() {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "storage.json")
    if let data = try? Data(contentsOf: path) {
      let decoder = JSONDecoder()
      self.items = try! decoder.decode([Item].self, from: data)
    } else {
      self.items = []
      save()
    }
  }

  private func save() {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "storage.json")
    let encoder = JSONEncoder()
    let data = try! encoder.encode(items)
    try! data.write(to: path)
  }

  func insert(_ item: Item) {
    items.append(item)
  }

  func delete(_ item: Item) {
    items.removeAll(where: {
      $0 == item
    })
  }
}
