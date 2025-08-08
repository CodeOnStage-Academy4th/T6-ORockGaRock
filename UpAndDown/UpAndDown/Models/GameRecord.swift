//
//  GameRecord.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import Foundation
import SwiftData

@Model
final class GameRecord {
    var id: UUID
    var playerId: UUID
    var startDate: Date
    var endDate: Date?
    var initialCash: Double
    var finalAssets: Double
    var profit: Double
    var profitRate: Double
    var isCompleted: Bool

    init(playerId: UUID, initialCash: Double) {
        id = UUID()
        self.playerId = playerId
        startDate = Date()
        endDate = nil
        self.initialCash = initialCash
        finalAssets = 0.0
        profit = 0.0
        profitRate = 0.0
        isCompleted = false
    }

    func completeGame(finalAssets: Double) {
        endDate = Date()
        self.finalAssets = finalAssets
        profit = finalAssets - initialCash
        profitRate = (profit / initialCash) * 100
        isCompleted = true
    }

    var gameDuration: TimeInterval? {
        guard let endDate = endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }
}
