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

protocol AnalogControlPositionChange {
  func analogControlPositionChanged(analogControl: AnalogControl, position: CGPoint)
}

class AnalogControl: UIView {
  
  let baseCenter: CGPoint
  let knobImageView: UIImageView
  
  var relativePosition: CGPoint!
  var delegate: AnalogControlPositionChange?
  
  init(frame: CGRect) {
    
    //1
    baseCenter = CGPointMake(frame.size.width/2, frame.size.height/2)
    
    //2
    knobImageView = UIImageView(image: UIImage(named: "knob.png"))
    knobImageView.center = baseCenter
    
    super.init(frame: frame)
    
    //3
    userInteractionEnabled = true
    
    //4
    let baseImageView = UIImageView(frame: bounds)
    baseImageView.image = UIImage(named: "base.png")
    addSubview(baseImageView)
    
    //5
    addSubview(knobImageView)
    
    //6
    assert(CGRectContainsRect(bounds, knobImageView.bounds),
      "Analog control size should be greater than the knob size")
  }
  
  override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
    let touchLocation = touches.anyObject().locationInView(self)
    updateKnobWithPosition(touchLocation)
  }
  
  override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
    let touchLocation = touches.anyObject().locationInView(self)
    updateKnobWithPosition(touchLocation)
  }
  
  override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
    updateKnobWithPosition(baseCenter)
  }
  
  override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
    updateKnobWithPosition(baseCenter)
  }
  
  func updateKnobWithPosition(position:CGPoint) {
    //1
    println("\(position.x) \(position.y)")
    println("\(baseCenter.x) \(baseCenter.y)")
    var positionToCenter = position - baseCenter
    var direction : CGPoint
    
    if positionToCenter == CGPointZero {
      direction = CGPointZero
    } else {
      direction = positionToCenter.normalized()
    }
    
    //2
    let radius = frame.size.width/2
    var length = positionToCenter.length()
    
    //3
    if length > radius {
      length = radius
      positionToCenter = direction * radius
    }
    
    let relPosition = CGPointMake(direction.x * (length/radius), direction.y * (length/radius))
    
    knobImageView.center = baseCenter + positionToCenter
    relativePosition = relPosition
    
    if let delegate = self.delegate {
      delegate.analogControlPositionChanged(self, position: relativePosition)
    }
    println("\(relativePosition)")
  }
}