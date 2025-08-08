import SwiftUI
import SwiftData

struct ResultView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Query private var gameRecords: [GameRecord]
    
    var latestRecord: GameRecord? {
        gameRecords.filter { $0.isCompleted }.max { $0.endDate! < $1.endDate! }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("게임 결과")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let record = latestRecord {
                VStack(spacing: 10) {
                    Text("최종 자산: \(String(format: "%.0f", record.finalAssets))원")
                        .font(.title2)
                    
                    Text("수익률: \(String(format: "%.1f", record.profitRate))%")
                        .font(.title3)
                        .foregroundColor(record.profit >= 0 ? .green : .red)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            VStack(spacing: 12) {
                Button("다시 하기") {
                    router.currentRoute = .start
                }
                .buttonStyle(.borderedProminent)
                
            }
        }
        .padding()
    }
}


