//
//  Coin.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import Foundation
import SwiftData

@Model
final class Coin {
    var id: UUID
    var name: String
    var symbol: String
    var currentPrice: Double
    var priceHistory: [PriceRecord]
    var createdAt: Date
    
    init(name: String, symbol: String, currentPrice: Double) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.currentPrice = currentPrice
        self.priceHistory = [PriceRecord(price: currentPrice, timestamp: Date())]
        self.createdAt = Date()
    }
    
    func addPriceRecord(price: Double) {
        currentPrice = price
        priceHistory.append(PriceRecord(price: price, timestamp: Date()))
    }
}

@Model
final class PriceRecord {
    var id: UUID
    var price: Double
    var timestamp: Date
    
    init(price: Double, timestamp: Date) {
        self.id = UUID()
        self.price = price
        self.timestamp = timestamp
    }
}
