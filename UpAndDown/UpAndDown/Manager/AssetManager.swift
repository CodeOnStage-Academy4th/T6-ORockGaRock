//
//  AssetManager.swift
//  UpAndDown
//
//  Created by Nike on 8/9/25.
//

import Foundation
import SwiftData

@Observable
class AssetManager {
    private let modelContext: ModelContext
    private let priceManager: PriceManager

    init(modelContext: ModelContext, priceManager: PriceManager) {
        self.modelContext = modelContext
        self.priceManager = priceManager
    }

    /// 현재 보유 중인 코인의 현재 전체 가치를 계산합니다.
    func currentValue(of holding: CoinHolding) -> Double {
        guard let currentPrice = priceManager.getCoinPrice(coinId: holding.coinId) else {
            return 0
        }
        return currentPrice * holding.quantity
    }

    /// 특정 코인 홀딩의 수익률(%)을 계산합니다.
    func profitRate(of holding: CoinHolding) -> Double {
        guard let currentPrice = priceManager.getCoinPrice(coinId: holding.coinId),
              holding.averagePrice > 0 else {
            return 0
        }
        return (currentPrice / holding.averagePrice) * 100 - 100
    }

    /// 플레이어가 보유한 모든 코인의 현재 가치를 합산합니다.
    func totalValue(for player: Player) -> Double {
        return player.holdings.reduce(0) { result, holding in
            result + currentValue(of: holding)
        }
    }

    /// 플레이어가 보유한 모든 코인의 평균 수익률(%)을 계산합니다.
    /// (전체 코인 비용 대비 현재 가치 기준)
    func totalProfitRate(for player: Player) -> Double {
        let totalCost = player.holdings.reduce(0) { result, holding in
            result + (holding.averagePrice * holding.quantity)
        }
        guard totalCost > 0 else {
            return 0
        }
        let currentSum = totalValue(for: player)
        return (currentSum / totalCost) * 100 - 100
    }
}
