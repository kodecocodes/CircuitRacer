//
//  GameScene.swift
//  CircuitRacer
//
//  Created by Kauserali on 14/06/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, AnalogControlPositionChange {
    
    var carType : CarType!
    var levelType : LevelType!
    var box1 : SKSpriteNode!, box2 : SKSpriteNode!
    var laps : SKLabelNode! , time : SKLabelNode!
    var boxSoundAction : SKAction!, hornSoundAction : SKAction!, lapSoundAction : SKAction!, nitroSoundAction : SKAction!
    var previousTimeInterval : CFTimeInterval = 0
    
    var timeInSeconds = 0
    var noOfLaps = 0
    var maxSpeed = 0
    var trackCenter : CGPoint = CGPointMake(0, 0)
    var nextProgressAngle : Double = M_PI
    
    typealias gameOverBlock = (didWin : Bool) -> Void
    var gameOverDelegate : gameOverBlock?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        println("\(carType.description) \(levelType.description)")
        initializeGame()
    }
    
    func initializeGame() {
        loadLevel()
        setupPhysicsBodies()
        loadTrackTexture()
        loadCarTexture()
        loadObstacles()
        addLabels()
        
        println("\(carType.toRaw())")
        maxSpeed = 250 * (2 + carType.toRaw())
        trackCenter = self.childNodeWithName("track").position
        
        boxSoundAction = SKAction.playSoundFileNamed("box.wav", waitForCompletion: false)
        hornSoundAction = SKAction.playSoundFileNamed("horn.wav", waitForCompletion: false)
        lapSoundAction = SKAction.playSoundFileNamed("lap.wav", waitForCompletion: false)
        nitroSoundAction = SKAction.playSoundFileNamed("nitro.wav", waitForCompletion: false)
    }
    
    func loadLevel() {
        let filePath = NSBundle.mainBundle().pathForResource("LevelDetails", ofType:"plist")!
        let levels = NSArray(contentsOfFile: filePath)
        
        let levelData = levels[levelType.toRaw()] as NSDictionary
        timeInSeconds = levelData["time"] as Int
        noOfLaps = levelData["laps"] as Int
    }
    
    func setupPhysicsBodies() {
        //These just dont work in the editor
        
        //1. Add the inner boundary
        let innerBoundary = SKNode()
        innerBoundary.position = self.childNodeWithName("track").position
        self.addChild(innerBoundary)
        
        let size = CGSizeMake(360, 240)
        innerBoundary.physicsBody = SKPhysicsBody(rectangleOfSize:size)
        innerBoundary.physicsBody.dynamic = false
        
        //2. Outer boundary
        let trackFrame = CGRectInset(self.childNodeWithName("track").frame, 40, 0)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: trackFrame)
    }
    
    func loadTrackTexture() {
        let track  = self.childNodeWithName("track") as SKSpriteNode
        track.texture = SKTexture(imageNamed: "track_" + "\(levelType.toRaw() + 1)")
    }
    
    func loadCarTexture() {
        let car = self.childNodeWithName("car") as SKSpriteNode
        car.texture = SKTexture(imageNamed:"car_" + "\(carType.toRaw() + 1)")
    }
    
    func loadObstacles() {
        box1 = self.childNodeWithName("box_1") as SKSpriteNode
        box2 = self.childNodeWithName("box_2") as SKSpriteNode
    }
    
    func addLabels() {
        laps = self.childNodeWithName("laps_label") as SKLabelNode
        time = self.childNodeWithName("time_left_label") as SKLabelNode
        
        laps.text = "Laps: \(noOfLaps)"
        time.text = "Time: \(timeInSeconds)"
    }

    func analogControlUpdated(relativePosition:CGPoint) {
 
        let car : SKSpriteNode = self.childNodeWithName("car") as SKSpriteNode
            
        car.physicsBody.velocity = CGVectorMake(relativePosition.x * Float(maxSpeed),
                                                -relativePosition.y * Float(maxSpeed))
        
        if !CGPointEqualToPoint(relativePosition, CGPointZero) {
            car.zRotation = CGPointMake(relativePosition.x, -relativePosition.y).angle
        }
    }
    
    func analogControlPositionChanged(analogControl: AnalogControl, position: CGPoint)  {
        analogControlUpdated(position)
    }
    
    override func update(currentTime: CFTimeInterval) {
        if previousTimeInterval == 0 {
            previousTimeInterval = currentTime
        }
        
        if self.paused {
            previousTimeInterval = currentTime
        }
        
        if currentTime - previousTimeInterval > 1 {
            timeInSeconds -= Int(currentTime - previousTimeInterval)
            previousTimeInterval = currentTime
            if timeInSeconds >= 0 {
                time.text = "Time: \(timeInSeconds)"
            }
        }
        
        let carPosition = self.childNodeWithName("car").position
        let vector = carPosition - trackCenter
        let progressAngle = Double(vector.angle) + M_PI
        
        if progressAngle > nextProgressAngle && (progressAngle - nextProgressAngle) < M_PI_4 {
            //advance on track
            nextProgressAngle += M_PI_2
            if nextProgressAngle >= (2 * M_PI) {
                nextProgressAngle = 0
            }

            if fabs(nextProgressAngle - M_PI) < Double(FLT_EPSILON) {
                noOfLaps -= 1
                laps.text = "Laps: \(noOfLaps)"
                self.runAction(lapSoundAction)
            }
        }
        
        if timeInSeconds < 0 || noOfLaps == 0 {
            self.paused = true
            
            if let gameOverCallback = gameOverDelegate {
                gameOverCallback(didWin: noOfLaps == 0)
            }
            println("Game over")
        }
    }
}
