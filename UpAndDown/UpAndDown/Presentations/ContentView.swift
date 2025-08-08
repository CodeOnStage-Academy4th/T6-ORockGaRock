import SwiftData
import SwiftUI

@Observable
class AppRouter {
    enum Route {
        case start, game, result
    }

    var currentRoute: Route = .start
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var coins: [Coin]
    @Query private var players: [Player]
    @Query private var gameRecords: [GameRecord]

    @State private var router = AppRouter()
    @State private var gameTimer = GameTimer()
    @State private var priceManager: PriceManager?
    @State private var tradeManager: TradeManager?
    @State private var currentPlayer: Player?
    @State private var currentGameRecord: GameRecord?
    @StateObject private var toastManager = ToastManager()
   

    var body: some View {
        ZStack {
            Group {
                switch router.currentRoute {
                case .start:
                    StartView(
                        router: router,
                        gameTimer: gameTimer,
                        priceManager: priceManager,
                        tradeManager: tradeManager,
                        currentPlayer: $currentPlayer,
                        currentGameRecord: $currentGameRecord
                    )
                case .game:
                    if let player = currentPlayer {

                        TabView {
                            VStack {
                                GameTimerView(gameTimer: gameTimer)
                                PortfolioView(
                                    player: player,
                                    coins: coins,
                                    tradeManager: tradeManager,
                                    gameTimer: gameTimer
                                )
                            }
                            .tabItem {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                Text("거래")
                            }

                            VStack {
                                GameTimerView(gameTimer: gameTimer)
                                HoldingView(
                                    player: player,
                                    coins: coins,
                                    tradeManager: tradeManager
                                )
                            }
                            .tabItem {
                                Image(systemName: "briefcase")
                                Text("보유")
                            }
                        }
                    }
                case .result:
                    ResultView(gameRecord: currentGameRecord)
                }
            }
            .environment(router)
            .environmentObject(toastManager)
            
            // 토스트 뷰를 최상단에 표시
            VStack {
                Spacer()
                ToastView(
                    title: toastManager.title,
                    description: toastManager.description,
                    isVisible: toastManager.isVisible
                )
                Spacer()
            }
            .allowsHitTesting(false) // 터치 이벤트가 뒤의 뷰로 전달되도록
        }
        .onAppear {
            setupGame()
        }
    }

    private func setupGame() {
        priceManager = PriceManager(modelContext: modelContext)

        if let priceManager = priceManager {
            tradeManager = TradeManager(modelContext: modelContext, priceManager: priceManager)
        }

        gameTimer.onGameEnd = {
            endGame()
        }

        // 기본 코인이 없으면 생성
        if coins.isEmpty {
            priceManager?.createDefaultCoins()
        }
    }

    private func endGame() {
        priceManager?.stopPriceUpdates()

        // 게임 종료 토스트 표시
        toastManager.showToast(
            title: "게임 종료!",
            description: "결과를 확인해보세요",
            duration: 2.0
        ) {
            // 토스트가 끝난 후 결과 화면으로 이동
            self.router.currentRoute = .result
        }

        // 게임 기록 완료
        if let player = currentPlayer,
           let gameRecord = currentGameRecord
        {
            gameRecord.completeGame(finalAssets: player.totalAssets)

            do {
                try modelContext.save()
            } catch {
                print("게임 종료 기록 실패: \(error)")
            }
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

    // 샘플 게임 기록들
    let records = [
        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
    ]

    records[0].completeGame(finalAssets: 1_850_000.0)
    records[1].completeGame(finalAssets: 1_650_000.0)
    records[2].completeGame(finalAssets: 1_420_000.0)
    records[3].completeGame(finalAssets: 950_000.0)

    for record in records {
        container.mainContext.insert(record)
    }

    // 샘플 코인들
    let sampleCoins = [
        Coin(name: "비트코인", symbol: "BTC", currentPrice: 50_000_000.0),
        Coin(name: "이더리움", symbol: "ETH", currentPrice: 3_000_000.0),
        Coin(name: "리플", symbol: "XRP", currentPrice: 500.0),
    ]

    for coin in sampleCoins {
        container.mainContext.insert(coin)
    }

    return ContentView()
        .modelContainer(container)
}
