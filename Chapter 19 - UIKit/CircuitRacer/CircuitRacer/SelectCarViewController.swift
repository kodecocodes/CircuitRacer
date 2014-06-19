//
//  SelectCarViewController.swift
//  CircuitRacer
//
//  Created by Kauserali on 15/06/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit

class SelectCarViewController: UIViewController {
    
    @IBAction func carButtonPressed(sender : UIButton) {
        SKTAudio.sharedInstance().playSoundEffect("button_press.wav")
        let levelViewController = self.storyboard.instantiateViewControllerWithIdentifier("SelectLevelViewController") as SelectLevelViewController
        levelViewController.carType = CarType.fromRaw(sender.tag)!
        self.navigationController.pushViewController(levelViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKTAudio.sharedInstance().playBackgroundMusic("circuitracer.mp3")
    }
}
