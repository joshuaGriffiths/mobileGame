//
//  Tower.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/20/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import Foundation

import UIKit
import SpriteKit

class Tower: SKSpriteNode {
    
    //Initializes Tower Class Object
    //See Player Class to understand what all this means
    init() {
        let texture = SKTexture(imageNamed: "tower")
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = "tower"
        self.zPosition = 5
        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size);
        self.physicsBody?.categoryBitMask = ColliderType.TOWER;
        self.physicsBody?.contactTestBitMask = ColliderType.PLAYER
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
