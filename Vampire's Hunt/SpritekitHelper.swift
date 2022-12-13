//
//  SpritekitHelper.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 12/12/22.
//

import Foundation
import SpriteKit

enum Layer: CGFloat{
    case background
    case player
    case arrow
    case citizen
    case ui
}

enum PhysicsCategory {
    static let none: UInt32 = UInt32(0)
    static let player: UInt32 = UInt32(1)
    static let arrow: UInt32 = UInt32(2)
    static let citizen: UInt32 = UInt32(4)
}

extension SKSpriteNode{
    
    func loadTexture(atlas: String, prefix: String, startsAt: Int, stopAt: Int) -> [SKTexture]{
        var textureArray = [SKTexture]()
        let textureAtlas = SKTextureAtlas(named: atlas)
        for i in startsAt...stopAt {
            let textureName = "\(prefix)\(i)"
            let temp = textureAtlas.textureNamed(textureName)
            textureArray.append(temp)
        }
        return textureArray
    }
    
    func startAnimation(texture: [SKTexture], speed: Double, name: String, count: Int, resize: Bool, restore: Bool){
        if(action(forKey: name) == nil){
            let animation = SKAction.animate(with: texture, timePerFrame: speed, resize: resize, restore: restore)
            if(count == 0){
                let repeatAction = SKAction.repeatForever(animation)
                run(repeatAction, withKey: name)
            }else if(count == 1){
                run(animation, withKey: name)
            }else{
                let repeatAction = SKAction.repeat(animation, count: count)
                run(repeatAction, withKey: name)
            }
        }
    }
    
}
func setupPhysics<T:SKSpriteNode>(node: inout T, categoryBitMask : UInt32, contactTestBitMask : UInt32,collisionBitMask: UInt32 = UInt32(0),affectedByGravity : Bool = false, isDynamic: Bool = true ) -> Void
{
    node.physicsBody = SKPhysicsBody(rectangleOf: node.size, center: CGPoint(x: 0.0, y: node.size.height / 2))
    node.physicsBody?.affectedByGravity = false
    node.physicsBody?.isDynamic = true
    node.physicsBody?.categoryBitMask = categoryBitMask
    node.physicsBody?.contactTestBitMask = contactTestBitMask
    node.physicsBody?.collisionBitMask = collisionBitMask
}
func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat.random(in: 0...1)  * (max - min) + min
}
