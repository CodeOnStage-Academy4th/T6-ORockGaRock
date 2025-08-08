import SwiftData
import SwiftUI

struct StartView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var gameRecords: [GameRecord]
    @EnvironmentObject var toastManager: ToastManager

    let router: AppRouter
    let gameTimer: GameTimer
    let priceManager: PriceManager?
    let tradeManager: TradeManager?
    @Binding var currentPlayer: UUID?
    @Binding var currentGameRecord: GameRecord?


    var body: some View {
        VStack {

            Spacer()

            title

            subtitle

            Spacer()

            rankingList

            Spacer()

            startButton
        }
    }

    private var title: some View {
        Text("오르樂\n내리落")
            .font(.system(size: 80, weight: .bold))
            .padding()
    }

    private var subtitle: some View {
        Text("단타 투자를 통해\n극락과 나락을 맛보자")
            .font(.system(size: 17))
            .multilineTextAlignment(.center)
    }

    private var rankingList: some View {
        VStack(alignment: .leading, spacing: 10) {
            let top3Records = gameRecords
                .filter { $0.isCompleted }
                .sorted { $0.finalAssets > $1.finalAssets }
                .prefix(3)

            ForEach(Array(top3Records.enumerated()), id: \.element.id) { index, record in
                HStack {
                    Text("\(index + 1)등")
                        .bold()
                        .frame(width: 40)
                        .padding(3)
                        .foregroundColor(index == 0 ? .white : .black)
                        .background(
                            Circle().fill(index == 0 ? Color.black : Color.clear)
                        )
                    Text("\(String(format: "%.0f", record.finalAssets))원")
                }
            }

            if let latest = currentGameRecord, latest.isCompleted {
                HStack {
                    Text("New")
                        .bold()
                        .frame(width: 40)
                        .padding(3)

                    Text("\(String(format: "%.0f", latest.finalAssets))원")
                }
            }
        }
        .padding()
    }

    private var startButton: some View {
        Button("게임 시작") {
            startGame()
        }
        .font(.title2)
        .padding()
        .background(Color.black)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    private func startGame() {
        // 게임 시작 토스트 표시
        toastManager.showToast(
            title: "게임이 곧 시작됩니다!",
            description: "5분간 최대한 많은 수익을 내보세요",
            duration: 2.0
        ) {
            // 토스트가 끝난 후 게임 화면으로 이동
            self.router.currentRoute = .game
        }
        
        // 새 플레이어 생성
        let newPlayer = Player(name: "플레이어")
        modelContext.insert(newPlayer)
        currentPlayer = newPlayer.id

        // 게임 기록 생성
        currentGameRecord = GameRecord(playerId: newPlayer.id, initialCash: newPlayer.cash)
        if let gameRecord = currentGameRecord {
            modelContext.insert(gameRecord)
        }

        // 게임 시작
        gameTimer.startGame()
        priceManager?.startPriceUpdates()

        do {
            try modelContext.save()
        } catch {
            print("게임 시작 실패: \(error)")
        }
    }
}
//
//#Preview {
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
//    // 샘플 게임 기록들
//    let records = [
//        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
//        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
//        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
//        GameRecord(playerId: UUID(), initialCash: 1_000_000.0),
//    ]
//
//    records[0].completeGame(finalAssets: 1_850_000.0)
//    records[1].completeGame(finalAssets: 1_650_000.0)
//    records[2].completeGame(finalAssets: 1_420_000.0)
//    records[3].completeGame(finalAssets: 950_000.0)
//
//    for record in records {
//        container.mainContext.insert(record)
//    }
//
//    @State var currentPlayer: Player? = nil
//    @State var currentGameRecord: GameRecord? = nil
//
////    return StartView(
////        router: AppRouter(),
////        gameTimer: GameTimer(),
////        priceManager: nil,
////        tradeManager: nil,
////        currentPlayer: $currentPlayer,
////        currentGameRecord: $currentGameRecord
////    )
////    .modelContainer(container)
//}
