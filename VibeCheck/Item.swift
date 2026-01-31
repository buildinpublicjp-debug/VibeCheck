//
//  Item.swift
//  VibeCheck
//
//  Created by og3939397 on 2026/01/31.
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
