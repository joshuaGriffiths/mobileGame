//
//  cube.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/19/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {

    var pi = CGFloat(Double.pi)
    static let sharedInstance = Player()
    
    init(){
        let texture = SKTexture(imageNamed: "cube")
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = "Player"
        self.setScale(CGFloat(0.5))
        self.position = CGPoint(x: -620, y: -240)
        self.physicsBody = SKPhysicsBody(rectangleOf:self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 0.05 //bounciness 
        self.zPosition = 5
        self.physicsBody?.categoryBitMask = ColliderType.PLAYER
        self.physicsBody?.contactTestBitMask = ColliderType.TOWER
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.isDynamic = true
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Fire the player
    func fire(){
        
        let xChange = tch.end.x - tch.start.x
        let yChange = (tch.end.y -  tch.start.y)/5
        
        let angle = (atan(xChange / (tch.end.y - tch.start.y)) * 180 / pi)
        //Because we limit the yvalue of our toss we need to account for that in our x
        let ammendedX = (tan(angle * pi / 180) * yChange) * 0.5 //Play with this
        
        //Throw Cube
        let throwVec = CGVector(dx: ammendedX, dy: yChange)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.applyImpulse(throwVec, at: tch.start)
        
    }
}
