//
//  AssetView.swift
//  UpAndDown
//
//  Created by Nike on 8/8/25.
//

import SwiftUI
import SwiftData

struct AssetView: View {
    @Bindable var player: Player
//    let gameTimer: GameTimer
    
    /*@Query */var coins: [Coin]
    let tradeManager: TradeManager?
    
    private var assetChangePercentage: Double {
        ((player.totalAssets / 1_000_000) * 100) - 100
    }
    private var assetChangePrefix: String {
        assetChangePercentage > 0 ? "+" : ""
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(){
                Text("timer here")
                Spacer()
                Text("left money here")
            }
            // 플레이어 자산 정보
            VStack(spacing: 8) {
                Text("총 자산")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("\(Int(player.totalAssets))원")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text("\(assetChangePrefix)\(assetChangePercentage, specifier: "%.3f")%")
                    .font(.subheadline)
                    .foregroundColor(
                        assetChangePercentage > 0 ? .red :
                        (assetChangePercentage == 0 ? .black : .blue)
                    )
                
            }
            .padding()
        }
        
        ScrollView {
            LazyVStack(spacing: 12) {
                
                HStack(spacing: 4) {
                    Text("현금 보유량")
                        .font(.headline)
                        .foregroundColor(Color.white)
                    Spacer()
                    Text("₩\(Int(player.cash))")
                        .font(.subheadline)
                        .foregroundColor(Color.white)
                }
                .padding()
                .background(.black)
                
                ForEach(player.holdings, id: \.id) { holding in
                    if let coin = coins.first(where: { $0.id == holding.coinId }) {
                        HoldingRow(holding: holding, coin: coin)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct HoldingRow: View {
    let holding: CoinHolding
    let coin: Coin
    
    private var profitPercentage: Double {
        ((coin.currentPrice / holding.averagePrice) * 100) - 100
    }
    private var profitPrefix: String {
        profitPercentage > 0 ? "+" : ""
    }
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.headline)
                Text("현재 가격: ₩\(coin.currentPrice, specifier: "%.0f")")
                    .font(.caption)
            }
            .foregroundColor(.white)
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("평균 매입가: ₩\(holding.averagePrice, specifier: "%.0f")")
                    .font(.caption)
                    .foregroundColor(.white)
                Text("총 가치: ₩\(holding.totalValue, specifier: "%.0f")")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("\(profitPrefix)\(profitPercentage, specifier: "%.3f")%")
                    .font(.caption)
                    .foregroundColor(
                        profitPercentage > 0 ? .red :
                        (profitPercentage == 0 ? .black : .blue)
                    )
            }
        }
        .padding()
        .background(.black)
    }
}

#Preview {
//    AssetView(
//        player: Player(name: "테스트"),
//        gameTimer: GameTimer()
//    )
}
