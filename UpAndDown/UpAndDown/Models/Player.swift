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

    init(name: String, initialCash: Double = 1_000_000.0) {
        id = UUID()
        self.name = name
        cash = initialCash
        holdings = []
        createdAt = Date()
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
        guard !holdings.isEmpty,
              let holding = holdings.first(where: { $0.coinId == coinId }),
              holding.quantity >= quantity
        else {
            return false
        }

        holding.quantity -= quantity

        if holding.quantity <= 0 {
            holdings.removeAll { $0.coinId == coinId }
        }

        return true
    }

    // 게임 시작 시 플레이어 상태 초기화
    func resetForNewGame() {
        cash = 1_000_000.0 // 100만원으로 초기화
        holdings.removeAll() // 모든 보유 코인 제거
        print("플레이어 초기화 완료: 현금 = \(cash), 보유코인 = \(holdings.count)")
    }

    // 강제 초기화 (디버깅용)
    func forceReset() {
        cash = 1_000_000.0
        holdings = []
        print("강제 초기화: cash = \(cash)")
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
        id = UUID()
        self.coinId = coinId
        self.quantity = quantity
        self.averagePrice = averagePrice
        createdAt = Date()
    }

    var totalValue: Double {
        return quantity * averagePrice // PriceManager를 통해 현재 가격을 가져와야 함
    }
}
