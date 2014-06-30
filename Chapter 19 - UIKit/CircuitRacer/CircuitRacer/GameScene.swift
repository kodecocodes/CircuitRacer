/*
* Copyright (c) 2013-2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import SpriteKit

class GameScene: SKScene, AnalogControlPositionChange {
  
  let boxSoundAction = SKAction.playSoundFileNamed("box.wav", waitForCompletion: false)
  let hornSoundAction = SKAction.playSoundFileNamed("horn.wav", waitForCompletion: false)
  let lapSoundAction = SKAction.playSoundFileNamed("lap.wav", waitForCompletion: false)
  let nitroSoundAction = SKAction.playSoundFileNamed("nitro.wav", waitForCompletion: false)
  
  var playableRect: CGRect!
  var carType: CarType!
  var levelType: LevelType!
  var box1: SKSpriteNode!, box2: SKSpriteNode!
  var laps: SKLabelNode! , time: SKLabelNode!
  var previousTimeInterval: CFTimeInterval = 0
  
  var timeInSeconds = 0, noOfLaps = 0, maxSpeed = 0
  var trackCenter = CGPointMake(0, 0)
  var nextProgressAngle = M_PI
  
  typealias gameOverBlock = (didWin : Bool) -> Void
  var gameOverDelegate: gameOverBlock?
  
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */
    
    println("\(carType.description) \(levelType.description)")
    
    let maxAspectRatio = 16.0/9.0
    let maxAspectRatioHeight = size.width/maxAspectRatio
    let playableMargin = (size.height - maxAspectRatioHeight)/2
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height - playableMargin * 2)
    
    initializeGame()
  }
  
  override func update(currentTime: CFTimeInterval) {
    if previousTimeInterval == 0 {
      previousTimeInterval = currentTime
    }
    
    if paused {
      previousTimeInterval = currentTime
      return
    }
    
    if currentTime - previousTimeInterval > 1 {
      timeInSeconds -= Int(currentTime - previousTimeInterval)
      previousTimeInterval = currentTime
      if timeInSeconds >= 0 {
        time.text = "Time: \(timeInSeconds)"
      }
    }
    
    let carPosition = childNodeWithName("car").position
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
        runAction(lapSoundAction)
      }
    }
    
    if timeInSeconds < 0 || noOfLaps == 0 {
      paused = true
      
      if let gameOverCallback = gameOverDelegate {
        gameOverCallback(didWin: noOfLaps == 0)
      }
      println("Game over")
    }
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
    trackCenter = childNodeWithName("track").position
  }
  
  func loadLevel() {
    let filePath = NSBundle.mainBundle().pathForResource("LevelDetails", ofType:"plist")!
    let levels = NSArray(contentsOfFile: filePath)
    
    let levelData = levels[levelType.toRaw()] as NSDictionary
    timeInSeconds = levelData["time"] as Int
    noOfLaps = levelData["laps"] as Int
  }
  
  func setupPhysicsBodies() {
    
    //1. Add the inner boundary
    let innerBoundary = SKNode()
    innerBoundary.position = childNodeWithName("track").position
    addChild(innerBoundary)
    
    let size = CGSizeMake(360, 240)
    innerBoundary.physicsBody = SKPhysicsBody(rectangleOfSize:size)
    innerBoundary.physicsBody.dynamic = false
    
    //2. Outer boundary
    physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
  }
  
  func loadTrackTexture() {
    let track  = childNodeWithName("track") as SKSpriteNode
    track.texture = SKTexture(imageNamed: "track_" + "\(levelType.toRaw() + 1)")
  }
  
  func loadCarTexture() {
    let car = childNodeWithName("car") as SKSpriteNode
    car.texture = SKTexture(imageNamed:"car_" + "\(carType.toRaw() + 1)")
  }
  
  func loadObstacles() {
    box1 = childNodeWithName("box_1") as SKSpriteNode
    box2 = childNodeWithName("box_2") as SKSpriteNode
  }
  
  func addLabels() {
    laps = childNodeWithName("laps_label") as SKLabelNode
    time = childNodeWithName("time_left_label") as SKLabelNode
    
    laps.text = "Laps: \(noOfLaps)"
    time.text = "Time: \(timeInSeconds)"
  }
  
  func analogControlUpdated(relativePosition:CGPoint) {
    
    let car = childNodeWithName("car") as SKSpriteNode
    
    car.physicsBody.velocity = CGVectorMake(relativePosition.x * CGFloat(maxSpeed),
      -relativePosition.y * CGFloat(maxSpeed))
    
    if !CGPointEqualToPoint(relativePosition, CGPointZero) {
      car.zRotation = CGPointMake(relativePosition.x, -relativePosition.y).angle
    }
  }
  
  func analogControlPositionChanged(analogControl: AnalogControl, position: CGPoint)  {
    analogControlUpdated(position)
  }
}
