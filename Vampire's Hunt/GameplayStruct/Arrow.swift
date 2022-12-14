//
//  Arrows.swift
//  Vampire's Hunt
//
//  Created by Nanshi on 12/12/22.
//

import Foundation
import SpriteKit

class Projectile: SKSpriteNode{
    
    private var projectileType: ProjectileType = .none
    
    enum ProjectileType: String{
        case none
        case arrow
        case cross
        case holywater
    }
    func getArrow() -> ProjectileType{
        return self.projectileType
    }
    init(projectileType: ProjectileType) {
        var texture: SKTexture!
        self.projectileType = projectileType
        if (self.projectileType != .none) {
            texture = SKTexture(imageNamed: self.projectileType.rawValue)
        }
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.zPosition = Layer.arrow.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
