import SwiftData
import SwiftUI

struct ResultView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query private var gameRecords: [GameRecord]

    let gameRecord: GameRecord?

    private let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    var displayRecord: GameRecord? {
        // 전달받은 gameRecord가 있으면 그것을 사용, 없으면 최신 기록 사용
        return gameRecord ?? gameRecords.filter { $0.isCompleted }.max { $0.endDate! < $1.endDate! }
    }

    var body: some View {
        VStack {
            gameRecordInfo

            Spacer()
            bottomText

            againButton
        }
        .padding()
    }

    @ViewBuilder
    private var gameRecordInfo: some View {
        if let record = displayRecord {
            VStack {
                Text("총 자산")
                    .font(.system(size: 28))
                    .bold()
                    .padding(.bottom, 5)

                Text("\(formatter.string(from: NSNumber(value: record.finalAssets)) ?? "0")원")
                    .font(.system(size: 40))

                Text("수익률: \(String(format: "%.0f", record.profitRate))%")
                    .font(.system(size: 20))
                    .bold()
            }
            .padding()
        }
    }

    private var againButton: some View {
        Button("다시 하기") {
            router.currentRoute = .start
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
    }


    private var bottomText: some View {
        if let rate = displayRecord?.profitRate {
            if rate > 10 {
                AnyView(RisingTextView())
            } else if rate < -10 {
                AnyView(FallingTextView())
            } else {
                AnyView(SlidingTextView())
            }
        } else {
            AnyView(EmptyView())
        }
    }

    struct RisingTextView: View {
        @State private var rise = false

        var body: some View {
            VStack(spacing: 0) {
                Text("극")
                Text("락")
            }
            .font(.system(size: 220, weight: .black))
            .offset(y: rise ? -30 : 300)
            .animation(.interpolatingSpring(stiffness: 70, damping: 8), value: rise)
            .onAppear {
                rise = true
            }
        }
    }

    struct SlidingTextView: View {
        @State private var show = false

        var body: some View {
            HStack(spacing: 0) {
                Text("쫄")
                    .rotationEffect(.degrees(-15))
                    .offset(y: -10)
                Text("...")
                Text("?")
            }
            .font(.system(size: 100, weight: .black))
            .offset(x: show ? 0 : -500)
            .offset(y: -250)
            .animation(.easeOut(duration: 1.0), value: show)
            .onAppear {
                show = true
            }
        }
    }

    struct FallingTextView: View {
        @State private var fall = false

        var body: some View {
            ZStack {
                Text("나")
                    .font(.system(size: 220, weight: .black))
                    .rotationEffect(.degrees(-20))
                    .offset(x: -50, y: fall ? -250 : -300)
                    .animation(.interpolatingSpring(stiffness: 70, damping: 8).delay(0.1), value: fall)

                Text("락")
                    .font(.system(size: 220, weight: .black))
                    .rotationEffect(.degrees(20))
                    .offset(x: 40, y: fall ? -20 : -300)
                    .animation(.interpolatingSpring(stiffness: 70, damping: 8).delay(0.2), value: fall)
            }
            .onAppear {
                fall = true
            }
        }
    }

  
  private var bottomText: some View {
      if let rate = displayRecord?.profitRate {
          if rate > 10 {
              AnyView(RisingTextView())
          } else if rate < -10 {
              AnyView(FallingTextView())
          } else {
              AnyView(SlidingTextView())
          }
      } else {
          AnyView(EmptyView())
      }
  }

  
  struct RisingTextView: View {
      @State private var rise = false

      var body: some View {
          VStack(spacing: 0) {
              Text("극")
              Text("락")
          }
          .font(.system(size: 220, weight: .black))
          .offset(y: rise ? -30 : 300)
          .animation(.interpolatingSpring(stiffness: 70, damping: 8), value: rise)
          .onAppear {
              rise = true
          }
      }
  }

  struct SlidingTextView: View {
      @State private var show = false

      var body: some View {
          HStack(spacing: 0) {
              Text("쫄")
                  .rotationEffect(.degrees(-15))
                  .offset(y: -10)
              Text("...")
              Text("?")
          }
          .font(.system(size: 100, weight: .black))
          .offset(x: show ? 0 : -500)
          .offset(y: -250)
          .animation(.easeOut(duration: 1.0), value: show)
          .onAppear {
              show = true
          }
      }
  }
  
  struct FallingTextView: View {
      @State private var fall = false

      var body: some View {
          ZStack {
              Text("나")
                  .font(.system(size: 220, weight: .black))
                  .rotationEffect(.degrees(-20))
                  .offset(x: -50, y: fall ? -250 : -300)
                  .animation(.interpolatingSpring(stiffness: 70, damping: 8).delay(0.1), value: fall)

              Text("락")
                  .font(.system(size: 220, weight: .black))
                  .rotationEffect(.degrees(20))
                  .offset(x: 40, y: fall ? -20 : -300)
                  .animation(.interpolatingSpring(stiffness: 70, damping: 8).delay(0.2), value: fall)
          }
          .onAppear {
              fall = true
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

    // 샘플 게임 기록
    let sampleRecord = GameRecord(playerId: UUID(), initialCash: 1_000_000.0)
    sampleRecord.completeGame(finalAssets: 1_350_000.0)
    container.mainContext.insert(sampleRecord)

    return ResultView(gameRecord: sampleRecord)
        .modelContainer(container)
        .environment(AppRouter())
}
