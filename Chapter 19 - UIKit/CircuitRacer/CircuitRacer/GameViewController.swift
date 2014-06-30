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

import UIKit
import SpriteKit

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
  var analogControl: AnalogControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
      // Configure the view.
      let skView = view as SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      
      /* Sprite Kit applies additional optimizations to improve rendering performance */
      skView.ignoresSiblingOrder = true
      
      /* Set the scale mode to scale to fit the window */
      scene.scaleMode = .AspectFill
      scene.levelType = levelType
      scene.carType = carType
      
      skView.presentScene(scene)
      
      let analogControlSize: CGFloat = UIImage(named: "base").size.width
      let analogControlPadding: CGFloat = 10.0
      
      analogControl = AnalogControl(frame: CGRectMake(analogControlPadding,
        skView.frame.size.height - analogControlPadding - analogControlSize, analogControlSize, analogControlSize))
      analogControl.delegate = scene
      view.addSubview(analogControl)
      
      scene.gameOverDelegate = {[weak self] (didWin) in
        println("Status:\(didWin)")
        
        if let unwrappedSelf = self {
          unwrappedSelf.gameOverWithWin(didWin)
        }
      }
    }
  }
  
  func gameOverWithWin(didWin:Bool) {
    let alert = UIAlertController(title: didWin ? "You won!" : "You lost", message: "Game Over", preferredStyle: .Alert)
    self.presentViewController(alert, animated: true, completion: nil)
    
    let delayInSeconds = 2.0
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds) * Int64(NSEC_PER_SEC))
    dispatch_after(popTime, dispatch_get_main_queue(), {[weak self] in
      if let validSelf = self {
        validSelf.goBack(alert)
      }
    })
  }
  
  func goBack(alert:UIAlertController) {
    alert.dismissViewControllerAnimated(true, completion: {[weak self] in
      if let unwrappedSelf = self {
        unwrappedSelf.navigationController.popToRootViewControllerAnimated(false)
      }
    })
  }
}
