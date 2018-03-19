//
//  MainMenuScene.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/19/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self);
            
            if atPoint(location).name == "start" {
                
                if let scene = GamePlay(fileNamed: "GameScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view!.presentScene(scene,transition: SKTransition.doorsOpenVertical(withDuration: TimeInterval(2)))
                }
            }
            
            if atPoint(location).name == "settings" {
                
                if let scene = Settings(fileNamed: "SettingsScene") {
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFill
                    
                    // Present the scene
                    view!.presentScene(scene,transition: SKTransition.doorsOpenVertical(withDuration: TimeInterval(2)))
                }
            }

            
        }
    }
}
