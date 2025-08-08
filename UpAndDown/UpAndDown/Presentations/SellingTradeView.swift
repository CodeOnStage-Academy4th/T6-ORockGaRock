//
//  SellingTradeView.swift
//  UpAndDown
//
//  Created by kim yijun on 8/9/25.
//

import SwiftData
import SwiftUI

struct SellingTradeView: View {
    let coin: Coin
    let player: Player
    let tradeManager: TradeManager
    let priceManager: PriceManager
    let onTradeComplete: (() -> Void)?

    @Environment(AppRouter.self) private var router
    @State private var sellQuantityString: String = ""
    @State private var sellTotalValueString: String = ""
    @State private var isInputInvalid: Bool = false

    init(coin: Coin, player: Player, tradeManager: TradeManager, priceManager: PriceManager, onTradeComplete: (() -> Void)? = nil) {
        self.coin = coin
        self.player = player
        self.tradeManager = tradeManager
        self.priceManager = priceManager
        self.onTradeComplete = onTradeComplete
    }

    private var currentHolding: CoinHolding? {
        guard !player.holdings.isEmpty else { return nil }
        return player.holdings.first { $0.coinId == coin.id }
    }

    private var holdingAmount: Double {
        currentHolding?.quantity ?? 0
    }

    private var holdingValue: Double {
        holdingAmount * coin.currentPrice
    }

    private var sellQuantityDouble: Double {
        Double(sellQuantityString.replacingOccurrences(of: ",", with: "")) ?? 0
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
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text(coin.name)
                        .fontWeight(.semibold)
                        .font(.system(size: 28))
                        .padding(.top)
                    HStack {
                        Text("보유 금액")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                        Spacer()
                        Text("₩\(formatNumber(holdingValue))")
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
                        Text("매도 수량")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)

                        TextField("수량을 입력하세요", text: $sellQuantityString)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                            .fontWeight(.semibold)

                        Text("개")
                            .fontWeight(.semibold)
                    }

                    HStack {
                        Text("매도 총액")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)

                        TextField("총액을 입력하세요", text: $sellTotalValueString)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)

                        Text("원")
                            .fontWeight(.semibold)
                    }

                    LineChartView(data: coin.priceHistory.map(\.price))
                        .frame(height: 200)
                }
                .padding(.horizontal)

                if isInputInvalid {
                    Text("보유 수량을 초과할 수 없습니다.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 10)
                }

                Spacer()

                // 매도 버튼
                HStack(spacing: 16) {
                    Button {
                        sellQuantityString = formatNumber(holdingAmount, fractionDigits: 6)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray)
                                .frame(maxWidth: .infinity)
                                .frame(width: 120, height: 60)

                            Text("올인")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .contentShape(Rectangle())
                    }

                    Button {
                        executeSell()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .foregroundColor(.white)
                                .frame(width: 225, height: 60)

                            Text("매도")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .contentShape(Rectangle())
                    }
                    .disabled(sellQuantityDouble <= 0 || isInputInvalid)
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
        .onChange(of: sellQuantityString) { _, newValue in
            let cleanValue = newValue.replacingOccurrences(of: ",", with: "")
            guard let quantity = Double(cleanValue) else {
                sellTotalValueString = ""
                isInputInvalid = false // 숫자가 아니면 초기화
                return
            }

            isInputInvalid = quantity > holdingAmount

            let totalValue = quantity * coin.currentPrice
            let formattedTotalValue = formatNumber(totalValue)

            if sellTotalValueString != formattedTotalValue {
                sellTotalValueString = formattedTotalValue
            }

            let formattedQuantity = formatNumber(quantity, fractionDigits: 6)
            if newValue != formattedQuantity {
                DispatchQueue.main.async {
                    self.sellQuantityString = formattedQuantity
                }
            }
        }
        // 총액 입력 시 수량 자동 계산 및 유효성 검사
        .onChange(of: sellTotalValueString) { _, newValue in
            let cleanValue = newValue.replacingOccurrences(of: ",", with: "")
            guard let totalValue = Double(cleanValue), coin.currentPrice > 0 else {
                sellQuantityString = ""
                isInputInvalid = false // 숫자가 아니면 초기화
                return
            }

            let quantity = totalValue / coin.currentPrice

            isInputInvalid = quantity > holdingAmount

            let formattedQuantity = formatNumber(quantity, fractionDigits: 6)

            if sellQuantityString != formattedQuantity {
                sellQuantityString = formattedQuantity
            }

            let formattedTotalValue = formatNumber(totalValue)
            if newValue != formattedTotalValue {
                DispatchQueue.main.async {
                    self.sellTotalValueString = formattedTotalValue
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

    private func executeSell() {
        guard sellQuantityDouble > 0 else { return }

        let result = tradeManager.sellCoin(player: player, coinId: coin.id, amount: sellQuantityDouble)

        switch result {
        case .success:
            sellQuantityString = ""
            sellTotalValueString = ""
            // completion handler 호출 또는 게임 화면으로 돌아가기
            if let onTradeComplete = onTradeComplete {
                onTradeComplete()
            } else {
                router.currentRoute = .game
            }
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

    let coin = Coin(name: "코인", symbol: "MSC", currentPrice: 120_000)
    let player = Player(name: "테스트", initialCash: 1_000_000)
    player.addHolding(coinId: coin.id, quantity: 2, purchasePrice: 120_000)

    let priceManager = PriceManager(modelContext: context)
    let tradeManager = TradeManager(modelContext: context, priceManager: priceManager)

    return SellingTradeView(
        coin: coin,
        player: player,
        tradeManager: tradeManager,
        priceManager: priceManager
    )
}
