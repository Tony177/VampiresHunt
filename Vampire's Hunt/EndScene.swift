//
//  GameEndScene.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 07/12/22.
//

import SpriteKit

class EndScene : SKScene {
    
    override func didMove(to view: SKView) {
        let leaderboard : Leaderboard = decodeLeaderboard(userDefaultsKey: "score")
        var i : Int = 1
        for e in leaderboard.records{
            let element = SKLabelNode()
            element.position = CGPoint(x: size.width/2, y: size.height * (0.90 - CGFloat(i)*0.05))
            element.text = String(i) + ". " + e.name + "   " + String(e.score)
            element.fontSize = 20
            i+=1
            addChild(element)
        }
        let restartButton = SKSpriteNode(imageNamed: "RetryButton")
        restartButton.position = CGPoint(x: size.width/2, y: size.height*0.2)
        restartButton.name = "restart"
        addChild(restartButton)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            let touchPointName = atPoint(loc).name
            if touchPointName == "restart"{
                removeAllChildren()
                let Button = SKSpriteNode(imageNamed: "PremutoRetry")
                Button.position = CGPoint(x: size.width/2, y: size.height*0.2)
                Button.name = "restart"
                addChild(Button)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    let reveal = SKTransition.reveal(with: .down, duration: 1)
                    let newScene = GameScene()
                    newScene.size = CGSize(width: 256, height: 256)
                    newScene.scaleMode = .resizeFill
                    self.scene?.view?.presentScene(newScene, transition: reveal)
                }
            }
            
        }
    }
}
