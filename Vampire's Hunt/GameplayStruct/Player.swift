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
        self.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        self.zPosition = Layer.player.rawValue
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: 0.0, y: self.size.height / 2))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.arrow
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func walk(){
        guard let walkTextures = walkTextures else { preconditionFailure("Could not find textures!") }
        startAnimation(texture: walkTextures, speed: 0.25, name: PlayerAnimationTye.walk.rawValue, count: 0, resize: true, restore: true)
    }
    
    func moveToPosition(pos: CGPoint, direction: String, duration: TimeInterval){
        switch direction{
        case "L":
            xScale = -abs(xScale)
        default:
            xScale = abs(xScale)
        }
        let moveAction = SKAction.move(to: pos, duration: speed)
        run(moveAction)
    }
    
    func setupConstraints(floor: CGFloat){
        let range = SKRange(lowerLimit: floor, upperLimit: floor)
        let lockToPlatform = SKConstraint.positionY(range)
        constraints = [lockToPlatform]
    }
    
}
