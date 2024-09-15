//
//  Item.swift
//  NFCWallet
//
//  Created by Hare White on 9/15/24.
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
