//
//  Item.swift
//  SKeyboard
//
//  Created by S2Ler on 22.08.23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
