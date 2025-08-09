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
    @Binding var currentPlayer: Player?
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
        Button {
            startGame()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)

                Text("게임 시작")
                    .padding(40)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            .contentShape(Rectangle())
        }
        .padding(.horizontal, 16)
        
//        Button("게임 시작") {
//            startGame()
//        }
//        .font(.title2)
//        .padding()
//        .background(Color.black)
//        .foregroundColor(.white)
//        .clipShape(RoundedRectangle(cornerRadius: 8))
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

        // 기존 게임용 플레이어들만 삭제 (완료되지 않은 게임들)
        do {
            let incompletePlayers = try modelContext.fetch(FetchDescriptor<Player>())
            let incompleteGameRecords = try modelContext.fetch(FetchDescriptor<GameRecord>(
                predicate: #Predicate<GameRecord> { record in
                    !record.isCompleted
                }
            ))

            // 미완료 게임 기록의 플레이어들만 삭제
            let incompletePlayerIds = Set(incompleteGameRecords.map { $0.playerId })
            for player in incompletePlayers {
                if incompletePlayerIds.contains(player.id) {
                    modelContext.delete(player)
                }
            }

            // 미완료 게임 기록들도 삭제
            for record in incompleteGameRecords {
                modelContext.delete(record)
            }
            
            
//            let fetchDescriptor1 = FetchDescriptor<Coin>()
//            guard let items = try? modelContext.fetch(fetchDescriptor1) else {
//                return
//            }
//            for item in items {
//                modelContext.delete(item)
//            }
            
            let fetchDescriptor2 = FetchDescriptor<PriceRecord>()
            guard let items = try? modelContext.fetch(fetchDescriptor2) else {
                return
            }
            for item in items {
                modelContext.delete(item)
            }
            
//            let fetchDescriptor3 = FetchDescriptor<Player>()
//            guard let items = try? modelContext.fetch(fetchDescriptor3) else {
//                return
//            }
//            for item in items {
//                modelContext.delete(item)
//            }
            
            let fetchDescriptor4 = FetchDescriptor<CoinHolding>()
            guard let items = try? modelContext.fetch(fetchDescriptor4) else {
                return
            }
            for item in items {
                modelContext.delete(item)
            }
            

            try modelContext.save()
            print("미완료 게임 데이터 정리 완료")
        } catch {
            print("기존 데이터 정리 실패: \(error)")
        }

        // 완전히 새로운 플레이어 생성
        let newPlayer = Player(name: "플레이어")
        // 확실히 100만원으로 설정
        newPlayer.cash = 1_000_000.0
        newPlayer.holdings = []

        modelContext.insert(newPlayer)
        currentPlayer = newPlayer

        print("새 게임 시작: 플레이어 ID=\(newPlayer.id), 현금=\(newPlayer.cash)")

        // 새 게임 기록 생성
        currentGameRecord = GameRecord(playerId: newPlayer.id, initialCash: 1_000_000.0)
        if let gameRecord = currentGameRecord {
            modelContext.insert(gameRecord)
            print("새 게임 기록 생성: ID=\(gameRecord.id), 플레이어ID=\(gameRecord.playerId)")
        }

        // 게임 시작
        gameTimer.startGame()
        priceManager?.startPriceUpdates()

        do {
            try modelContext.save()
            modelContext.processPendingChanges()
            print("새 게임 시작 완료")
        } catch {
            print("게임 시작 실패: \(error)")
        }
    }
}

//
// #Preview {
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
// }
