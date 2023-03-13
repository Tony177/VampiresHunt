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
    private let baseSpeed : CGFloat = 300
    private let musicAudioNode = SKAudioNode(fileNamed: "backgroundMusic")
    private let biteAudioNode = SKAudioNode(fileNamed: "biteBloodPickup")
    private let hitAudioNode = SKAudioNode(fileNamed: "hitFallingObject")
    private var hashFirstTouch : Int = 0
    private var player = Player()
    private var stage : Int = 1
    private var lives : Int = 3
    private var blood : Int = 0
    private var clock : TimeInterval = 0.0
    private var coinvalue : SKLabelNode?
    private var citizen = Citizen(citizenType: Citizen.CitizenType.citizen1)
    private var collectible = Collectible(collectiblesType: Collectible.CollectibleType.wolf)
    private var dropSpeed : CGFloat = 0.0
    private var scalingFactor : CGFloat = 0.75
    private var debuffSpeed : CGFloat = 1.0
    private var textField: UITextField!
    private var playerNameIns: UITextField!
    
    
    override func didMove(to view: SKView) {
        self.view?.isMultipleTouchEnabled = true
        self.view?.isExclusiveTouch = true
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        setupAudio()
        changeBackground()
        addMenu()
        setClock()
        addPlayer()
        startSpawn()
        changeLevel()
        
    }
    private func setupAudio(){
        audioEngine.mainMixerNode.outputVolume = 0.0
        biteAudioNode.autoplayLooped = false
        hitAudioNode.autoplayLooped = false
        addChild(musicAudioNode)
        addChild(biteAudioNode)
        addChild(hitAudioNode)
        biteAudioNode.run(SKAction.changeVolume(to: audioSFX, duration: 0.1))
        hitAudioNode.run(SKAction.changeVolume(to: audioSFX, duration: 0.1))
        musicAudioNode.run(SKAction.changeVolume(to: 0.0, duration: 0.0))
        run(SKAction.wait(forDuration: 1.0)) {
            [unowned self] in self.audioEngine.mainMixerNode.outputVolume = 1.0
            self.musicAudioNode.run(SKAction.changeVolume(to: audioMusic, duration: 2.0))
        }
    }
    private func changeBackground(){
        let background = SKSpriteNode(imageNamed: "background\(stage)")
        background.name = "background"
        background.zPosition = Layer.background.rawValue
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        addChild(background)
    }
    private func changeLevel(){
        if(stage < 11){ // Last stage
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
        spawnMultipleWolf()
    }
    
    private func spawnProjectile() {
        let projectile = Projectile(projectileType: weightedRandomProjectile(phase: stage-1))
        let actualX = random(min: size.width * 0.05, max: size.width * 0.95)
        projectile.position = CGPoint(x: actualX, y: size.height + projectile.size.height)
        projectile.physicsBody = SKPhysicsBody(texture: projectile.texture!, size: projectile.size)
        projectile.physicsBody?.affectedByGravity = false
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.arrow
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.player
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        projectile.physicsBody?.velocity = CGVector(dx: 0, dy: -350 - dropSpeed)
        addChild(projectile)
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
    
    func spawnWolf(citizenType: Citizen.CitizenType){
        citizen = Citizen(citizenType: citizenType)
        setupPhysics(node: &citizen, categoryBitMask: PhysicsCategory.citizen, contactTestBitMask: PhysicsCategory.player)
        let randomX = random(min: size.width*0.05, max: size.width*0.95)
        citizen.position = CGPoint(x: randomX, y: size.height * 0.15)
        addChild(citizen)
        citizen.spawn(spawnTime: TimeInterval(0.75))
        citizen.run(SKAction.sequence([SKAction.wait(forDuration: 3.5),SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
    }
    
    func spawnMultipleWolf(){
        let wait = SKAction.wait(forDuration: TimeInterval(10), withRange: TimeInterval(2))
        let spawn = SKAction.run {
            self.spawnCitizen(citizenType: Citizen.CitizenType.wolf)
        }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: 10000)
        run(repeatAction, withKey: "wolf")
    }
    
    func spawnCitizen(citizenType: Citizen.CitizenType){
        citizen = Citizen(citizenType: citizenType)
        setupPhysics(node: &citizen, categoryBitMask: PhysicsCategory.citizen, contactTestBitMask: PhysicsCategory.player)
        let randomX = random(min: size.width*0.05, max: size.width*0.95)
        citizen.position = CGPoint(x: randomX, y: size.height * 0.15)
        addChild(citizen)
        citizen.spawn(spawnTime: TimeInterval(0.75))
        citizen.run(SKAction.sequence([SKAction.wait(forDuration: 2.5),SKAction.fadeOut(withDuration: 0.3), SKAction.removeFromParent()]))
    }
    
    func spawnMultipleCitizen(){
        let wait = SKAction.wait(forDuration: TimeInterval(1), withRange: TimeInterval(0.25))
        let spawn = SKAction.run {
            let type = weightedRandomCitizen(phase: self.stage-1)
            self.spawnCitizen(citizenType: type)
        }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: 10000)
        run(repeatAction, withKey: "citizen")
    }
    
    private func setClock() {
        let clockLabel = SKLabelNode()
        let dateFormatter = DateComponentsFormatter()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(.red), .font: UIFont(name: "CasaleTwo NBP", size: 26)!]
        clockLabel.name = "clock"
        clockLabel.attributedText = NSAttributedString(string: dateFormatter.string(from: self.clock)!, attributes: attributes)
        clockLabel.zPosition = Layer.ui.rawValue
        clockLabel.position = CGPoint(x: size.width*0.1, y: size.height*0.9)
        addChild(clockLabel)
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: 1),
                SKAction.run {self.clock += 1
                    clockLabel.attributedText = NSAttributedString(string: dateFormatter.string(from: self.clock)!, attributes: attributes)
                }
            ])
        ))
    }
    private func addPlayer() {
        setupPhysics(node: &player, categoryBitMask: PhysicsCategory.player, contactTestBitMask: PhysicsCategory.arrow)
        player.constraints = [SKConstraint.distance(SKRange(lowerLimit: -size.width*0.45,upperLimit: size.width*0.45), to: CGPoint(x: size.width/2, y: size.height*0.15))]
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width*0.9, height: player.size.height*0.9),center: CGPoint(x: 0.0, y: -5))
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.arrow
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(player)
        player.walk()
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
            hearts[i].position = CGPoint(x: size.width - CGFloat((i+1)*40+160), y: size.height * 0.92)
            hearts[i].name = "heart."+String(i+1)
            hearts[i].zPosition = Layer.ui.rawValue
            addChild(hearts[i])
        }
        
        let scoreicon = SKSpriteNode(imageNamed: "blood")
        scoreicon.position = CGPoint(x: size.width*0.35, y: size.height*0.84+scoreicon.size.height)
        scoreicon.zPosition = Layer.ui.rawValue
        addChild(scoreicon)
        let scorevalue = SKLabelNode()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(.red), .font: UIFont(name: "CasaleTwo NBP", size: 26)!]
        scorevalue.attributedText = NSAttributedString(string: String(blood), attributes: attributes)
        scorevalue.position = CGPoint(x: size.width*0.40, y: size.height*0.81+scorevalue.fontSize)
        scorevalue.zPosition = Layer.ui.rawValue
        scorevalue.name = "scorevalue"
        self.coinvalue = scorevalue
        addChild(scorevalue)
        let pauseButton = SKSpriteNode(imageNamed: "blood")
        pauseButton.name = "pauseButton"
        pauseButton.position = CGPoint(x: size.width*0.9, y: size.height*0.85+pauseButton.size.height)
        pauseButton.zPosition = Layer.ui.rawValue
        addChild(pauseButton)
    }
    func citizenDidCollideWithPlayer(citizen: Citizen, player: Player){
        if(lives == 0){
            return
        }
        if (citizen.getType() == .virgin) {
            if let child = childNode(withName: "empty."+String(lives+1)) {
                child.removeFromParent()
                lives += 1
                let h = SKSpriteNode(imageNamed: "heart")
                h.name = "heart."+String(lives)
                h.position = CGPoint(x: size.width - CGFloat((lives)*40+160), y: size.height * 0.92)
                h.zPosition = Layer.ui.rawValue
                addChild(h)
            }
        }
        if(citizen.getType() == Citizen.CitizenType.wolf){
            run(SKAction.sequence([
                SKAction.run({
                    self.debuffSpeed = 1.3
                    player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)! * self.debuffSpeed, dy: 0)
                }),
                SKAction.wait(forDuration: 3),
                SKAction.run({self.debuffSpeed = 1.0
                    if( (player.physicsBody?.velocity.dx)! == 0.0){
                        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    } else {
                        player.physicsBody?.velocity = CGVector(dx: self.baseSpeed * player.xScale, dy: 0)
                    }
                    
                })
            ]))
        }
        let bitesTexture : [SKTexture] = player.loadTexture(atlas: "Vampire", prefix: "VampireBite", startsAt: 1, stopAt: 3)
        player.startAnimation(texture: bitesTexture, speed: 0.15, name: "bite", count: 1, resize: true, restore: true)
        blood += citizen.getCoinValue()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(.red), .font: UIFont(name: "CasaleTwo NBP", size: 26)!]
        citizen.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3),SKAction.run(citizen.removeFromParent)]))
        self.coinvalue?.attributedText = NSAttributedString(string: String(blood), attributes: attributes)
        self.coinvalue?.position = CGPoint(x: size.width*0.40 + log10(CGFloat(blood+1))*4, y: size.height*0.81+self.coinvalue!.fontSize)
        
    }
    
    func projectileDidCollideWithPlayer(projectile: Projectile, player: Player) {
        if(projectile.getType() == Projectile.ProjectileType.cross){
            run(SKAction.sequence([
                SKAction.run({
                    self.debuffSpeed = 0.7
                    player.physicsBody?.velocity = CGVector(dx: (player.physicsBody?.velocity.dx)! * self.debuffSpeed, dy: 0)
                }),
                SKAction.wait(forDuration: 3),
                SKAction.run({self.debuffSpeed = 1.0
                    if( (player.physicsBody?.velocity.dx)! == 0.0){
                        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    } else {
                        player.physicsBody?.velocity = CGVector(dx: self.baseSpeed * player.xScale, dy: 0)
                    }
                    
                })
            ]))
        }
        if(projectile.getType() == Projectile.ProjectileType.holywater){
            run(SKAction.sequence([
                SKAction.run({self.debuffSpeed = 0.0
                    player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)}),
                SKAction.wait(forDuration: 1),
                SKAction.run({self.debuffSpeed = 1.0})
            ]))
        }
        projectile.removeFromParent()
        if let child = childNode(withName: "heart."+String(lives)) {
            child.removeFromParent()
            let h = SKSpriteNode(imageNamed: "empty")
            h.name = "empty."+String(lives)
            h.position = CGPoint(x: size.width - CGFloat((lives)*40+160), y: size.height * 0.92)
            h.zPosition = Layer.ui.rawValue
            addChild(h)
            lives -= 1
        }
        if(lives == 0) {
            let deathTexture : [SKTexture] = player.loadTexture(atlas: "Vampire", prefix: "VampireDying", startsAt: 1, stopAt: 12)
            player.startAnimation(texture: deathTexture, speed: 0.15, name: "die", count: 1, resize: true, restore: true)
            player.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
            self.removeAllActions()
            self.removeAllChildren()
            resetMatch()
        }
    }
    
    func resetMatch() {
        removeAllChildren()
        GKLeaderboard.submitScore(blood, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["com.nanashi.vhpoint"]) { error in
            if let error { print(error.localizedDescription) }
        }
        GKLeaderboard.submitScore(Int(clock.rounded(.down)), context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["com.nanashi.vhtime"]){ error in
            if let error { print(error.localizedDescription) }
        }
        let reveal = SKTransition.reveal(with: .down,duration: 1)
        let newScene = GameScene()
        newScene.size = CGSize(width: 256, height: 256)
        newScene.scaleMode = .resizeFill
        scene?.view?.presentScene(newScene,transition: reveal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(lives != 0 ) {
            for touch in touches{
                let loc = touch.location(in: self)
                if(atPoint(loc).name == "pauseButton"){
                    self.view?.presentScene(PauseScene())
                    return
                }
                hashFirstTouch = touch.hashValue
                
                // Movement area check
                if (loc.x > size.width * 0.5) {
                    player.xScale = abs(player.xScale)
                    player.physicsBody?.velocity = CGVector(dx: baseSpeed * debuffSpeed, dy: 0)
                } else {
                    player.xScale = abs(player.xScale) * -1
                    player.physicsBody?.velocity = CGVector(dx: -baseSpeed * debuffSpeed, dy: 0)
                }
           }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if(touch.hashValue == hashFirstTouch){
                player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
        }
        
    }
    
    private func changeDiff(){
        self.stage += 1
        self.scalingFactor = pow(0.89, CGFloat(self.stage))
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
               let projectile = secondBody.node as? Projectile {
                hitAudioNode.run(SKAction.play())
                projectileDidCollideWithPlayer(projectile: projectile, player: player)
                return
            }
        }
        // Player - Citizen
        if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.citizen != 0)) {
            if let citizen = secondBody.node as? Citizen {
                let player = firstBody.node as? Player
                biteAudioNode.run(SKAction.play())
                citizenDidCollideWithPlayer(citizen: citizen, player: player!)
                return
            }
        }
    }
}
