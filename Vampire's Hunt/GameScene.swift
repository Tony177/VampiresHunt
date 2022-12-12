//
//  GameScene.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 06/12/22.
//

import SpriteKit

class GameScene: SKScene {
    private let coinsAtlas : SKTextureAtlas = SKTextureAtlas(named: "coin")
    private let projectiles : [String] = ["Arrow1"]
    private let coins : [String] = ["normal","woman"]
    let player = Player()
    private var lives : Int = 3
    private var blood : Int = 0
    private var clock : TimeInterval = 0.0
    private var coinvalue : SKLabelNode?
    var dropSpeed: CGFloat = 1.0
    let minDropSpeed: CGFloat = 0.12
    let maxDropSpeed: CGFloat = 1.0
    var citizen = Citizen(citizenType: Citizen.CitizenType.citizen1)
    var typeOfCivil = ["citizen1", "citizen2", "virgin"]
    let background = SKSpriteNode(imageNamed: "Background")
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        background.name = "background"
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.background.rawValue
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
        addMenu()
        setClock()
        addPlayer()
        startSpawn()
    }
    
    
    private func startSpawn(){
        spawnProjectile()
        spawnMultipleCitizen()
    }
    private func spawnProjectile(){
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addProjectile),
                SKAction.wait(forDuration: 2.0,withRange: 3.5)
            ])
        ))
    }
    
    func spawnCitizen(citizenType: Citizen.CitizenType){
        citizen = Citizen(citizenType: citizenType)
        let margin = citizen.size.width * 2
        let spawnRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        let randomX = CGFloat.random(in: spawnRange.lowerLimit...spawnRange.upperLimit)
        citizen.position = CGPoint(x: randomX, y: size.height * 0.15)
        addChild(citizen)
        citizen.spawn(spawnTime: TimeInterval(2.0))
    }
    
    func spawnMultipleCitizen(){
        let wait = SKAction.wait(forDuration: TimeInterval(3.0), withRange: TimeInterval(3.0))
        let spawn = SKAction.run {
            let type = self.typeOfCivil.randomElement()
            if(type == "citizen1"){
                self.spawnCitizen(citizenType: Citizen.CitizenType.citizen1)
            }else if(type == "citizen2"){
                self.spawnCitizen(citizenType: Citizen.CitizenType.citizen2)
            }else{
                self.spawnCitizen(citizenType: Citizen.CitizenType.virgin)
            }
        }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: 20)
        run(repeatAction, withKey: "citizen")
    }

    private func setClock() {
        let clockLabel = SKLabelNode()
        let dateFormatter = DateComponentsFormatter()
        clockLabel.text = dateFormatter.string(from: self.clock)!
        clockLabel.fontSize = CGFloat(26)
        clockLabel.zPosition = Layer.ui.rawValue
        clockLabel.position = CGPoint(x: size.width/2, y: size.height*0.9)
        addChild(clockLabel)
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 1),
                SKAction.run {self.clock += 1
                    clockLabel.text = dateFormatter.string(from: self.clock)!
                }
            ])
        ))
    }
    
    private func addPlayer() {
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.05)
        addChild(player)
        player.walk()
    }
    
    private func addProjectile() {
        
        let projectile = SKSpriteNode(imageNamed: projectiles.randomElement()!)
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.arrow
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.player
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        let actualX = random(min: projectile.size.height/2, max: size.width - projectile.size.height/2)
        projectile.position = CGPoint(x: actualX, y: size.width + projectile.size.height)
        addChild(projectile)
        let actualDuration = CGFloat(4)//random(min: CGFloat(2.0), max: CGFloat(4.0))
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -projectile.size.height),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    private func addMenu(){
        let menu = SKShapeNode(rect: CGRect(x: 0, y: size.height*0.85, width: size.width, height: size.height*0.85))
        menu.strokeColor = .black
        menu.fillColor = .gray
        menu.zPosition = Layer.ui.rawValue
        addChild(menu)
        let hearts = [SKSpriteNode(imageNamed: "heart"),
                      SKSpriteNode(imageNamed: "heart"),
                      SKSpriteNode(imageNamed: "heart")]
        for i in hearts.indices{
            hearts[i].position = CGPoint(x: size.width - CGFloat(i*40+30), y: size.height * 0.90)
            hearts[i].name = "heart."+String(i)
            hearts[i].zPosition = Layer.ui.rawValue
            addChild(hearts[i])
        }
        
        let scoreicon = SKSpriteNode(imageNamed: "blood")
        scoreicon.position = CGPoint(x: size.width*0.05, y: size.height*0.85+scoreicon.size.height)
        scoreicon.zPosition = Layer.ui.rawValue
        addChild(scoreicon)
        let scorevalue = SKLabelNode()
        scorevalue.text = String(blood)
        scorevalue.fontSize = CGFloat(26)
        scorevalue.position = CGPoint(x: size.width*0.1, y: size.height*0.85+scorevalue.fontSize)
        scorevalue.zPosition = Layer.ui.rawValue
        scorevalue.name = "scorevalue"
        self.coinvalue = scorevalue
        addChild(scorevalue)
    }
    func coinDidCollideWithPlayer(coin: SKSpriteNode, player: SKSpriteNode){
        print("Coin")
        coin.removeFromParent()
        blood += 90
        self.coinvalue?.text = String(blood)
    }
    func projectileDidCollideWithPlayer(projectile: SKSpriteNode, player: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        if let child = childNode(withName: "heart."+String(lives-1)) {
            child.removeFromParent()
            let h = SKSpriteNode(imageNamed: "empty")
            h.position = CGPoint(x: size.width - CGFloat((lives-1)*40+30), y: size.height * 0.90)
            h.zPosition = Layer.ui.rawValue
            addChild(h)
            lives = lives - 1
        }
        if(lives == 0) {
            resetMatch()
            
        }
    }
    
    func resetMatch() {
        print("Dead")
        removeAllChildren()
        let leaderboard = decodeLeaderboard(userDefaultsKey: "score")
        let leaderboardChanged = leaderboard.copyAddRecord(record: Record(name: "Test", score: blood))
        encodeLeaderboard(userDefaultsKey: "score",leaderboard:leaderboardChanged)
        let reveal = SKTransition.reveal(with: .down,duration: 1)
        let newScene = EndScene()
        newScene.size = CGSize(width: 256, height: 256)
        newScene.scaleMode = .resizeFill
        
        scene?.view?.presentScene(newScene,transition: reveal)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let loc = touch.location(in: self)
            // Movement area check
            if (loc.x > size.width * 0.8 || loc.x < size.width * 0.2){
                player.removeAllActions()
                let dur : CGFloat = abs(loc.x-player.position.x)/300
                
                if (loc.x - player.position.x > 0) {
                    player.xScale = abs(player.xScale)
                    player.run(SKAction.moveTo(x:size.width*0.95 , duration: dur))
                } else {
                    player.xScale = abs(player.xScale) * -1
                    player.run(SKAction.moveTo(x:size.width*0.05, duration: dur))
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.removeAllActions()
        player.walk()
    }
}

extension GameScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Player - Projectile
        if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.arrow != 0)) {
            if let player = firstBody.node as? SKSpriteNode,
               let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithPlayer(projectile: projectile, player: player)
                return
            }
        }
        // Player - Coin
        if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.citizen != 0)) {
            if let player = firstBody.node as? SKSpriteNode,
               let coin = secondBody.node as? SKSpriteNode {
                coinDidCollideWithPlayer(coin: coin, player: player)
                return
            }
        }
    }
}
