//
//  SpawnItems.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/19/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import SpriteKit
import UIKit

struct ColliderType {
    
    static let PLAYER: UInt32 = 0;
    static let TOWER: UInt32 = 1;
    static let MINICUBE: UInt32 = 2;
    static let TOWERTOP: UInt32 = 3
}

class SpawnItems {
    
    func spawnItems()-> SKSpriteNode {
        
        let item: SKSpriteNode?;
        //let cubeOne: SKSpriteNode?;
     
        item = SKSpriteNode(imageNamed: "tower");
        //item!.name = "tower";
        item!.setScale(1.0);//PLAY WITH THIS to get the random height
        item!.size.height = randNumb(firstNum: CGFloat(700), secNum: CGFloat(250));
        item!.physicsBody = SKPhysicsBody(rectangleOf: item!.size);
        item!.physicsBody?.categoryBitMask = ColliderType.TOWER;
        item!.physicsBody?.affectedByGravity = false
        item!.physicsBody?.allowsRotation = false
        item!.physicsBody?.isDynamic = false
        item!.zPosition = 3;
        item!.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        //SPAWN Towers Position Randomly
        
        //TO USE SCENE FRAME HEIGHT GO TO 18:00 on Spawning Fruits Tutorial
        
        //item!.position.x = randNumb(firstNum: scene.frame.width, secNum: 50 -scene.frame.width)
        //let rand = randNumb(firstNum: CGFloat(1000), secNum: CGFloat(-1000));
        item!.position.x = randNumb(firstNum: CGFloat(640), secNum: CGFloat(-240));
        item!.position.y = -250;
        
        //IF WE WANT TO INITIALIZE SMALLER CUBES WHEN WE INITIALIZE THE TOWER
//        cubeOne = SKSpriteNode(imageNamed: "box");
//        cubeOne!.name = "miniCube";
//        cubeOne!.setScale(0.25);//PLAY WITH THIS to get the random height
//        //item!.setValue(value: CGFloat(0.5), forKeyPath: item!.size.height)
//        cubeOne!.physicsBody = SKPhysicsBody(rectangleOf: item!.size);
//        cubeOne!.physicsBody?.categoryBitMask = ColliderType.TOWER;
//        cubeOne!.physicsBody?.affectedByGravity = true
//        cubeOne!.physicsBody?.allowsRotation = false
//        cubeOne!.physicsBody?.isDynamic = true
//        cubeOne!.zPosition = 4;//make 2
//        //cubeOne!.anchorPoint = item!.anchorPoint;
//        cubeOne!.position.x = item!.position.x;
//        //cubeOne!.position.y = item!.position.y;
//        return (item!,cubeOne!);
        
        return item!;
        
    }
    
    
    
    
    //RETURNS Random Number between firstNum and secondNum
    func randNumb(firstNum: CGFloat, secNum: CGFloat)->CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secNum) + min(firstNum,secNum)
    }
    
    
}








