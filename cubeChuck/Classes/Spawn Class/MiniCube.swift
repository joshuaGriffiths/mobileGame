//
//  MiniCube.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/21/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import Foundation

import SpriteKit

class MiniCube: SKSpriteNode {
    
    var pi = CGFloat(Double.pi)
    
    //Initializes MiniCube Class Object
    //See Player Class to understand what all this means
    init(){
        let texture = SKTexture(imageNamed: "cube")
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = "minicube"
        self.setScale(CGFloat(0.25))
        //self.position = CGPoint(x: -620, y: -240)
        self.physicsBody = SKPhysicsBody(rectangleOf:self.size)
        self.physicsBody?.affectedByGravity = true
        self.zPosition = 5
        self.physicsBody?.categoryBitMask = ColliderType.MINICUBE
        self.physicsBody?.contactTestBitMask = ColliderType.TOWER
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
