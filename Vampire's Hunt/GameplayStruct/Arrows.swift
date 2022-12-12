//
//  Player.swift
//  Vampire's Hunt
//
//  Created by Nanshi on 12/12/22.
//

import Foundation
import SpriteKit

class Arrow: SKSpriteNode{
    
    private var arrowType: ArrowType = .none
    
    enum ArrowType: String{
        case none
        case arrow
    }
    
    init(arrowType: ArrowType) {
        var texture: SKTexture!
        self.arrowType = arrowType
        switch self.arrowType{
        case .arrow:
            texture = SKTexture(imageNamed: "Arrow1")
        case .none:
            break
        }
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = "co_\(arrowType)"
        self.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.zPosition = Layer.arrow.rawValue
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: 0.0, y: (self.size.height) / 15))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.arrow
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drop(dropSpeed: TimeInterval, floorLevel: CGFloat){
        let pos = CGPoint(x: position.x, y: floorLevel)
        let scaleX = SKAction.scaleX(to: 1.0, duration: 1.0)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1.0)
        let scale = SKAction.group([scaleX, scaleY])
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let moveAction = SKAction.move(to: pos, duration: dropSpeed)
        let actionSequence = SKAction.sequence([appear, scale, moveAction])
        self.scale(to: CGSize(width: 0.25, height: 1.0))
        self.run(actionSequence, withKey: "drop")
    }
    
    func hit(){
        let remouveFromParent = SKAction.removeFromParent()
        self.run(remouveFromParent)
    }
    
    func missed(){
        let remouveFromParent = SKAction.removeFromParent()
        self.run(remouveFromParent)
    }
    
}
//
//  Arrows.swift
//  Vampire's Hunt
//
//  Created by Mattia Golino on 12/12/22.
//

import Foundation
