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
    
    init(){
        let texture = SKTexture(imageNamed: "cube")
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
        self.name = "Player"
        self.setScale(CGFloat(0.5))
        self.position = CGPoint(x: -620, y: -240)
        self.physicsBody = SKPhysicsBody(rectangleOf:self.size)
        self.physicsBody?.affectedByGravity = false
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
    
    
    
//    func initPlayer(){
//
//        name = "cube";
//        physicsBody = SKPhysicsBody(rectangleOf: size);
//        physicsBody?.affectedByGravity = true;
//        physicsBody?.isDynamic = true;
//        physicsBody?.categoryBitMask = ColliderType.PLAYER
//
//
//
//
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        for touch in touches {
//            
//            let location = touch.location(in: self);
//            tch.start = location
//        }
//    }
//    
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//       
//        
//        for touch in touches {
//            
//            let location = touch.location(in: self);
//            tch.end = location
//            fire(tchStrt: tch.start,tchEnd: tch.end);
//        }
//    }
//    
//    func fire(tchStrt: CGPoint, tchEnd: CGPoint) {
//        
//        let xChange = tchEnd.x - tchStrt.x;
//        let yChange = 20 * (tchEnd.y -  tchStrt.y);
//        
//        let angle = (atan(xChange / (tchEnd.y - tchStrt.y)) * 180 / pi);
//        //Because we limit the yvalue of our toss we need to account for that in our x
//        let ammendedX = (tan(angle * pi / 180) * yChange) * 0.5; //Play with this
//        
//        //Throw Cube
//        let throwVec = CGVector(dx: ammendedX, dy: yChange);
//        self.physicsBody?.applyImpulse(throwVec, at: tchStrt);
//    }
    
}
