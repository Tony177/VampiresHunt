//
//  EndView.swift
//  Vampire's Hunt
//
//  Created by Antonio Avolio on 14/03/23.
//

import SwiftUI
import SpriteKit
import GameKit

struct EndView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 256, height: 256)
        scene.scaleMode = .resizeFill
        scene.view?.ignoresSiblingOrder = true
        scene.view?.shouldCullNonVisibleNodes = true
        let reveal = SKTransition.reveal(with: .down,duration: 1000)
        scene.view?.presentScene(scene, transition: reveal)
        return scene
    }
    @Binding var score: Int
    @Binding var time: TimeInterval
    let dateFormatter = DateComponentsFormatter()
    var body: some View {
        NavigationStack{
            ZStack{
                Image("TitleScreen").resizable().ignoresSafeArea()
                VStack{
                    HStack{
                        Text(LocalizedStringKey("score"))
                        Text(score.formatted())
                    }
                    HStack{
                        Text(LocalizedStringKey("time"))
                        Text(dateFormatter.string(from:time)!)
                    }
                    Spacer().frame(height: 0)
                    NavigationLink {
                        SpriteView(scene: self.scene)
                            .ignoresSafeArea()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        ZStack{
                            Image("bgButton")
                            Text(LocalizedStringKey("RETRY")).font(.custom("CasaleTwo NBP", size: 20)).foregroundColor(.customRed)
                        }
                    }
                }.font(.custom("CasaleTwo NBP", size: 30))
                    .foregroundColor(.customRed)
            }
        }.onDisappear(){
            GKAccessPoint.shared.isActive = false
        }
        .onAppear(){
            GKAccessPoint.shared.isActive = true
        }
    }
}

struct EndView_Previews: PreviewProvider {
    static var previews: some View {
        EndView(score: Binding.constant(960), time: Binding.constant(TimeInterval(150))).previewInterfaceOrientation(.landscapeRight)
    }
}
