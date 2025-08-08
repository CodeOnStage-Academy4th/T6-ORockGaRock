//
//  Player.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID
    var name: String
    var cash: Double
    var holdings: [CoinHolding]
    var createdAt: Date
    
    init(name: String, initialCash: Double = 1000000.0) {
        self.id = UUID()
        self.name = name
        self.cash = initialCash
        self.holdings = []
        self.createdAt = Date()
    }
    
    var totalAssets: Double {
        return cash + holdings.reduce(0) { total, holding in
            total + holding.totalValue
        }
    }
    
    func addHolding(coinId: UUID, quantity: Double, purchasePrice: Double) {
        if let existingHolding = holdings.first(where: { $0.coinId == coinId }) {
            let totalQuantity = existingHolding.quantity + quantity
            let totalCost = (existingHolding.averagePrice * existingHolding.quantity) + (purchasePrice * quantity)
            existingHolding.quantity = totalQuantity
            existingHolding.averagePrice = totalCost / totalQuantity
        } else {
            holdings.append(CoinHolding(coinId: coinId, quantity: quantity, averagePrice: purchasePrice))
        }
    }
    
    func removeHolding(coinId: UUID, quantity: Double) -> Bool {
        guard let holding = holdings.first(where: { $0.coinId == coinId }),
              holding.quantity >= quantity else {
            return false
        }
        
        holding.quantity -= quantity
        
        if holding.quantity <= 0 {
            holdings.removeAll { $0.coinId == coinId }
        }
        
        return true
    }
}

@Model
final class CoinHolding {
    var id: UUID
    var coinId: UUID
    var quantity: Double
    var averagePrice: Double
    var createdAt: Date
    
    init(coinId: UUID, quantity: Double, averagePrice: Double) {
        self.id = UUID()
        self.coinId = coinId
        self.quantity = quantity
        self.averagePrice = averagePrice
        self.createdAt = Date()
    }
    
    var totalValue: Double {
        return quantity * averagePrice // PriceManager를 통해 현재 가격을 가져와야 함
    }
}
