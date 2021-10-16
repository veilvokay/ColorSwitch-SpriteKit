//
//  GameScene.swift
//  ColorSwitch
//
//  Created by Roman Yakovliev on 13.10.2021.
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
    ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState: SwitchState = SwitchState.red
    var currentColorIndex: Int?
    
    var gravity: CGFloat = -2.5
    var gravityUpdateLabel = SKLabelNode(text: "Gravity increased")
    var gravityUpdateBreakpoint = 2
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
    
    override func didMove(to view: SKView) {
        setupPhysics()
        layoutScene()
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        gravityUpdateLabel.fontName = "AvenirNext-Bold"
        gravityUpdateLabel.fontSize = 40.0
        gravityUpdateLabel.fontColor = UIColor(red: 214/255, green: 56/255, blue: 102/255, alpha: 1.0)
        gravityUpdateLabel.position = CGPoint(x: frame.midX, y: frame.midY + (scoreLabel.frame.size.height + gravityUpdateLabel.frame.size.height))
        gravityUpdateLabel.zPosition = ZPositions.label
        gravityUpdateLabel.alpha = 0.0
        
        addChild(gravityUpdateLabel)
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height)
        colorSwitch.zPosition = ZPositions.colorSwitch
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        
        addChild(colorSwitch)
        
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = ZPositions.label
        
        addChild(scoreLabel)
    
        spawnBall()
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    func spawnBall() {
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.maxY - colorSwitch.size.height)
        ball.zPosition = ZPositions.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        
        addChild(ball)
    }
    
    func turnWheel() {
        if let newState = SwitchState(rawValue: switchState.rawValue + 1) {
            switchState = newState
        } else {
            switchState = .red
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.25))
    }
    
    func updateGravity() {
        let tempScore = score != 0 ? ceil(Float(score)/10) : 1
        if tempScore == Float(gravityUpdateBreakpoint) {
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.3)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
            let sequence = SKAction.sequence([fadeIn, fadeOut])
            let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
            gravityUpdateLabel.run(sequence)
            gravityUpdateLabel.run(scaleSequence)

            gravity -= 1
            physicsWorld.gravity = CGVector(dx: 0.0, dy: gravity)
            gravityUpdateBreakpoint += 1
        }
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        turnWheel()
    }
    
}


extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // contactMasks
        // 01 ball
        // 10 switch
        // adds up on contact
        // 11 result (10 + 01)
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    run(SKAction.playSoundFileNamed("bling", waitForCompletion: false))
                    score += 1
                    updateScoreLabel()
                    updateGravity()
                    ball.run(SKAction.fadeOut(withDuration: 0.25)) {
                        ball.removeFromParent()
                        self.spawnBall()
                    }
                } else {
                    gameOver()
                }
            }
        }
    }
    
}
