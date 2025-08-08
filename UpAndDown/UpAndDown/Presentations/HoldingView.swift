import SwiftData
import SwiftUI

struct HoldingView: View {
    @Bindable var player: Player
    let coins: [Coin]
    let tradeManager: TradeManager?

    @State private var showingTradeResult = false
    @State private var tradeResultMessage = ""

    var totalHoldingValue: Double {
        player.holdings.reduce(0) { total, holding in
            let coin = coins.first { $0.id == holding.coinId }
            let currentPrice = coin?.currentPrice ?? holding.averagePrice
            return total + (holding.quantity * currentPrice)
        }
    }

    var totalProfitLoss: Double {
        player.holdings.reduce(0) { total, holding in
            let coin = coins.first { $0.id == holding.coinId }
            let currentPrice = coin?.currentPrice ?? holding.averagePrice
            let currentValue = holding.quantity * currentPrice
            let purchaseValue = holding.quantity * holding.averagePrice
            return total + (currentValue - purchaseValue)
        }
    }

    var profitLossRate: Double {
        let totalPurchaseValue = player.holdings.reduce(0) { total, holding in
            total + (holding.quantity * holding.averagePrice)
        }
        guard totalPurchaseValue > 0 else { return 0 }
        return (totalProfitLoss / totalPurchaseValue) * 100
    }

    var body: some View {
        VStack(spacing: 16) {
            // 보유 자산 요약
            VStack(spacing: 8) {
                HStack {
                    Text("보유 자산")
                    Spacer()
                    Text("₩\(Int(totalHoldingValue))")
                        .fontWeight(.semibold)
                }

                HStack {
                    Text("평가손익")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("₩\(Int(totalProfitLoss))")
                            .fontWeight(.bold)
                            .foregroundColor(totalProfitLoss >= 0 ? .green : .red)
                        Text("\(profitLossRate >= 0 ? "+" : "")\(profitLossRate, specifier: "%.2f")%")
                            .font(.caption)
                            .foregroundColor(totalProfitLoss >= 0 ? .green : .red)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)

            // 보유 코인 목록
            if player.holdings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("보유 중인 코인이 없습니다")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("코인을 매수해보세요!")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(player.holdings, id: \.id) { holding in
                            if let coin = coins.first(where: { $0.id == holding.coinId }) {
                                HoldingRowView(
                                    holding: holding,
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
            }
        }
        .alert("거래 결과", isPresented: $showingTradeResult) {
            Button("확인") {}
        } message: {
            Text(tradeResultMessage)
        }
    }
}

struct HoldingRowView: View {
    let holding: CoinHolding
    let coin: Coin
    @Bindable var player: Player
    let tradeManager: TradeManager?
    let onTradeResult: (String) -> Void

    @State private var showingSellSheet = false

    private var currentValue: Double {
        holding.quantity * coin.currentPrice
    }

    private var purchaseValue: Double {
        holding.quantity * holding.averagePrice
    }

    private var profitLoss: Double {
        currentValue - purchaseValue
    }

    private var profitLossRate: Double {
        guard purchaseValue > 0 else { return 0 }
        return (profitLoss / purchaseValue) * 100
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.name)
                        .font(.headline)
                    Text(coin.symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("₩\(Int(coin.currentPrice))")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("보유: \(holding.quantity, specifier: "%.4f")")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("평균단가")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("₩\(Int(holding.averagePrice))")
                        .font(.body)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("평가손익")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("₩\(Int(profitLoss))")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(profitLoss >= 0 ? .green : .red)
                        Text("(\(profitLossRate >= 0 ? "+" : "")\(profitLossRate, specifier: "%.2f")%)")
                            .font(.caption)
                            .foregroundColor(profitLoss >= 0 ? .green : .red)
                    }
                }
            }

            HStack {
                Text("현재가치: ₩\(Int(currentValue))")
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Button("매도") {
                    showingSellSheet = true
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingSellSheet) {
            TradeSheetView(
                coin: coin,
                player: player,
                tradeManager: tradeManager,
                isSellingMode: true,
                onTradeResult: onTradeResult
            )
        }
    }
}

#Preview {
    let schema = Schema([
        Coin.self,
        PriceRecord.self,
        Player.self,
        CoinHolding.self,
        GameRecord.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])

    let player = Player(name: "테스트")
    let coin = Coin(name: "비트코인", symbol: "BTC", currentPrice: 50_000_000.0)
    player.addHolding(coinId: coin.id, quantity: 0.001, purchasePrice: 48_000_000.0)

    container.mainContext.insert(player)
    container.mainContext.insert(coin)

    return HoldingView(
        player: player,
        coins: [coin],
        tradeManager: nil
    )
    .modelContainer(container)
}
