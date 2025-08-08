//
//  TradeManager.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import Foundation
import SwiftData

enum TradeType {
    case buy
    case sell
}

enum TradeResult {
    case success
    case insufficientFunds
    case insufficientHoldings
    case invalidAmount
    case coinNotFound
    case error(String)
}

@Observable
class TradeManager {
    private var modelContext: ModelContext
    private var priceManager: PriceManager

    init(modelContext: ModelContext, priceManager: PriceManager) {
        self.modelContext = modelContext
        self.priceManager = priceManager
    }

    func buyCoin(player: Player, coinId: UUID, amount: Double) -> TradeResult {
        print("TradeManager.buyCoin 호출: amount=\(amount)")

        guard amount > 0 else {
            print("TradeManager: 잘못된 수량")
            return .invalidAmount
        }

        guard let currentPrice = priceManager.getCoinPrice(coinId: coinId) else {
            print("TradeManager: 코인 가격을 찾을 수 없음")
            return .coinNotFound
        }

        print("TradeManager: 현재가=\(currentPrice)")

        let totalCost = currentPrice * amount
        print("TradeManager: 총 비용=\(totalCost), 플레이어 현금=\(player.cash)")

        guard player.cash >= totalCost else {
            print("TradeManager: 자금 부족")
            return .insufficientFunds
        }

        // 거래 실행
        print("TradeManager: 거래 실행 중...")
        player.cash -= totalCost
        player.addHolding(coinId: coinId, quantity: amount, purchasePrice: currentPrice)
        print("TradeManager: 거래 실행 완료, 남은 현금=\(player.cash)")

        do {
            try modelContext.save()
            print("TradeManager: 저장 성공")
            return .success
        } catch {
            print("TradeManager: 저장 실패 - \(error)")
            return .error("거래 저장 실패: \(error)")
        }
    }

    func sellCoin(player: Player, coinId: UUID, amount: Double) -> TradeResult {
        guard amount > 0 else {
            return .invalidAmount
        }

        guard let currentPrice = priceManager.getCoinPrice(coinId: coinId) else {
            return .coinNotFound
        }

        guard
            let holding = player.holdings.isEmpty ? nil : player.holdings.first(where: { $0.coinId == coinId }),
            holding.quantity >= amount
        else {
            return .insufficientHoldings
        }

        // 거래 실행
        let totalValue = currentPrice * amount
        player.cash += totalValue

        let success = player.removeHolding(coinId: coinId, quantity: amount)

        guard success else {
            return .insufficientHoldings
        }

        do {
            try modelContext.save()
            return .success
        } catch {
            return .error("거래 저장 실패: \(error)")
        }
    }

    func sellAllCoin(player: Player, coinId: UUID) -> TradeResult {
        guard let holding = player.holdings.isEmpty ? nil : player.holdings.first(where: { $0.coinId == coinId }) else {
            return .insufficientHoldings
        }

        return sellCoin(player: player, coinId: coinId, amount: holding.quantity)
    }

    func getMaxBuyAmount(player: Player, coinId: UUID) -> Double {
        guard let currentPrice = priceManager.getCoinPrice(coinId: coinId) else {
            return 0
        }

        return player.cash / currentPrice
    }

    func getMaxSellAmount(player: Player, coinId: UUID) -> Double {
        guard let holding = player.holdings.isEmpty ? nil : player.holdings.first(where: { $0.coinId == coinId }) else {
            return 0
        }

        return holding.quantity
    }

    func calculateTradeValue(coinId: UUID, amount: Double) -> Double? {
        guard let currentPrice = priceManager.getCoinPrice(coinId: coinId) else {
            return nil
        }

        return currentPrice * amount
    }
}
