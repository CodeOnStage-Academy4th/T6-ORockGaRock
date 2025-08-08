//
//  BuyingTradeView.swift
//  UpAndDown
//
//  Created by kim yijun on 8/9/25.
//

import SwiftUI
import SwiftData

struct BuyingTradeView: View {
    let coin: Coin
    let player: Player
    let tradeManager: TradeManager
    let priceManager: PriceManager
    
    @State private var buyQuantityString: String = ""
    @State private var buyTotalValueString: String = ""
    @State private var isInputInvalid: Bool = false
 
    
    private var currentHolding: CoinHolding? {
        player.holdings.first { $0.coinId == coin.id }
    }
    
    private var availableCash: Double {
        player.cash
    }
    
    private var buyQuantityDouble: Double {
        Double(buyQuantityString.replacingOccurrences(of: ",", with: "")) ?? 0
    }
    
    // 보유 코인 기준 가격 변동률 계산
    private var priceChange: (amount: Double, percentage: Double) {
        guard let holding = currentHolding else {
            return (0, 0)
        }
        
        let purchasePrice = holding.averagePrice
        let currentPrice = coin.currentPrice
        let changeAmount = currentPrice - purchasePrice
        let changePercentage = (changeAmount / purchasePrice) * 100
        
        return (changeAmount, changePercentage)
    }

    
    var body: some View {
        VStack{
        
            VStack(alignment: .leading, spacing: 20) {
                
                Text(coin.name)
                    .fontWeight(.semibold)
                    .font(.system(size: 28))
                    .padding(.top)
                HStack {
                    Text("주문가능 금액")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                    Spacer()
                    Text("₩\(formatNumber(availableCash))")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("현재가")
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("₩\(formatNumber(coin.currentPrice))")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                        
                        let change = priceChange
                        if change.amount == 0 && change.percentage == 0 {
                            Text("0 (0.0%)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        } else {
                            let changeText = "\(change.amount >= 0 ? "+" : "")\(formatNumber(change.amount)) (\(String(format: "%.1f", change.percentage))%)"
                            Text(changeText)
                                .font(.system(size: 14))
                                .foregroundColor(change.amount >= 0 ? .red : .blue)
                        }
                    }
                }
                
                    HStack {
                        Text("매수 수량")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                           
                        
                        TextField("수량을 입력하세요", text: $buyQuantityString)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .fontWeight(.semibold)
                        
                        Text("개")
                            .fontWeight(.semibold)
                            
                    }
                    
                    HStack {
                        Text("매수 총액")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                        
                        TextField("총액을 입력하세요", text: $buyTotalValueString)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                        
                        Text("원")
                            .fontWeight(.semibold)
                           
                    }
            }
            .padding(.horizontal)
            
           
            if isInputInvalid {
                Text("주문가능 금액을 초과할 수 없습니다.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }
            
            Spacer()
            
            // 매수 버튼
            HStack(spacing: 16) {
                Button("올인") {
                    let maxQuantity = availableCash / coin.currentPrice
                    buyQuantityString = formatNumber(maxQuantity, fractionDigits: 6)
                }
                .frame(width: 120, height: 60)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.system(size: 16, weight: .semibold))
                
                Button("매수") {
                    executeBuy()
                }
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.system(size: 18, weight: .bold))
                .disabled(buyQuantityDouble <= 0 || isInputInvalid)
            }
            .padding(.horizontal)
            .padding(.bottom, 34)
        }
        .onTapGesture {
            hideKeyboard()
        }
        // 수량 입력 시 총액 자동 계산 및 유효성 검사
        .onChange(of: buyQuantityString) { oldValue, newValue in
            let cleanValue = newValue.replacingOccurrences(of: ",", with: "")
            guard let quantity = Double(cleanValue) else {
                buyTotalValueString = ""
                isInputInvalid = false // 숫자가 아니면 초기화
                return
            }
            
            let totalValue = quantity * coin.currentPrice
            isInputInvalid = totalValue > availableCash
            
            let formattedTotalValue = formatNumber(totalValue)
            
            if buyTotalValueString != formattedTotalValue {
                buyTotalValueString = formattedTotalValue
            }
            
            let formattedQuantity = formatNumber(quantity, fractionDigits: 6)
            if newValue != formattedQuantity {
                DispatchQueue.main.async {
                    self.buyQuantityString = formattedQuantity
                }
            }
        }
        // 총액 입력 시 수량 자동 계산 및 유효성 검사
        .onChange(of: buyTotalValueString) { oldValue, newValue in
            let cleanValue = newValue.replacingOccurrences(of: ",", with: "")
            guard let totalValue = Double(cleanValue), coin.currentPrice > 0 else {
                buyQuantityString = ""
                isInputInvalid = false // 숫자가 아니면 초기화
                return
            }
            
            isInputInvalid = totalValue > availableCash
            
            let quantity = totalValue / coin.currentPrice
            let formattedQuantity = formatNumber(quantity, fractionDigits: 6)
            
            if buyQuantityString != formattedQuantity {
                buyQuantityString = formattedQuantity
            }
            
            let formattedTotalValue = formatNumber(totalValue)
            if newValue != formattedTotalValue {
                DispatchQueue.main.async {
                    self.buyTotalValueString = formattedTotalValue
                }
            }
        }
    }
    
    private func formatNumber(_ number: Double, fractionDigits: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func executeBuy() {
        guard buyQuantityDouble > 0 else { return }
        
        let result = tradeManager.buyCoin(player: player, coinId: coin.id, amount: buyQuantityDouble)
        
        switch result {
        case .success:
            // 입력 필드 초기화
            buyQuantityString = ""
            buyTotalValueString = ""
        default:
            break
        }
    }
}


#Preview {
    // Preview용 더미 데이터
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Player.self, Coin.self, configurations: config)
    let context = container.mainContext
    
    let coin = Coin(name: "코인", symbol: "MSC", currentPrice: 120000)
    let player = Player(name: "테스트", initialCash: 1000000)
    
    let priceManager = PriceManager(modelContext: context)
    let tradeManager = TradeManager(modelContext: context, priceManager: priceManager)
    
    return BuyingTradeView(
        coin: coin,
        player: player,
        tradeManager: tradeManager,
        priceManager: priceManager
    )
}
