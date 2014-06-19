//
//  GameViewController.swift
//  CircuitRacer
//
//  Created by Kauserali on 14/06/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks")
        
        var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
        var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {

    var carType: CarType!
    var levelType: LevelType!
    let motionManager: CMMotionManager = CMMotionManager()
    
//    var analogControl : AnalogControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.levelType = levelType
            scene.carType = carType
            
            skView.presentScene(scene)
            
            let padSide : CGFloat = 128.0
            let padPadding : CGFloat = 10.0
            
//            analogControl = AnalogControl(frame: CGRectMake(padPadding,
//                skView.frame.size.height - padPadding - padSide, padSide, padSide))
//            analogControl.delegate = scene
//            self.view.addSubview(analogControl)
            
            scene.gameOverDelegate = {[weak self] (didWin) in
                println("Status:\(didWin)")
                
                if let validSelf = self {
                    validSelf.gameOverWithWin(didWin)
                }
            }
            
            motionManager.accelerometerUpdateInterval = 0.05
            motionManager.startAccelerometerUpdates()
            scene.motionManager = motionManager
        }
    }
    
    @IBAction func showInGameMenu(sender : UIButton) {
        let alert = UIAlertController(title: "Game Menu", message: "What would you like to do", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Resume level", style: .Cancel, handler: {[weak self](alert :UIAlertAction!) in
                if let validSelf = self {
                    let skView = validSelf.view as SKView
                    skView.paused = false
                }
            }))
        alert.addAction(UIAlertAction(title: "Go to menu", style: .Default, handler: {[weak self](alert :UIAlertAction!) in
                if let validSelf = self {
                    let skView = validSelf.view as SKView
                    skView.paused = false
                    validSelf.gameOverWithWin(false)
                }
            }))
        
        self.presentViewController(alert, animated: true, completion: nil)

        let skView = self.view as SKView
        skView.scene.paused = true
    }
    
    func gameOverWithWin(didWin:Bool) {
        let alert = UIAlertController(title: didWin ? "You won!" : "You lost", message: "Game Over", preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)

        let delayInSeconds = 2.0
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds) * Int64(NSEC_PER_SEC))
        dispatch_after(popTime, dispatch_get_main_queue(),  {
                [weak self] in
            
                if let validSelf = self {
                    validSelf.goBack(alert)
                }
            })
    }
    
    func goBack(alert:UIAlertController) {
        alert.dismissViewControllerAnimated(true, completion: {
            [weak self] in
            
            if let validSelf = self {
                validSelf.navigationController.popToRootViewControllerAnimated(false)
            }
        })
    }
}
