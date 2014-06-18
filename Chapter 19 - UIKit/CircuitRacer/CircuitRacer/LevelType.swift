//
//  LevelType.swift
//  CircuitRacer
//
//  Created by Kauserali on 15/06/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

enum LevelType : Int, Printable {
    case Easy
    case Medium
    case Hard
    
    var description : String {
        get {
            switch self {
            case .Easy:
                return "Easy level"
            case .Medium:
                return "Medium level"
            case .Hard:
                return "Hard level"
            }
        }
    }
}
