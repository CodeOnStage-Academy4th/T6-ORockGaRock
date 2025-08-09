//
//  GameTimer.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import Foundation

@Observable
class GameTimer {
    private(set) var timeRemaining: TimeInterval = 60 // 5분 = 300초
    private(set) var isRunning = false
    private(set) var isGameOver = false

    private var timer: Timer?
    private let gameDuration: TimeInterval = 60 // 5분

    var onGameEnd: (() -> Void)?
    var onTimeUpdate: ((TimeInterval) -> Void)?

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progressPercentage: Double {
        return (gameDuration - timeRemaining) / gameDuration
    }

    func startGame() {
        guard !isRunning else { return }

        timeRemaining = gameDuration
        isRunning = true
        isGameOver = false

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimer()
        }
    }

    func pauseGame() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func resumeGame() {
        guard !isRunning, !isGameOver else { return }

        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimer()
        }
    }

    func stopGame() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isGameOver = true
        timeRemaining = 0
        onGameEnd?()
    }

    func resetGame() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isGameOver = false
        timeRemaining = gameDuration
    }

    private func updateTimer() {
        timeRemaining -= 1
        onTimeUpdate?(timeRemaining)

        if timeRemaining <= 0 {
            stopGame()
        }
    }

    deinit {
        timer?.invalidate()
    }
}
