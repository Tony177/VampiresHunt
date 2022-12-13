//
//  Citizen.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 12/12/22.
//

import Foundation
import SpriteKit

class Citizen: SKSpriteNode {
    
    private var citizenType: CitizenType = .none
    private var walkTextures1: [SKTexture]?
    private var walkTextures2: [SKTexture]?
    private var walkTextures3: [SKTexture]?
    
    enum CitizenType: String {
        case none
        case citizen1
        case citizen2
        case virgin
    }
    
    enum CitizenAnimationType: String{
        case walk
    }
    
    init(citizenType: CitizenType){
        var texture: SKTexture!
        self.citizenType = citizenType
        switch self.citizenType{
        case .citizen1:
            texture = SKTexture(imageNamed: "Citizen1-frame1")
        case .citizen2:
            texture = SKTexture(imageNamed: "Citizen2-frame1")
        case .virgin:
            texture = SKTexture(imageNamed: "Virgin-frame1")
        case .none:
            break
        }
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        if(self.citizenType == .citizen1){
            self.walkTextures1 = self.loadTexture(atlas: "Citizen", prefix: "Citizen1-frame", startsAt: 1, stopAt: 4)
            startAnimation(texture: walkTextures1!, speed: 0.25, name: CitizenAnimationType.walk.rawValue, count: 0, resize: true, restore: true)
        }else if(self.citizenType == .citizen2){
            self.walkTextures2 = self.loadTexture(atlas: "Citizen", prefix: "Citizen2-frame", startsAt: 1, stopAt: 4)
            startAnimation(texture: walkTextures2!, speed: 0.25, name: CitizenAnimationType.walk.rawValue, count: 0, resize: true, restore: true)
        }else{
            self.walkTextures3 = self.loadTexture(atlas: "Citizen", prefix: "Virgin-frame", startsAt: 1, stopAt: 4)
            startAnimation(texture: walkTextures3!, speed: 0.25, name: CitizenAnimationType.walk.rawValue, count: 0, resize: true, restore: true)
        }
        self.name = "city_\(citizenType)"
        self.zPosition = Layer.citizen.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawn(spawnTime: TimeInterval){
        let scaleX = SKAction.scaleX(to: 1.0, duration: 1.0)
        let scaleY = SKAction.scaleY(to: 1.3, duration: 1.0)
        let scale = SKAction.group([scaleX, scaleY])
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.25)
        let actionSequence = SKAction.sequence([appear, scale])
        self.scale(to: CGSize(width: 0.25, height: 1.0))
        self.run(actionSequence, withKey: "spawn")
    }    
}
