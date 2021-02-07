//
//  Bullet.swift
//  AR Fighter
//
//  Created by Gokhan Bayir on 2.02.2021.
//


import UIKit
import SceneKit

// Spheres that are shot at the "ships"
class Bullet: SCNNode {
    override init () {
        super.init()
        let sphere = SCNSphere(radius: 0.095)
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        self.physicsBody?.contactTestBitMask = PhysicsCategories.EnemyMan | PhysicsCategories.EnemyWoman
        self.physicsBody?.collisionBitMask = PhysicsCategories.None
        
        self.geometry?.materials.first?.diffuse.contents = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
