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
    private let musicAudioNode = SKAudioNode(fileNamed: "backgroundMusic.mp3")
    private var player = Player()
    private var stage : Int = 1
    private var lives : Int = 3
    private var blood : Int = 0
    private var clock : TimeInterval = 0.0
    private var coinvalue : SKLabelNode?
    private var citizen = Citizen(citizenType: Citizen.CitizenType.citizen1)
    private var dropSpeed : CGFloat = 0.0
    private var scalingFactor : CGFloat = 0.75
    
    
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
        changeBackground()
        addMenu()
        setClock()
        addPlayer()
        startSpawn()
        changeLevel()
    }
    private func changeBackground(){
        let background = SKSpriteNode(imageNamed: "background\(stage)")
        background.name = "background"
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = Layer.background.rawValue
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
    }
    private func changeLevel(){
        if(stage < 11){ // Last stage
            //MARK: remove spawned citizen
            run(SKAction.sequence([
                SKAction.wait(forDuration: 10),
                SKAction.run {
                    self.removeAllActions()
                    self.removeChildren(in: [self.childNode(withName: "background")!])
                    self.removeChildren(in: [self.childNode(withName: "clock")!])
                },
                SKAction.run {
                    self.startSpawn()
                    self.changeDiff()
                    self.setClock()
                },
                SKAction.run {
                    self.changeLevel()
                }
            ]))
        }
        
    }
    
    private func startSpawn(){
        spawnMultipleProjectile()
        spawnMultipleCitizen()
    }
    
    func spawnMultipleProjectile(){
        let wait = SKAction.wait(forDuration: 1.0 * scalingFactor , withRange: 1.5 * scalingFactor)
        let spawn = SKAction.run {
            self.spawnProjectile()
        }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: 10000)
        run(repeatAction, withKey: "projectile")
    }
    
    func spawnCitizen(citizenType: Citizen.CitizenType){
        citizen = Citizen(citizenType: citizenType)
        setupPhysics(node: &citizen, categoryBitMask: PhysicsCategory.citizen, contactTestBitMask: PhysicsCategory.player)
        let margin = citizen.size.width * 2
        let randomX = [random(min: frame.maxX + margin, max: player.position.x - 100),random(min: player.position.x + 100, max: frame.maxX - margin)].randomElement()!
        citizen.position = CGPoint(x: randomX, y: size.height * 0.15)
        addChild(citizen)
        citizen.spawn(spawnTime: TimeInterval(1.75))
    }
    
    func spawnMultipleCitizen(){
        let wait = SKAction.wait(forDuration: TimeInterval(2.0), withRange: TimeInterval(1.5))
        let spawn = SKAction.run {
            let type = weightedRandomCitizen(phase: self.stage)
            self.spawnCitizen(citizenType: type)
        }
        let sequence = SKAction.sequence([wait, spawn, wait, SKAction.run(removeFromParent)])
        let repeatAction = SKAction.repeat(sequence, count: 10000)
        run(repeatAction, withKey: "citizen")
    }
    
    private func setClock() {
        let clockLabel = SKLabelNode()
        let dateFormatter = DateComponentsFormatter()
        clockLabel.name = "clock"
        clockLabel.attributedText = NSAttributedString(string: dateFormatter.string(from: self.clock)!, attributes: [.font: UIFont(name: "CasaleTwo NBP", size: 26)!])
        clockLabel.zPosition = Layer.ui.rawValue
        clockLabel.position = CGPoint(x: size.width/2, y: size.height*0.9)
        addChild(clockLabel)
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 1),
                SKAction.run {self.clock += 1
                    clockLabel.attributedText = NSAttributedString(string: dateFormatter.string(from: self.clock)!, attributes: [.font: UIFont(name: "CasaleTwo NBP", size: 26)!])
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
    
    private func spawnProjectile() {
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
        menu.fillColor = UIColor(.gray).withAlphaComponent(0.2)
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
        scorevalue.attributedText = NSAttributedString(string: String(blood), attributes: [.font: UIFont(name: "CasaleTwo NBP", size: 26)!])
        scorevalue.position = CGPoint(x: size.width*0.1, y: size.height*0.85+scorevalue.fontSize)
        scorevalue.zPosition = Layer.ui.rawValue
        scorevalue.name = "scorevalue"
        self.coinvalue = scorevalue
        addChild(scorevalue)
    }
    func citizenDidCollideWithPlayer(citizen: Citizen){
        print("Point")
        let bitesTexture : [SKTexture] = player.loadTexture(atlas: "Vampire", prefix: "VampireBite", startsAt: 1, stopAt: 3)
        player.startAnimation(texture: bitesTexture, speed: 0.15, name: "bite", count: 1, resize: true, restore: true)
        blood += citizen.getCoinValue()
        citizen.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3),SKAction.run(removeFromParent)]))
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
    private func changeDiff(){
        self.stage += 1
        self.scalingFactor = pow(0.8, CGFloat(self.stage))
        self.dropSpeed = ((0.05 * baseSpeed * CGFloat(self.stage))).rounded()
        changeBackground()
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
                let arrowAudioNode = SKAction.playSoundFileNamed("Hitby_falling_object.mp3", waitForCompletion: false)
                run(arrowAudioNode)
                return
            }
        }
        // Player - Citizen
        if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.citizen != 0)) {
            if let citizen = secondBody.node as? Citizen {
                citizenDidCollideWithPlayer(citizen: citizen)
                let bitAudioNode = SKAction.playSoundFileNamed("BiteBloodPickup.mp3", waitForCompletion: false)
                run(bitAudioNode)
                return
            }
        }
    }
}
