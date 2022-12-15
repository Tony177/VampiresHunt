//
//  MainView.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 06/12/22.
//

import SwiftUI
import SpriteKit

struct MainView: View {

    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 256, height: 256)
        scene.scaleMode = .resizeFill
        let reveal = SKTransition.reveal(with: .down,duration: 1)
        scene.view?.presentScene(scene, transition: reveal)
        return scene
    }
    
    @State var isStartGame = false
    
    var body: some View {
        ZStack{
            Image("TitleScreen").resizable().frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
            VStack{
                Button {
                    isStartGame.toggle()
                } label: {
                    Image("StartButton")
                }.fullScreenCover(isPresented: $isStartGame) {
                    SpriteView(scene: self.scene)
                        .ignoresSafeArea()
                        .previewInterfaceOrientation(.landscapeRight)
                }
                Spacer().frame(height: 50)
            }
        }
    }
}


