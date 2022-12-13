//
//  Arrows.swift
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
