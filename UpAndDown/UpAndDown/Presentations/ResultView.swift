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
        // 디버깅을 위한 로그
        print("ResultView - 전달받은 gameRecord: \(gameRecord?.id.uuidString ?? "nil")")
        print("ResultView - 저장된 gameRecords 개수: \(gameRecords.count)")
        print("ResultView - 완료된 gameRecords 개수: \(gameRecords.filter { $0.isCompleted }.count)")
        
        // 전달받은 gameRecord가 있으면 그것을 사용
        if let gameRecord = gameRecord {
            print("ResultView - 전달받은 기록 사용: 최종자산=\(gameRecord.finalAssets), 수익률=\(gameRecord.profitRate)%")
            return gameRecord
        }
        
        // 없으면 최신 완료된 기록 사용
        let latestRecord = gameRecords.filter { $0.isCompleted }.max { $0.endDate! < $1.endDate! }
        if let latest = latestRecord {
            print("ResultView - 최신 기록 사용: 최종자산=\(latest.finalAssets), 수익률=\(latest.profitRate)%")
        } else {
            print("ResultView - ⚠️ 표시할 기록이 없음")
        }
        
        return latestRecord
    }

    var body: some View {
        ZStack {
            backgroundImage
            VStack {
                gameRecordInfo

                Spacer()
                bottomText

                againButton
            }
            .padding()
        }
    }

    @ViewBuilder
    private var backgroundImage: some View {
        if let rate = displayRecord?.profitRate {
            if rate > 10 {
                Image("hell")
                    .resizable()
                    .scaledToFill()
                    .frame(width: .infinity, height: .infinity)
                    .clipped()
                    .ignoresSafeArea()
            } else if rate < -10 {
                Image("hell")
                    .resizable()
                    .scaledToFill()
                    .frame(width: .infinity, height: .infinity)
                    .clipped()
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private var gameRecordInfo: some View {
        if let record = displayRecord {
            let isExtreme = record.profitRate > 10 || record.profitRate < -10
            let content = VStack {
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

            content
                .padding()
                .foregroundStyle(isExtreme ? .white : .primary)
                .shadow(color: isExtreme ? .black : .clear, radius: 4, x: 0, y: 2)
        } else {
            // 기록이 없을 때 기본값 표시
            VStack {
                Text("총 자산")
                    .font(.system(size: 28))
                    .bold()
                    .padding(.bottom, 5)

                Text("1,000,000원")
                    .font(.system(size: 40))

                Text("수익률: 0%")
                    .font(.system(size: 20))
                    .bold()
            }
            .padding()
        }
    }

    private var againButton: some View {
        Button("다시 하기") {
//            let schema = [
//                Coin,
//                PriceRecord,
//                Player,
//                CoinHolding,
//            ]
            
            router.currentRoute = .start
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
    }

    private var isHalfLoss: Bool {
        guard let rate = displayRecord?.profitRate else { return false }
        return rate >= -50.0 && rate <= -49.0
    }

    private var bottomText: some View {
        if isHalfLoss {
            if Bool.random() {
                AnyView(HangangWaterTempView())
            } else {
                AnyView(BrokenCoinView())
            }
        } else if let rate = displayRecord?.profitRate {
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
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 6, x: 0, y: 2)
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
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 6, x: 0, y: 2)
                    .offset(x: -50, y: fall ? -250 : -300)
                    .animation(.interpolatingSpring(stiffness: 70, damping: 8).delay(0.1), value: fall)

                Text("락")
                    .font(.system(size: 220, weight: .black))
                    .rotationEffect(.degrees(20))
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 6, x: 0, y: 2)
                    .offset(x: 40, y: fall ? -20 : -300)
                    .animation(.interpolatingSpring(stiffness: 70, damping: 8).delay(0.2), value: fall)
            }
            .onAppear {
                fall = true
            }
        }
    }

    struct HangangWaterTempView: View {
        var body: some View {
            VStack(spacing: 8) {
                Text("오늘,")
                Text("한강의")
                Text("물 온도는")
                Text("몇 도?")
            }
            .font(.system(size: 36, weight: .black))
            .kerning(10)
            .offset(y: -200)
            .multilineTextAlignment(.center)
        }
    }

    struct BrokenCoinView: View {
        var body: some View {
            VStack(spacing: -30) {
                Text("반")
                Text("토")
                Text("막")
            }
            .font(.system(size: 100, weight: .black))
            .offset(x: 40, y: -120)
            .rotationEffect(.degrees(-10))
            .overlay(
                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .rotation(.degrees(40))
                    .frame(width: 120, height: 120)
                    .offset(x: -50, y: -10)
                    .scaleEffect(1.3)
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

    // 샘플 게임 기록
    let sampleRecord = GameRecord(playerId: UUID(), initialCash: 1_000_000.0)
    sampleRecord.completeGame(finalAssets: 1_350_000.0)
    container.mainContext.insert(sampleRecord)

    return ResultView(gameRecord: sampleRecord)
        .modelContainer(container)
        .environment(AppRouter())
}
