//
//  GameScene.swift
//  Vampire's Hunt
//
//  Created by Nanashi on 06/12/22.
//

import SpriteKit
import AVFoundation
import GameKit

class GameScene: SKScene {
    private let baseSpeed : CGFloat = -350
    private let background = SKSpriteNode(imageNamed: "Background")
    private let musicAudioNode = SKAudioNode(fileNamed: "backgroundMusic.mp3")
    private var player = Player()
    private var lives : Int = 3
    private var blood : Int = 0
    private var clock : TimeInterval = 60.0
    private var coinvalue : SKLabelNode?
    private var citizen = Citizen(citizenType: Citizen.CitizenType.citizen1)
    private var typeOfCivil = ["citizen1", "citizen2", "virgin"]
    
    var dropSpeed : CGFloat {
        // divided by 10 for unit every 10s
        // divided by 100 to get 0.01 decimal point
        // multiplied by 5 to decrese faster
        return  ((0.005 * baseSpeed * clock)).rounded()
    }
    
    override func didMove(to view: SKView) {
        audioEngine.mainMixerNode.outputVolume = 0.0
        musicAudioNode.autoplayLooped = true
        musicAudioNode.isPositional = false
        addChild(musicAudioNode)
        musicAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
        run(SKAction.wait(forDuration: 1.0)) {
            [unowned self] in self.audioEngine.mainMixerNode.outputVolume = 1.0
            self.musicAudioNode.run(SKAction.changeVolume(to: 0.75, duration: 2.0))
        }
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
        // MARK: Not updating scalingFactor beacuse of one time call
        let scalingFactor = pow(0.75, clock/10.0)
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addProjectile),
                SKAction.wait(forDuration: 2.0 * scalingFactor,withRange: 3.5 * scalingFactor)
            ])
        ))
    }
    
    
    func spawnCitizen(citizenType: Citizen.CitizenType){
        citizen = Citizen(citizenType: citizenType)
        setupPhysics(node: &citizen, categoryBitMask: PhysicsCategory.citizen, contactTestBitMask: PhysicsCategory.player)
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
            let type = weightedRandomCitizen(phase: Int(self.clock/10))
            self.spawnCitizen(citizenType: type)
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
        setupPhysics(node: &player, categoryBitMask: PhysicsCategory.player, contactTestBitMask: PhysicsCategory.arrow)
        player.constraints = [SKConstraint.distance(SKRange(lowerLimit: -size.width*0.45,upperLimit: size.width*0.45), to: CGPoint(x: size.width/2, y: size.height*0.05))]
        addChild(player)
        player.walk()
    }
    
    private func addProjectile() {
        var projectile = Arrow(arrowType: Arrow.ArrowType.arrow)
        let actualX = random(min: size.width * 0.05, max: size.width * 0.95)
        setupPhysics(node: &projectile, categoryBitMask: PhysicsCategory.arrow, contactTestBitMask: PhysicsCategory.player)
        projectile.position = CGPoint(x: actualX, y: size.height + projectile.size.height)
        projectile.physicsBody?.velocity = CGVector(dx: 0, dy: -350 + dropSpeed)
        addChild(projectile)
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
    func citizenDidCollideWithPlayer(citizen: Citizen){
        print("Point")
        blood += citizen.getCoinValue()
        citizen.removeFromParent()
        self.coinvalue?.text = String(blood)
    }
    func projectileDidCollideWithPlayer(projectile: Arrow, player: Player) {
        print("Hit")
        projectile.removeFromParent()
        if let child = childNode(withName: "heart."+String(lives-1)) {
            child.removeFromParent()
            let h = SKSpriteNode(imageNamed: "empty")
            h.position = CGPoint(x: size.width - CGFloat((lives-1)*40+30), y: size.height * 0.90)
            h.zPosition = Layer.ui.rawValue
            addChild(h)
            lives -= 1
        }
        if(lives == 0) {
            resetMatch()
        }
    }
    
    func resetMatch() {
        print("Dead")
        removeAllChildren()
        let leaderboard = decodeLeaderboard(userDefaultsKey: "score")
        let leaderboardChanged = leaderboard.copyAddRecord(record: Record(name: "You", score: blood))
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
            if (loc.x > size.width * 0.8 || loc.x < size.width * 0.2 ){
                if (loc.x - player.position.x > 0) {
                    player.xScale = abs(player.xScale)
                    player.physicsBody?.velocity = CGVector(dx: 300, dy: 0)
                } else {
                    player.xScale = abs(player.xScale) * -1
                    player.physicsBody?.velocity = CGVector(dx: -300, dy: 0)
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
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
            if let player = firstBody.node as? Player,
               let projectile = secondBody.node as? Arrow {
                projectileDidCollideWithPlayer(projectile: projectile, player: player)
                return
            }
        }
        // Player - Citizen
        if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.citizen != 0)) {
            if let citizen = secondBody.node as? Citizen {
                citizenDidCollideWithPlayer(citizen: citizen)
                return
            }
        }
    }
}
