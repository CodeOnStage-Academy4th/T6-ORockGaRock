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
        let holdingsValue = holdings.reduce(0) { total, holding in
            total + holding.totalValue
        }
        let total = cash + holdingsValue
        print("플레이어 총 자산 계산: 현금=\(cash), 보유코인가치=\(holdingsValue), 총자산=\(total)")
        return total
    }
    
    // PriceManager를 사용한 정확한 총 자산 계산
    func getTotalAssetsWithCurrentPrices(priceManager: PriceManager) -> Double {
        let holdingsValue = holdings.reduce(0) { total, holding in
            if let currentPrice = priceManager.getCoinPrice(coinId: holding.coinId) {
                return total + holding.getCurrentValue(currentPrice: currentPrice)
            } else {
                return total + holding.totalValue // 현재 가격을 못 가져오면 평균 가격 사용
            }
        }
        let total = cash + holdingsValue
        print("플레이어 정확한 총 자산 계산: 현금=\(cash), 보유코인가치=\(holdingsValue), 총자산=\(total)")
        return total
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

    // totalValue는 현재 가격을 알아야 하므로 별도 메서드로 계산
    var totalValue: Double {
        // 임시로 평균 가격 사용 (실제로는 PriceManager를 통해 현재 가격을 가져와야 함)
        return quantity * averagePrice
    }
    
    func getCurrentValue(currentPrice: Double) -> Double {
        return quantity * currentPrice
    }
}
