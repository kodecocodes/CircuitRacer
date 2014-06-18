//
//  SelectLevelViewController.swift
//  CircuitRacer
//
//  Created by Kauserali on 15/06/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit

class SelectLevelViewController: UIViewController {

    var carType : CarType!
    var levelType : LevelType!
    
    @IBAction func levelButtonPressed(sender : UIButton) {
        SKTAudio.sharedInstance().playSoundEffect("button_press.wav")
        
        levelType = LevelType.fromRaw(sender.tag)
        println("\(levelType.description) \(carType.description)")
        
        let gameViewController = self.storyboard.instantiateViewControllerWithIdentifier("GameViewController") as GameViewController
        gameViewController.carType = carType
        gameViewController.levelType = levelType
        self.navigationController.pushViewController(gameViewController, animated: true)
    }
    
    @IBAction func backButtonPressed(sender : UIButton) {
        self.navigationController.popViewControllerAnimated(true)
        SKTAudio.sharedInstance().playSoundEffect("button_press.wav")
    }
}
