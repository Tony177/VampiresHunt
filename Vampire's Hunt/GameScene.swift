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
    private var debuffSpeed : CGFloat = 1.0
    private var textField: UITextField!
    private var playerNameIns: UITextField!
    
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
        
        let randomX = random(min: size.width*0.05, max: size.width*0.95)
        citizen.position = CGPoint(x: randomX, y: size.height * 0.15)
        addChild(citizen)
        citizen.spawn(spawnTime: TimeInterval(1))
    }
    
    func spawnMultipleCitizen(){
        let wait = SKAction.wait(forDuration: TimeInterval(1), withRange: TimeInterval(0.25))
        let spawn = SKAction.run {
            let type = weightedRandomCitizen(phase: self.stage)
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
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.05)
        setupPhysics(node: &player, categoryBitMask: PhysicsCategory.player, contactTestBitMask: PhysicsCategory.arrow)
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: player.size.width, height: player.size.height * 0.8), center: CGPoint(x: 0.0, y: player.size.height * 0.7))
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.arrow
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.constraints = [SKConstraint.distance(SKRange(lowerLimit: -size.width*0.45,upperLimit: size.width*0.45), to: CGPoint(x: size.width/2, y: size.height*0.05))]
        addChild(player)
        player.walk()
    }
    
    private func spawnProjectile() {
        var projectile = Projectile(projectileType: weightedRandomProjectile(phase: stage))
        let actualX = random(min: size.width * 0.05, max: size.width * 0.95)
        setupPhysics(node: &projectile, categoryBitMask: PhysicsCategory.arrow, contactTestBitMask: PhysicsCategory.player,yCenter: -20.0 - ((projectile.getType() == .holywater) ? 10 : 0))
        projectile.position = CGPoint(x: actualX, y: size.height + projectile.size.height)
        projectile.physicsBody?.usesPreciseCollisionDetection = true
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
            hearts[i].position = CGPoint(x: size.width - CGFloat((i+1)*40+30), y: size.height * 0.90)
            hearts[i].name = "heart."+String(i+1)
            hearts[i].zPosition = Layer.ui.rawValue
            addChild(hearts[i])
        }
        
        let scoreicon = SKSpriteNode(imageNamed: "blood")
        scoreicon.position = CGPoint(x: size.width*0.45, y: size.height*0.84+scoreicon.size.height)
        scoreicon.zPosition = Layer.ui.rawValue
        addChild(scoreicon)
        let scorevalue = SKLabelNode()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(.red), .font: UIFont(name: "CasaleTwo NBP", size: 26)!]
        scorevalue.attributedText = NSAttributedString(string: String(blood), attributes: attributes)
        scorevalue.position = CGPoint(x: size.width*0.5, y: size.height*0.81+scorevalue.fontSize)
        scorevalue.zPosition = Layer.ui.rawValue
        scorevalue.name = "scorevalue"
        self.coinvalue = scorevalue
        addChild(scorevalue)
    }
    func citizenDidCollideWithPlayer(citizen: Citizen){
        print("Point")
        if (citizen.getType() == .virgin) {
            if let child = childNode(withName: "empty."+String(lives+1)) {
                child.removeFromParent()
                lives += 1
                let h = SKSpriteNode(imageNamed: "heart")
                h.name = "heart."+String(lives)
                h.position = CGPoint(x: size.width - CGFloat((lives)*40+30), y: size.height * 0.90)
                h.zPosition = Layer.ui.rawValue
                addChild(h)
            }
        }
        let bitesTexture : [SKTexture] = player.loadTexture(atlas: "Vampire", prefix: "VampireBite", startsAt: 1, stopAt: 3)
        player.startAnimation(texture: bitesTexture, speed: 0.15, name: "bite", count: 1, resize: true, restore: true)
        blood += citizen.getCoinValue()
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(.red), .font: UIFont(name: "CasaleTwo NBP", size: 26)!]
        citizen.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.3),SKAction.run(citizen.removeFromParent)]))
        self.coinvalue?.attributedText = NSAttributedString(string: String(blood), attributes: attributes)
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
        print("Hit")
        projectile.removeFromParent()
        if let child = childNode(withName: "heart."+String(lives)) {
            child.removeFromParent()
            let h = SKSpriteNode(imageNamed: "empty")
            h.name = "empty."+String(lives)
            h.position = CGPoint(x: size.width - CGFloat((lives)*40+30), y: size.height * 0.90)
            h.zPosition = Layer.ui.rawValue
            addChild(h)
            lives -= 1
        }
        if(lives == 0) {
            removeAllChildren()
            removeAllActions()
            var alert = UIAlertController(title: "Game Over", message: "Enter your nickname", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "Write here."
            })
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField
                self.resetMatch(playerName: textField.text!)
            }))
            getTopMostViewController()?.present(alert, animated: true)
        }
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }

        return topMostViewController
    }
    
    func resetMatch(playerName: String) {
        print("Dead")
        removeAllChildren()
        let leaderboard = decodeLeaderboard(userDefaultsKey: "score")
        let leaderboardChanged = leaderboard.copyAddRecord(record: Record(name: playerName , score: blood))
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
            if (loc.x > size.width * 0.5) {
                player.xScale = abs(player.xScale)
                player.physicsBody?.velocity = CGVector(dx: baseSpeed * debuffSpeed, dy: 0)
            } else {
                player.xScale = abs(player.xScale) * -1
                player.physicsBody?.velocity = CGVector(dx: -baseSpeed * debuffSpeed, dy: 0)
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }
    private func changeDiff(){
        self.stage += 1
        self.scalingFactor = pow(0.9, CGFloat(self.stage))
        self.dropSpeed = ((0.06 * baseSpeed * CGFloat(self.stage))).rounded()
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
                let arrowAudioNode = SKAction.playSoundFileNamed("Hitby_falling_object.mp3", waitForCompletion: false)
                let changeVolumeAction = SKAction.changeVolume(to: 0.3, duration: 0.3)
                let effectAudioGroup = SKAction.group([arrowAudioNode,changeVolumeAction])
                run(effectAudioGroup)
                projectileDidCollideWithPlayer(projectile: projectile, player: player)
                return
            }
        }
        // Player - Citizen
        if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.citizen != 0)) {
            if let citizen = secondBody.node as? Citizen {
                let bitAudioNode = SKAction.playSoundFileNamed("BiteBloodPickup.mp3", waitForCompletion: false)
                run(bitAudioNode)
                citizenDidCollideWithPlayer(citizen: citizen)
                return
            }
        }
    }
}
