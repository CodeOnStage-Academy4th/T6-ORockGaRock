import SwiftUI
import SwiftData

struct StartView: View{
  
  @Environment(\.modelContext) private var modelContext
  @Query private var coins: [Coin]
  @Query private var players: [Player]
  @Query private var gameRecords: [GameRecord]
  
  @State private var gameTimer = GameTimer()
  @State private var priceManager: PriceManager?
  @State private var tradeManager: TradeManager?
  @State private var currentPlayer: Player?
  @State private var currentGameRecord: GameRecord?
  @State private var isGameStarted = false
  
  var body: some View{
    VStack {
      
      Spacer()
      
      title
      
      subtitle
      
      Spacer()
      
      rankingList
      
      Spacer()
      
      if !isGameStarted {
        startButton
      }
      else {
        if let player = currentPlayer {
            GameView(
                player: player,
                coins: coins,
                tradeManager: tradeManager,
                gameTimer: gameTimer
            )
        }
      }
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
              Text("New")
              .bold()
              .frame(width: 40)
              .padding(3)
            
              Text("\(String(format: "%.0f", latest.finalAssets))원")

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
      // 새 플레이어 생성
      currentPlayer = Player(name: "플레이어")
      if let player = currentPlayer {
          modelContext.insert(player)
          
          // 게임 기록 생성
          currentGameRecord = GameRecord(playerId: player.id, initialCash: player.cash)
          if let gameRecord = currentGameRecord {
              modelContext.insert(gameRecord)
          }
      }
      
      // 게임 시작
      isGameStarted = true
      gameTimer.startGame()
      priceManager?.startPriceUpdates()
      
      do {
          try modelContext.save()
      } catch {
          print("게임 시작 실패: \(error)")
      }
  }
  
}


#Preview {
    let container = try! ModelContainer(for: GameRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    
    // 샘플 게임 기록들
    let records = [
        GameRecord(playerId: UUID(), initialCash: 1000000.0),
        GameRecord(playerId: UUID(), initialCash: 1000000.0),
        GameRecord(playerId: UUID(), initialCash: 1000000.0),
        GameRecord(playerId: UUID(), initialCash: 1000000.0)
    ]
    
    records[0].completeGame(finalAssets: 1850000.0)
    records[1].completeGame(finalAssets: 1650000.0)
    records[2].completeGame(finalAssets: 1420000.0)
    records[3].completeGame(finalAssets: 950000.0)
    
    for record in records {
        container.mainContext.insert(record)
    }
    
    return StartView()
        .modelContainer(container)
}
