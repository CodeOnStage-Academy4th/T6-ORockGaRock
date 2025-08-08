import SwiftData
import SwiftUI

struct PortfolioView: View {
    @Bindable var player: Player
    let coins: [Coin]
    let tradeManager: TradeManager?
    let gameTimer: GameTimer

    @State private var selectedCoin: Coin?
    @State private var tradeAmount: String = ""
    @State private var showingTradeResult = false
    @State private var tradeResultMessage = ""
   

    var body: some View {
        VStack(spacing: 16) {
            // 플레이어 자산 정보
            VStack(spacing: 8) {
                HStack {
                    Text("현금")
                    Spacer()
                    Text("₩\(Int(player.cash))")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("총 자산")
                    Spacer()
                    Text("₩\(Int(player.totalAssets))")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // 코인 목록
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(coins, id: \.id) { coin in
                        CoinRowView(
                            coin: coin,
                            player: player,
                            tradeManager: tradeManager,
                            onTradeResult: { message in
                                tradeResultMessage = message
                                showingTradeResult = true
                            }
                        )
                    }
                }
            }
        }
        .alert("거래 결과", isPresented: $showingTradeResult) {
            Button("확인") {}
        } message: {
            Text(tradeResultMessage)
        }
    }
}

struct CoinRowView: View {
    let coin: Coin
    @Bindable var player: Player
    let tradeManager: TradeManager?
    let onTradeResult: (String) -> Void

    @State private var showingTradeSheet = false
    @State private var tradeAmount: String = ""
    @State private var isSellingMode = false

    private var holdingQuantity: Double {
        player.holdings.first { $0.coinId == coin.id }?.quantity ?? 0
    }

    private var priceChangeColor: Color {
        guard coin.priceHistory.count >= 2 else { return .primary }
        let current = coin.currentPrice
        let previous = coin.priceHistory[coin.priceHistory.count - 2].price

        if current > previous {
            return .green
        } else if current < previous {
            return .red
        } else {
            return .primary
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(coin.name)
                        .font(.headline)
                    Text(coin.symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("₩\(Int(coin.currentPrice))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(priceChangeColor)

                    if holdingQuantity > 0 {
                        Text("보유: \(holdingQuantity, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }

            HStack(spacing: 12) {
                Button("매수") {
                    isSellingMode = false
                    showingTradeSheet = true
                }
                .buttonStyle(.bordered)
                .tint(.green)

                Button("매도") {
                    isSellingMode = true
                    showingTradeSheet = true

                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(holdingQuantity <= 0)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingTradeSheet) {
            TradeSheetView(
                coin: coin,
                player: player,
                tradeManager: tradeManager,
                isSellingMode: isSellingMode,
                onTradeResult: onTradeResult
            )
        }
    }
}

struct TradeSheetView: View {
    let coin: Coin
    @Bindable var player: Player
    let tradeManager: TradeManager?
    let isSellingMode: Bool
    let onTradeResult: (String) -> Void

    @State private var tradeAmount: String = ""
    @Environment(\.dismiss) private var dismiss

    private var maxAmount: Double {
        if isSellingMode {
            return tradeManager?.getMaxSellAmount(player: player, coinId: coin.id) ?? 0
        } else {
            return tradeManager?.getMaxBuyAmount(player: player, coinId: coin.id) ?? 0
        }
    }

    private var tradeValue: Double {
        guard let amount = Double(tradeAmount) else { return 0 }
        return tradeManager?.calculateTradeValue(coinId: coin.id, amount: amount) ?? 0
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text(coin.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("현재가: ₩\(Int(coin.currentPrice))")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("수량")
                        .font(.headline)

                    HStack {
                        TextField("수량 입력", text: $tradeAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        Button("최대") {
                            tradeAmount = String(maxAmount)
                        }
                        .buttonStyle(.bordered)
                    }

                    Text("최대: \(maxAmount, specifier: "%.4f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !tradeAmount.isEmpty {
                    VStack {
                        Text("거래 금액")
                            .font(.headline)
                        Text("₩\(Int(tradeValue))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }

                Button(isSellingMode ? "매도하기" : "매수하기") {
                    executeTrade()
                }
                .buttonStyle(.borderedProminent)
                .tint(isSellingMode ? .red : .green)
                .disabled(tradeAmount.isEmpty || Double(tradeAmount) == nil || Double(tradeAmount)! <= 0)

                Spacer()
            }
            .padding()
            .navigationTitle(isSellingMode ? "매도" : "매수")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func executeTrade() {
        guard let amount = Double(tradeAmount),
              let tradeManager = tradeManager else { return }

        let result: TradeResult

        if isSellingMode {
            result = tradeManager.sellCoin(player: player, coinId: coin.id, amount: amount)
        } else {
            result = tradeManager.buyCoin(player: player, coinId: coin.id, amount: amount)
        }

        let message: String
        switch result {
        case .success:
            message = isSellingMode ? "매도가 완료되었습니다!" : "매수가 완료되었습니다!"
        case .insufficientFunds:
            message = "현금이 부족합니다."
        case .insufficientHoldings:
            message = "보유 수량이 부족합니다."
        case .invalidAmount:
            message = "유효하지 않은 수량입니다."
        case .coinNotFound:
            message = "코인을 찾을 수 없습니다."
        case let .error(errorMessage):
            message = "오류: \(errorMessage)"
        }

        onTradeResult(message)
        dismiss()
    }
}

#Preview {
    PortfolioView(
        player: Player(name: "테스트"),
        coins: [],
        tradeManager: nil,
        gameTimer: GameTimer()
    )
}
