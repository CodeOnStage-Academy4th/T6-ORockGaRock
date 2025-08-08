//
//  DevView.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import SwiftData
import SwiftUI

struct DevView: View {
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

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 타이머 표시
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

                if !isGameStarted {
                    // 게임 시작 화면
                    VStack(spacing: 20) {
                        Text("코인 단타 게임")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("5분 동안 최대한 많은 수익을 올려보세요!")
                            .font(.title3)
                            .multilineTextAlignment(.center)

                        Button("게임 시작") {
                            startGame()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.title2)
                        .padding()
                    }
                } else {
                    // 게임 진행 화면
                    if let player = currentPlayer {
                        GameView(
                            player: player,
                            coins: coins,
                            tradeManager: tradeManager,
                            gameTimer: gameTimer
                        )
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("UpAndDown")
            .onAppear {
                setupGame()
            }
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

    private func endGame() {
        priceManager?.stopPriceUpdates()
        isGameStarted = false

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
    DevView()
        .modelContainer(for: [Coin.self, Player.self, GameRecord.self], inMemory: true)
}
