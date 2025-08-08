//
//  PriceManager.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class PriceManager {
    private var modelContext: ModelContext
    private var priceUpdateTimer: Timer?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func startPriceUpdates() {
        priceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateAllCoinPrices()
        }
    }

    func stopPriceUpdates() {
        priceUpdateTimer?.invalidate()
        priceUpdateTimer = nil
    }

    private func updateAllCoinPrices() {
        let request = FetchDescriptor<Coin>()

        do {
            let coins = try modelContext.fetch(request)
            for coin in coins {
                updateCoinPrice(coin)
            }
            try modelContext.save()
        } catch {
            print("가격 업데이트 실패: \(error)")
        }
    }

    private func updateCoinPrice(_ coin: Coin) {
        // 단타 게임에 맞는 가격 변동 로직
        let volatility = 0.05 // 5% 변동성
        let randomFactor = Double.random(in: -volatility ... volatility)
        let newPrice = coin.currentPrice * (1 + randomFactor)

        // 최소 가격 보장 (0 이하로 떨어지지 않도록)
        let finalPrice = max(newPrice, coin.currentPrice * 0.1)
        
        withAnimation {
            coin.addPriceRecord(price: finalPrice)
        }
    }

    func createDefaultCoins() {
        let defaultCoins = [
            ("비트코인", "BTC", 50_000_000.0),
            ("이더리움", "ETH", 3_000_000.0),
            ("리플", "XRP", 500.0),
            ("도지코인", "DOGE", 100.0),
            ("솔라나", "SOL", 100_000.0),
        ]

        for (name, symbol, price) in defaultCoins {
            let coin = Coin(name: name, symbol: symbol, currentPrice: price)
            modelContext.insert(coin)
        }

        do {
            try modelContext.save()
        } catch {
            print("기본 코인 생성 실패: \(error)")
        }
    }

    func getCoinPrice(coinId: UUID) -> Double? {
        let request = FetchDescriptor<Coin>(predicate: #Predicate { coin in
            coin.id == coinId
        })

        do {
            let coins = try modelContext.fetch(request)
            return coins.first?.currentPrice
        } catch {
            print("코인 가격 조회 실패: \(error)")
            return nil
        }
    }
}
