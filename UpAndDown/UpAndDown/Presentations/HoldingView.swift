import SwiftData
import SwiftUI

struct HoldingView: View {
    @Bindable var player: Player
    let coins: [Coin]
    let tradeManager: TradeManager?
    let gameTimer: GameTimer
    let currentPlayer: Player

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
        ZStack {
            Color.white01
                .ignoresSafeArea()
            VStack(spacing: 10) {
                topContents
                
                // 보유 자산 요약
                VStack(spacing: 15) {
                    Text("총 자산")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("\(Int(totalHoldingValue+player.cash)) 원")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("총 수익률: \(String(format: "%.2f", profitLossRate))%")
                        .fontWeight(.semibold)
                    HStack(){
                        Text("현금자산")
                        Spacer()
                        Text("\(Int(player.cash)) 원")
                    }
                    .font(.title3)
                    .padding(.horizontal, 100)
                    
                }

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
                        .padding()
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
    private var topContents: some View {
        HStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Text(gameTimer.formattedTime)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 70)

                Image(.clock)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }

            Spacer()

            HStack(spacing: 8) {
                Text(currentPlayer.cash, format: .currency(code: "KRW"))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black)

                Image(.won)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
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
    
    private var profitPrefix: String {
        profitLossRate > 0 ? "+" : ""
    }

    var body: some View {
        HStack(spacing: 8){
            VStack(alignment: .leading, spacing: 4){
                Text(coin.name)
                    .font(.title)
                    .fontWeight(.heavy)
                HStack{
                    Text("₩ \(coin.currentPrice, specifier: "%.0f")")
                        .font(.headline)
                    Text("(\(profitPrefix)\(profitLossRate, specifier: "%.1f%")%)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(
                            profitLossRate > 0 ? .red :
                            (profitLossRate == 0 ? .black : .blue)
                        )
                }
            }
            Spacer()
            HStack{
                VStack(alignment:.trailing, spacing: 5){
                    HStack{
                        Text("보유수량")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(holding.quantity,specifier: "%.3f") 개")
                    }
                    HStack{
                        Text("평균매수가")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(purchaseValue, specifier: "%.f") 원")
                    }
                    HStack{
                        Text("평가손익")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(profitPrefix)\(profitLoss, specifier: "%.f") 원")
                            .foregroundColor(
                                profitLossRate > 0 ? .red :
                                (profitLossRate == 0 ? .black : .blue)
                            )
                    }
                    HStack{
                        Text("평가금액")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(currentValue, specifier: "%.f") 원")
                            .foregroundColor(
                                profitLossRate > 0 ? .red :
                                (profitLossRate == 0 ? .black : .blue)
                            )
                    }
                }
                .monospacedDigit()
                .frame(width: 160, alignment: .trailing)

            }
            .font(.system(size: 13))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
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
//    let schema = Schema([
//        Coin.self,
//        PriceRecord.self,
//        Player.self,
//        CoinHolding.self,
//        GameRecord.self,
//    ])
//    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: schema, configurations: [modelConfiguration])
//
//    let player = Player(name: "테스트")
//    let coin = Coin(name: "비트코인", symbol: "BTC", currentPrice: 50_000_000.0)
//    player.addHolding(coinId: coin.id, quantity: 0.001, purchasePrice: 48_000_000.0)
//
//    container.mainContext.insert(player)
//    container.mainContext.insert(coin)
//
//    return HoldingView(
//        player: player,
//        coins: [coin],
//        tradeManager: nil,
//    )
//    .modelContainer(container)
}
