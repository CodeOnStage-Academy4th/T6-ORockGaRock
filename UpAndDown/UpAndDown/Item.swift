//
//  Item.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
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
