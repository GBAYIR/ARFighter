//
//  Player.swift
//  ARDicee
//
//  Created by Gokhan Bayir on 1.02.2021.
//

import UIKit
import SceneKit

class Player: SCNNode {
    override init() {
        super.init()
        let box = SCNBox(width: 0.5, height: 1, length: 0.5, chamferRadius: 0)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.opacity = 0.01
        
        self.physicsField = SCNPhysicsField.electric()
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategories.EnemyMan | PhysicsCategories.EnemyWoman
        self.physicsBody?.collisionBitMask = PhysicsCategories.None
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "abstract")
        self.geometry?.materials  = [material, material, material, material, material, material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
