//
//  CarType.swift
//  CircuitRacer
//
//  Created by Kauserali on 15/06/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

enum CarType : Int, Printable {
    case Yellow = 0
    case Blue
    case Red
    
    var description :String {
        get {
            switch self {
            case .Yellow:
                return "Yellow car"
            case .Blue:
                return "Blue car"
            case .Red:
                return "Red car"
            }
        }
    }
}
