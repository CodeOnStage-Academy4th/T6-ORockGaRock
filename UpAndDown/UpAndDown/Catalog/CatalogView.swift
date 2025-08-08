//
//  CatalogView.swift
//  UpAndDown
//
//  Created by 이승진 on 8/8/25.
//

import SwiftUI
import SwiftData

struct CatalogView: View {
    
    // MARK: - Property
    
    let tradeManager: TradeManager?
    let priceManager: PriceManager?
    
    @State private var selectedCoin: Coin?
    @State private var gameTimer = GameTimer()
    
    @Query(sort: [SortDescriptor(\Coin.name, order: .forward)])
    private var coins: [Coin]

    @Query
    private var players: [Player]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.white01
                    .ignoresSafeArea()
            VStack(spacing: 30) {
                topContents
                centerContents
            }
            .padding(.horizontal, 16)
            .sheet(item: $selectedCoin) { coin in
                CatalogDetailSheetView(
                    coin: coin,
                    player: players.first,
                    currentPrice: coin.currentPrice,
                    holding: players.first?.holdings.isEmpty == false ? 
                        players.first?.holdings.first(where: { $0.coinId == coin.id }) : nil,
                    tradeManager: tradeManager,
                    priceManager: priceManager
                )
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    /// 타이머 + 총자산
    private var topContents: some View {
        HStack(spacing: .zero) {
            HStack(spacing: 8) {
                Text(gameTimer.formattedTime)
                    .font(.title3)
                    .foregroundStyle(.black)
                
                Image(.clock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(players.first?.totalAssets ?? 0, format: .currency(code: "KRW"))
                    .font(.title3)
                    .foregroundStyle(.black)
                
                Image(.won)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    /// 코인 리스트
    private var centerContents: some View {
        ScrollView {
            LazyVStack {
                ForEach(coins) { coin in
                    CatalogCoinRow(coin: coin)
                        .onTapGesture {
                            selectedCoin = coin
                        }
                    
                    Spacer()
                }
            }
        }
    }
}
