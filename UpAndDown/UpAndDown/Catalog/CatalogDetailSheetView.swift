//
//  CatalogDetailSheetView.swift
//  UpAndDown
//
//  Created by 이승진 on 8/8/25.
//

import SwiftUI

struct CatalogDetailSheetView: View {
    
    // MARK: - Property
    
    let coin: Coin
    let player: Player?
    let currentPrice: Double
    let holding: CoinHolding?
    let tradeManager: TradeManager?
    let priceManager: PriceManager?
    
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var currentView: ViewType = .detail
    
    enum ViewType {
        case detail, buying, selling
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                switch currentView {
                case .detail:
                    detailView
                case .buying:
                    if let player = player,
                       let tradeManager = tradeManager,
                       let priceManager = priceManager {
                        BuyingTradeView(
                            coin: coin,
                            player: player,
                            tradeManager: tradeManager,
                            priceManager: priceManager,
                            onTradeComplete: {
                                currentView = .detail
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("뒤로") {
                                    currentView = .detail
                                }
                            }
                        }
                    }
                case .selling:
                    if let player = player,
                       let tradeManager = tradeManager,
                       let priceManager = priceManager {
                        SellingTradeView(
                            coin: coin,
                            player: player,
                            tradeManager: tradeManager,
                            priceManager: priceManager,
                            onTradeComplete: {
                                currentView = .detail
                            }
                        )
                        .navigationBarBackButtonHidden(true)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("뒤로") {
                                    currentView = .detail
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(coin.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var detailView: some View {
        VStack {
            topContentes
            
            Spacer()
            
            centerContents
            
            Spacer()
            
            bottomContents
            
            Spacer()
            
            buttonGroup
        }
        .padding(EdgeInsets(top: 36, leading: 16, bottom: 0, trailing: 16))
    }
    
    /// 코인 이름 + 현재가
    private var topContentes: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(coin.name)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.black)
                
                Text(coin.currentPrice, format: .currency(code: "KRW"))
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.black)
            }
            
            Spacer()
        }
    }
    
    /// 그래프 넣어주세요 ㅠㅠ
    private var centerContents: some View {
        Rectangle()
            .fill(.black)
            .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    /// 코인 인포 + 버튼
    private var bottomContents: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("내 코인")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.black)
            
            infoGroup
        }
    }
    
    /// 평가액 + 1주 평균 x 보유수량 그룹
    private var infoGroup: some View {
        VStack(spacing: 10) {
            HStack {
                Text("평가액")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                
                Spacer()
                
                Text(eval, format: .currency(code: "KRW"))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
            }
            
            HStack {
                Text("1주 평균 × 보유 수량")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                
                Spacer()
                
                (
                    Text(pnl, format: .number.sign(strategy: .always()).grouping(.automatic))
                    + Text(String(format: " (%.1f%%)", pnlRate))
                )
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(pnl >= 0 ? .red : .blue)
            }
            
        }
    }
    
    /// 매도 + 매수 버튼 그룹
    private var buttonGroup: some View {
        HStack() {
            Button {
                print("매도 버튼 클릭")
                currentView = .selling
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                    
                    Text("매도")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            
            Spacer()
            
            Button {
                print("매수 버튼 클릭")
                currentView = .buying
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                    
                    Text("매수")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

private extension CatalogDetailSheetView {
    var qty: Double { holding?.quantity ?? 0 }
    var avg: Double { holding?.averagePrice ?? 0 }
    var eval: Double { qty * currentPrice }
    var cost: Double { avg * qty }
    var pnl: Double { eval - cost }
    var pnlRate: Double { cost > 0 ? (pnl / cost) * 100 : 0 }
}
