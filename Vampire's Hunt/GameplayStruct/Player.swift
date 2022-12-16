//
//  Player.swift
//  Vampire's Hunt
//
//  Created by Nanshi on 12/12/22.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode{
    
    private var walkTextures: [SKTexture]?
    
    enum PlayerAnimationTye: String{
        case walk
    }
    
    init(){
        let texture = SKTexture(imageNamed: "VampireWalk1")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.walkTextures = self.loadTexture(atlas: "Vampire", prefix: "VampireWalk", startsAt: 1, stopAt: 3)
        self.name = "player"
        self.setScale(1.0)
        self.position = CGPoint(x: size.width/2, y: size.height*0.6)
        self.zPosition = Layer.player.rawValue       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func walk(){
        guard let walkTextures = walkTextures else { preconditionFailure("Could not find textures!") }
        startAnimation(texture: walkTextures, speed: 0.4, name: PlayerAnimationTye.walk.rawValue, count: 0, resize: true, restore: true)
    }
}
