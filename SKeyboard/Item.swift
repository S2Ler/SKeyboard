//
//  Item.swift
//  SKeyboard
//
//  Created by S2Ler on 22.08.23.
//

import Foundation
import HidApi

struct Item: Codable, Identifiable, Hashable {
  var vendorId: HidDevice.VendorId
  var productId: HidDevice.ProductId
  var serialNumber: String?

  var id: String {
    deviceLabel
  }

  init(
    vendorId: HidDevice.VendorId,
    productId: HidDevice.ProductId,
    serialNumber: String?
  ) {
    self.vendorId = vendorId
    self.productId = productId
    self.serialNumber = serialNumber
  }

  var deviceLabel: String {
    if let serialNumber {
      "\(vendorId):\(productId):\(serialNumber)"
    } else {
      "\(vendorId):\(productId)"
    }
  }
}
