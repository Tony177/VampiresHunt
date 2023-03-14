//
//  SpritekitHelper.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 12/12/22.
//

import Foundation
import SpriteKit
import SwiftUI

private let pC1 : [CGFloat] = [0.9, 0.85, 0.8, 0.7, 0.65, 0.6, 0.6, 0.55, 0.47, 0.44, 0.4]
private let pC2 : [CGFloat] = [0.1, 0.15, 0.2, 0.28, 0.32, 0.36, 0.35, 0.4, 0.47, 0.5, 0.53]
private let pC3 : [CGFloat] = [0.0, 0.0, 0.0, 0.02, 0.03, 0.04, 0.05, 0.05, 0.06, 0.06, 0.07]
private let pCW : [CGFloat] = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
private let ArC1 : [CGFloat] = [1.0, 0.95, 0.9, 0.85, 0.85, 0.8, 0.8, 0.75, 0.7, 0.65, 0.55]
private let ArC2 : [CGFloat] = [0.0, 0.05, 0.1, 0.15, 0.15, 0.15, 0.15, 0.2, 0.2, 0.2, 0.25]
private let ArC3 : [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.05, 0.05, 0.05, 0.1, 0.15, 0.2]

public var audioSFX : Float = UserDefaults.standard.object(forKey: "audioSFX") as? Float ?? 1.0
public var audioMusic : Float = UserDefaults.standard.object(forKey: "audioMusic") as? Float ?? 1.0

enum Layer: CGFloat{
    case background
    case player
    case arrow
    case citizen
    case collectible
    case ui
    case backgroundPause
    case buttonPause
}

enum PhysicsCategory {
    static let none: UInt32 = UInt32(0)
    static let player: UInt32 = UInt32(1)
    static let arrow: UInt32 = UInt32(2)
    static let citizen: UInt32 = UInt32(4)
}
extension Color {
    static let customRed = Color("customRed")
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

func setupPhysics<T:SKSpriteNode>(node: inout T, categoryBitMask : UInt32, contactTestBitMask : UInt32,collisionBitMask: UInt32 = UInt32(0),xCenter : CGFloat = 0.0,yCenter : CGFloat = 0.0,affectedByGravity : Bool = false, isDynamic: Bool = true ) -> Void
{
    node.physicsBody = SKPhysicsBody(rectangleOf: node.size, center: CGPoint(x: xCenter, y: yCenter))
    node.physicsBody?.affectedByGravity = affectedByGravity
    node.physicsBody?.isDynamic = isDynamic
    node.physicsBody?.categoryBitMask = categoryBitMask
    node.physicsBody?.contactTestBitMask = contactTestBitMask
    node.physicsBody?.collisionBitMask = collisionBitMask
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return CGFloat.random(in: 0...1)  * (max - min) + min
    
}

func weightedRandomCitizen(phase : Int) -> Citizen.CitizenType{
    var idx : Int = phase
    if (phase > pC1.count) {
        idx = pC1.endIndex-1
    }
    let random : CGFloat = CGFloat.random(in: 0...1)
    switch random {
    case 0..<pC1[idx]:
        return Citizen.CitizenType.citizen1
    case pC1[idx]..<pC1[idx]+pC2[idx]:
        return Citizen.CitizenType.citizen2
    default:
        return Citizen.CitizenType.virgin
    }
}

func weightedRandomWolf(phase : Int) -> Citizen.CitizenType{
    var idx : Int = phase
    if (phase > pC1.count) {
        idx = pC1.endIndex-1
    }
    let random : CGFloat = CGFloat.random(in: 0...1)
    switch random {
    case 0..<pC1[idx]:
        return Citizen.CitizenType.citizen1
    case pC1[idx]..<pC1[idx]+pC2[idx]:
        return Citizen.CitizenType.citizen2
    default:
        return Citizen.CitizenType.virgin
    }
}


func weightedRandomProjectile(phase: Int) -> Projectile.ProjectileType{
    var idx : Int = phase
    if (phase > pC1.count) {
        idx = pC1.endIndex-1
    }
    let random : CGFloat = CGFloat.random(in: 0...1)
    switch random {
    case 0..<ArC1[idx]:
        return Projectile.ProjectileType.arrow
    case ArC1[idx]..<ArC1[idx]+ArC2[idx]:
        return Projectile.ProjectileType.cross
    default:
        return Projectile.ProjectileType.holywater
    }
}
