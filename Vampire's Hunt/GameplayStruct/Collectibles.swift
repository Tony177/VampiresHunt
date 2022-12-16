//
//  Collectibles.swift
//  Vampire's Hunt
//
//  Created by Mattia Golino on 16/12/22.
//

import Foundation
import SpriteKit

class Collectible: SKSpriteNode{
    
    private var collectiblesType: CollectibleType = CollectibleType.none
    
    enum CollectibleType: String{
        case none
        case wolf
        case mist
    }
    
    init(collectiblesType: CollectibleType) {
        var texture: SKTexture!
        self.collectiblesType = collectiblesType
        if (self.collectiblesType != .none) {
            texture = SKTexture(imageNamed: self.collectiblesType.rawValue)
        }
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.zPosition = Layer.collectible.rawValue
    }
    
    func getType() -> CollectibleType{
        return self.collectiblesType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
