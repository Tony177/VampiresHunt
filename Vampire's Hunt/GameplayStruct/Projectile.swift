//
//  Projectile.swift
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
    
    init(projectileType: ProjectileType) {
        var texture: SKTexture!
        self.projectileType = projectileType
        if (self.projectileType != .none) {
            texture = SKTexture(imageNamed: self.projectileType.rawValue)
        }
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.zPosition = Layer.arrow.rawValue
    }
    
    func getType() -> ProjectileType{
        return self.projectileType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
