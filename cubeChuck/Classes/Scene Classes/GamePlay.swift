//
//  GameScene.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/16/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import SpriteKit
import GameplayKit

//***CONSTANTS***//
enum GameState {
    
    case playing
    case menu
    case setting
    static var current = GameState.playing
}

//***Physics***//
struct phys { //Physics Category
    
    static let none: UInt32 = 0x1 << 0
    static let cube: UInt32 = 0x1 << 1
    static let leftBin: UInt32 = 0x1 << 2
    static let rightBin: UInt32 = 0x1 << 3
    static let baseBin: UInt32 = 0x1 << 4
    static let strtGrnd: UInt32 = 0x1 << 5
    static let endGrnd: UInt32 = 0x1 << 6
}

//***Touch***//
struct tch { //start and end touch points
    
    static var start = CGPoint()//has x and y cordinates
    static var end = CGPoint()
    static var touchingBall = true
}

//***CONSTANTS***//
struct consts {
    
    static var grav = CGFloat()//Gravity 9.8
    static var yVel = CGFloat()//CHANGE THIS (this makes it so the user cant control distance of toss
    static var airTime = TimeInterval()//Time the cube is in the air
}

class GamePlay: SKScene, SKPhysicsContactDelegate {
    
    //TOGGLE PHYSICS BARRIERS
    var grids = true
    
    
    //Physics Objects
    var cube: SKSpriteNode!
    var leftWall = SKShapeNode()
    var rightWall = SKShapeNode()
    var baseWall = SKShapeNode()
    var endGround = SKShapeNode()
    var startGround = SKShapeNode()
    
    //LABELS
    var windLabel = SKLabelNode()
    
    var pi = CGFloat(M_PI)
    var windSpeed = CGFloat()
    
    var hasGone = false
    var originalCubePos: CGPoint!
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        //Sets our gravity
        //physicsWorld.gravity = CGVector(dx: 0,dy: consts.grav)
        
        cube = childNode(withName: "cube") as! SKSpriteNode
        cube.physicsBody? .affectedByGravity = true
        originalCubePos = cube.position
        
//        if UIDevice.current.userInterfaceIdiom == .phone {
//
//            consts.grav = -9.8
//            consts.yVel = self.frame.height
//            consts.airTime = 2
//        }
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        
        
        setupGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if GameState.current == .playing {
                
                if cube.contains(location){
                    
                    tch.start = location
                }
                
                if atPoint(location).name == "back" {
                    
                    if let scene = MainMenu(fileNamed: "MainMenuScene") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                        
                        // Present the scene
                        view!.presentScene(scene,transition: SKTransition.doorsOpenVertical(withDuration: TimeInterval(2)))
                    }
                }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if GameState.current == .playing && !cube.contains(location) && tch.touchingBall {
                
                tch.end = location
                fire()
                hasGone = true
                
                
            }
        }
    }
    
    
    func setupGame (){
        
        GameState.current = .playing
        
    }
    
    func fire(){
        
        let xChange = tch.end.x - tch.start.x
        let yChange = 20 * (tch.end.y -  tch.start.y)
        
        let angle = (atan(xChange / (tch.end.y - tch.start.y)) * 180 / pi)
        //Because we limit the yvalue of our toss we need to account for that in our x
        let ammendedX = (tan(angle * pi / 180) * yChange) * 0.5 //Play with this
        
        //Throw Cube
        let throwVec = CGVector(dx: ammendedX, dy: yChange)
        cube.physicsBody?.applyImpulse(throwVec, at: tch.start)
        
        
        //Change Collison BitMask
        let wait = SKAction.wait(forDuration: consts.airTime / 2)
        let changeCollision = SKAction.run ({
            self.cube.physicsBody? .collisionBitMask = phys.strtGrnd | phys.endGrnd | phys.baseBin | phys.leftBin | phys.rightBin
            //self.cube.zPosition = self.img_bg.zPosition + 2
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let cubePhysicsBody = cube.physicsBody {
            if cubePhysicsBody.velocity.dx <= 0.1 && cubePhysicsBody.velocity.dy <= 0.1 && cubePhysicsBody.angularVelocity <= 0.1 && hasGone {
                cube.physicsBody?.affectedByGravity = true
                cube.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                cube.physicsBody?.angularVelocity = 0
                cube.zRotation = 0
                cube.position = originalCubePos
                
                hasGone = false
                
                }
            }
        }
}
    
    
    

