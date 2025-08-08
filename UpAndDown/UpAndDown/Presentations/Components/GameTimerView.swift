import SwiftUI

struct GameTimerView: View {
    let gameTimer: GameTimer
    
    var body: some View {
        VStack {
            Text("남은 시간")
                .font(.headline)
            Text(gameTimer.formattedTime)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(gameTimer.timeRemaining < 60 ? .red : .primary)

            ProgressView(value: gameTimer.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

