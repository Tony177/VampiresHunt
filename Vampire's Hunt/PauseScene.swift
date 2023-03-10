//
//  PauseScene.swift
//  Vampire's Hunt
//
//  Created by Antonio Avolio on 10/03/23.
//

import Foundation
import SpriteKit

class PauseScene: SKScene {
    override func didMove(to view: SKView) {
        addMenu()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    private func addMenu(){
        let background = SKSpriteNode(imageNamed: "pauseBackground")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = Layer.backgroundPause.rawValue
        addChild(background)
        let buttonResume = SKSpriteNode(imageNamed: "pauseResume")
        buttonResume.position = CGPoint(x:self.size.width/2, y:self.size.height/2+50)
        buttonResume.zPosition = Layer.resumePause.rawValue
    }
}
