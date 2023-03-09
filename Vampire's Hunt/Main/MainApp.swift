//
//  MainApp.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 06/12/22.
//

import SwiftUI
import GameKit

@main
struct MainApp: App {
    @State var firstAppear: Bool = false
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear(){
                    if(!firstAppear){
                        firstAppear = true
                        authenticateGK()
                    }
            }
        }
    }
    private func authenticateGK(){
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // Present the view controller so the player can sign in.
                let gameCenterController = GKGameCenterViewController(
                                leaderboardID: "com.nanashi.vhpoint",
                                playerScope: .global,
                                timeScope: .allTime)
                viewController.present(gameCenterController, animated: true, completion: nil)
                return
            }
            if error != nil {
                enabledGameCenter = false
                print(error ?? "Generic error authentication")
                // Player could not be authenticated.
                // Disable Game Center in the game.
                return
            }
            enabledGameCenter = true
            // Perform any other configurations as needed (for example, access point).
            
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
        }
    }
}

