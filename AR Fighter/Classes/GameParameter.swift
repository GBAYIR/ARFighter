//
//  GameParameter.swift
//  AR Fighter
//
//  Created by Gokhan Bayir on 1.02.2021.
//

import Foundation

class GameParameter  {
    
    static let sharedInstance = GameParameter()
    var score: Int = 0
    
}

struct PhysicsCategories {
    static let None: Int = 0
    static let Player: Int = 0b1 //1
    static let Bullet: Int = 0b10 //2
    static let EnemyMan: Int = 0b100
    static let EnemyWoman: Int = 0b1000
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0) //moves 0 bits to left for 0000001
    static let target = CollisionCategory(rawValue: 1 << 1) //moves 1 bits to left for 00000001 then you have 00000010
    static let player = CollisionCategory(rawValue: 1 << 2) //moves 1 bits to left for 00000001 then you have 00000100
}

