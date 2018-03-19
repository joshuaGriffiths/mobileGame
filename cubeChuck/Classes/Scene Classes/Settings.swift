//
//  Settings.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/19/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import SpriteKit

class Settings: SKScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self);
            
            if atPoint(location).name == "back_settings" {
                
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
