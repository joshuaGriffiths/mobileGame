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
    static let sharedInstance = Player()//make player a singelton
    
    //Initialize Player
    init(){
        let texture = SKTexture(imageNamed: "cube")//attatch image to player
        super.init(texture: texture, color: SKColor.clear, size: texture.size())//size of player is size of image
        self.name = "Player"
        self.setScale(CGFloat(0.375))//scale the player to be 0.375 of the original image
        self.position = CGPoint(x: -620, y: -240)//player position is hard coded to bottom left of screen
        self.physicsBody = SKPhysicsBody(rectangleOf:self.size)//player physics body is size of player image
        self.physicsBody?.affectedByGravity = false//so player doesnt drop out of sky on intialization
        self.physicsBody?.restitution = 0.05 //bounciness 
        self.zPosition = 5//layer on the screen
        self.physicsBody?.categoryBitMask = ColliderType.PLAYER//for collision detection
        self.physicsBody?.contactTestBitMask = ColliderType.TOWER//for collision detection
        self.physicsBody?.allowsRotation = true
        self.physicsBody?.isDynamic = true//allow player to come in contact with other objects
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Fire the player
    func fire(){
        
        let throwMultiplier = CGFloat(10)//allows for adjustment on how far to throw player based on the touch on the screen
        
        //How far on the screen did the user hold down for
        let xChange = tch.end.x - tch.start.x
        let yChange = (tch.end.y -  tch.start.y)/throwMultiplier
        
        let angle = (atan(xChange / (tch.end.y - tch.start.y)) * 180 / pi)
        //Because we limit the yvalue of our toss we need to account for that in our x
        let ammendedX = (tan(angle * pi / 180) * yChange) * 0.5 //Play with this
        
        //Throw Cube
        let throwVec = CGVector(dx: ammendedX, dy: yChange)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.applyImpulse(throwVec, at: tch.start)
        
    }
}
