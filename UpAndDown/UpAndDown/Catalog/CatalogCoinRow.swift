//
//  CatalogCoinRow.swift
//  UpAndDown
//
//  Created by 이승진 on 8/8/25.
//

import SwiftUI

struct CatalogCoinRow: View {
    
    // MARK: - Property
    let coin: Coin
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                // 코인이름 + 코인심볼
                VStack(alignment: .leading, spacing: .zero) {
                    Text(coin.name)
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Text(coin.symbol)
                        .font(.subheadline)
                        .foregroundStyle(.black)
                }
                
                Spacer()
                
                // 코인 가격
                Text(coin.currentPrice, format: .currency(code: "KRW"))
                    .font(.system(size: 25, weight: .regular))
                    .foregroundStyle(.black)
            }
            
            // 그래프 해주세요 ㅠㅠ
            Image(systemName: "chart.line.uptrend.xyaxis")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, maxHeight: 80)
                
                .background(
                    Rectangle()
                        .fill(.white)
                        .frame(height: 80)
                )
        }
        .padding(EdgeInsets(top: 30, leading: 30, bottom: 30, trailing: 30))
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    CatalogCoinRow(
        coin: Coin(
            name: "비트코인",
            symbol: "BTC",
            currentPrice: 50_000_000.0
        )
    )
}
