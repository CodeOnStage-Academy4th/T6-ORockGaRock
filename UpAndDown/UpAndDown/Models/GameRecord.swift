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
        self.id = UUID()
        self.playerId = playerId
        self.startDate = Date()
        self.endDate = nil
        self.initialCash = initialCash
        self.finalAssets = 0.0
        self.profit = 0.0
        self.profitRate = 0.0
        self.isCompleted = false
    }
    
    func completeGame(finalAssets: Double) {
        self.endDate = Date()
        self.finalAssets = finalAssets
        self.profit = finalAssets - initialCash
        self.profitRate = (profit / initialCash) * 100
        self.isCompleted = true
    }
    
    var gameDuration: TimeInterval? {
        guard let endDate = endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }
}
