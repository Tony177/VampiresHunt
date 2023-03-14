//
//  MainView.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 06/12/22.
//

import SwiftUI
import SpriteKit
import GameKit
struct MainView: View {
    
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 256, height: 256)
        scene.scaleMode = .resizeFill
        scene.previousView = self
        let reveal = SKTransition.reveal(with: .down,duration: 1000)
        scene.view?.presentScene(scene, transition: reveal)
        return scene
    }

    var body: some View {
        NavigationStack{
            ZStack{
                Image("TitleScreen").resizable().frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
                VStack(spacing:15){
                    NavigationLink {
                        SpriteView(scene: self.scene)
                            .ignoresSafeArea()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        ZStack{
                            Image("bgButton")
                            Text(LocalizedStringKey("START")).font(.custom("CasaleTwo NBP", size: 20)).foregroundColor(.customRed)
                        }
                    }
                    NavigationLink {
                        SettingsView()
                    } label: {
                        ZStack{
                            Image("bgButton")
                            Text(LocalizedStringKey("SETTINGS")).font(.custom("CasaleTwo NBP", size: 20)).foregroundColor(.customRed)
                        }
                    }
                }
            }
        }
    }
}

