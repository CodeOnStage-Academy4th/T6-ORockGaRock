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
    let onTradeComplete: (() -> Void)?
    
    @Environment(AppRouter.self) private var router
    @State private var buyQuantityString: String = ""
    @State private var buyTotalValueString: String = ""
    @State private var isInputInvalid: Bool = false
    
    // 디버깅을 위한 안전한 접근
    private var safeBuyQuantityString: String {
        return buyQuantityString
    }
    
    init(coin: Coin, player: Player, tradeManager: TradeManager, priceManager: PriceManager, onTradeComplete: (() -> Void)? = nil) {
        self.coin = coin
        self.player = player
        self.tradeManager = tradeManager
        self.priceManager = priceManager
        self.onTradeComplete = onTradeComplete
    }
    
    private var availableCash: Double {
        player.cash
    }
    
    // 안전한 수량 계산 함수
    private func getBuyQuantityDouble() -> Double {
        guard !buyQuantityString.isEmpty else { return 0 }
        let cleanString = buyQuantityString.replacingOccurrences(of: ",", with: "")
        return Double(cleanString) ?? 0
    }
    
    private var buyQuantityDouble: Double {
        return getBuyQuantityDouble()
    }
    
    // 보유 코인 기준 가격 변동률 계산
    private var priceChange: (amount: Double, percentage: Double) {
        // SwiftData 관계형 데이터 접근을 안전하게 처리
        let holdings = player.holdings
        for holding in holdings {
            if holding.coinId == coin.id {
                let purchasePrice = holding.averagePrice
                let currentPrice = coin.currentPrice
                let changeAmount = currentPrice - purchasePrice
                let changePercentage = (changeAmount / purchasePrice) * 100
                return (changeAmount, changePercentage)
            }
        }
        return (0, 0)
    }

    
    var body: some View {
        NavigationView {
            VStack{
            
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text(coin.name)
                        .fontWeight(.semibold)
                        .font(.system(size: 28))
                        .padding(.top)
                        .onAppear {
                            print("BuyingTradeView 로드됨")
                            print("플레이어 현금: \(player.cash)")
                            print("플레이어 ID: \(player.id)")
                            print("플레이어 이름: \(player.name)")
                            print("코인 이름: \(coin.name)")
                            print("코인 현재가: \(coin.currentPrice)")
                        }
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
                .disabled(getBuyQuantityDouble() <= 0 || isInputInvalid)
            }
            .padding(.horizontal)
            .padding(.bottom, 34)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
        // 직접 계산하여 브레이크포인트 회피
        let cleanQuantityString = buyQuantityString.replacingOccurrences(of: ",", with: "")
        guard let quantity = Double(cleanQuantityString), quantity > 0 else { 
            print("매수 실패: 수량이 0 이하 또는 잘못된 입력")
            return 
        }
        
        print("매수 시도: 코인 \(coin.name), 수량 \(quantity), 현재가 \(coin.currentPrice)")
        print("플레이어 현금: \(player.cash)")
        print("총 비용: \(quantity * coin.currentPrice)")
        
        let result = tradeManager.buyCoin(player: player, coinId: coin.id, amount: quantity)
        
        switch result {
        case .success:
            print("매수 성공!")
            // 입력 필드 초기화
            buyQuantityString = ""
            buyTotalValueString = ""
            // completion handler 호출 또는 게임 화면으로 돌아가기
            if let onTradeComplete = onTradeComplete {
                onTradeComplete()
            } else {
                router.currentRoute = .game
            }
        case .insufficientFunds:
            print("매수 실패: 보유 현금 부족")
        case .invalidAmount:
            print("매수 실패: 올바르지 않은 수량")
        case .coinNotFound:
            print("매수 실패: 코인을 찾을 수 없음")
        case .error(let message):
            print("매수 실패: \(message)")
        default:
            print("매수 실패: 알 수 없는 오류")
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
