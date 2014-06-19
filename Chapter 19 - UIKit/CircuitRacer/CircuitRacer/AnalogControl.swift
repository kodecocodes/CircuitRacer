//
//  AnalogControl.swift
//  CircuitRacer
//
//  Created by Kauserali on 16/06/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit

protocol AnalogControlPositionChange {
    func analogControlPositionChanged(analogControl : AnalogControl, position : CGPoint)
}

class AnalogControl: UIView {

    var relativePosition: CGPoint!
    var baseCenter: CGPoint!
    var knobImageView: UIImageView!
    var delegate: AnalogControlPositionChange?
    
    init(frame: CGRect) {
        super.init(frame: frame)
        
        //1
        self.userInteractionEnabled = true
        
        //2
        let baseImageView = UIImageView(frame: self.bounds)
        baseImageView.image = UIImage(named: "base.png")
        self.addSubview(baseImageView)
        
        //3
        baseCenter = CGPointMake(frame.size.width/2, frame.size.height/2)
        
        //4
        knobImageView = UIImageView(image: UIImage(named: "knob.png"))
        knobImageView.center = baseCenter
        self.addSubview(knobImageView)
        
        //5
        assert(CGRectContainsRect(self.bounds, knobImageView.bounds),
            "Analog control size should be greater than the knob size")
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
        let radius = self.frame.size.width/2
        var length = positionToCenter.length()
        
        //3
        if length > radius {
            length = radius
            positionToCenter = direction * radius
        }
        
        let relPosition = CGPointMake(direction.x * (length/radius), direction.y * (length/radius))
        
        knobImageView.center = baseCenter + positionToCenter
        self.relativePosition = relPosition
        
        if let unmarshell = delegate {
            unmarshell.analogControlPositionChanged(self, position: relativePosition)
        }
        println("\(relativePosition)")
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
}