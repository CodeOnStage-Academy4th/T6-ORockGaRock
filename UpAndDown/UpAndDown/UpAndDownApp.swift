//
//  UpAndDownApp.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import SwiftUI
import SwiftData

@main
struct UpAndDownApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Coin.self,
            PriceRecord.self,
            Player.self,
            CoinHolding.self,
            GameRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
