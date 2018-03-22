//
//  Settings.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/19/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import SpriteKit

class Settings: SKScene {
    
    //LABELS
    var lifeLabel: SKLabelNode?
    var easyLabel: SKLabelNode?
    var mediumLabel: SKLabelNode?
    var hardLabel: SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        lifeLabel = childNode(withName: "numLives") as? SKLabelNode!
        easyLabel = childNode(withName: "easyCheck") as? SKLabelNode!
        mediumLabel = childNode(withName: "mediumCheck") as? SKLabelNode!
        hardLabel = childNode(withName: "hardCheck") as? SKLabelNode!
        lifeLabel?.text = String(numLifes)
        
        if numTowers == 1 {
            
            hardLabel?.zPosition = 3
            
        } else if numTowers == 2 {
            
            mediumLabel?.zPosition = 3
            
        } else {
            
            hardLabel?.zPosition = 3
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self);
            
            if atPoint(location).name == "back_settings" {
                
                if let scene = MainMenu(fileNamed: "MainMenuScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view!.presentScene(scene,transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(2)))
                }
            }
            
            //Handle setting manipulation
            if atPoint(location).name == "numLives_increase" {
                
                numLifes += 1
                lifeLabel?.text = String(numLifes)
            }
            
            if atPoint(location).name == "numLives_decrease" {
                
                numLifes -= 1
                lifeLabel?.text = String(numLifes)
            }
            
            if atPoint(location).name == "difEasy" {
                
                numTowers = 3
                easyLabel?.zPosition = 3
                mediumLabel?.zPosition = 0
                hardLabel?.zPosition = 0
                
            }
            
            if atPoint(location).name == "difMedium" {
                
                numTowers = 2
                easyLabel?.zPosition = 0
                mediumLabel?.zPosition = 3
                hardLabel?.zPosition = 0
                
            }
            
            if atPoint(location).name == "difHard" {
                
                numTowers = 1
                easyLabel?.zPosition = 0
                mediumLabel?.zPosition = 0
                hardLabel?.zPosition = 3
                
            }
            
        }
        
    }
    
    

}
