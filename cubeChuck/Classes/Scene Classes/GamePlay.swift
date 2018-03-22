//
//  GameScene.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/16/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import SpriteKit
import GameplayKit

//***GameMode***//
enum GameState {
    
    case playing
    case menu
    case setting
    static var current = GameState.playing
}

//***Touch***//
struct tch { //start and end touch points
    
    static var start = CGPoint()//has x and y cordinates
    static var end = CGPoint()
}

//GLOBALS FOR SETTING MANIPULATION
var numTowers = 2
var numLifes = 3//number of lives the player has (should be moved to player class)
let player:Player = Player()

class GamePlay: SKScene, SKPhysicsContactDelegate {
    
    
    //LABELS
    var lifeLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    
    //Variables
    var pi = CGFloat(Double.pi)

    var score = 0
    var hasGone = false  // to detect if cube has left (should be removed)
    var originalCubePos: CGPoint! //to allow for cube updating(should be removed)
    
    
    //SET UP SCENE
    override func didMove(to view: SKView) {
        
        //Create contact world
        self.physicsWorld.contactDelegate = self
        
        //INitialize Labels
        lifeLabel = childNode(withName: "livesLabel") as? SKLabelNode!
        lifeLabel?.text = String(numLifes)
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode!
        scoreLabel?.text = String(score)
        
        //Spawn towers and players
        spawnTowers()
        spawnPlayer()
    }
    
    
    
    
    //REGISTER A TOUCH ON THE SCREEN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            //IF WE TOUCH THE CUBE
            if GameState.current == .playing {

                if player.contains(location){

                    tch.start = location
                }
            
                //BACK BUTTON
                if atPoint(location).name == "back" {
                    
                    if let scene = MainMenu(fileNamed: "MainMenuScene") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                        
                        // Present the scene
                        view!.presentScene(scene,transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(2)))
                    }
                }
            }
        }
    }
    
    
    
    
    //REGISTER END TOUCH ON THE SCREEN
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if GameState.current == .playing && !player.contains(location) {

                tch.end = location
                player.fire()
                hasGone = true
            }
        }
    }
    
    
    //DETECTING COLLISION
    func didBegin(_ contact: SKPhysicsContact) {

        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();

        //This is to detect what hits what
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "ground" {
            NSLog("Player and ground Conatact")
        
         }

        if firstBody.node?.name == "Player" && secondBody.node?.name == "tower" {
             NSLog("Player and tower Conatact")
            
            let towerY = (secondBody.node?.position.y)! + 250
            let towerX = secondBody.node?.position.x
            
            spawnMiniCubes(towX: towerX!, towY: towerY)
            numLifes += 1

        }
        
        
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "tower" {
            NSLog("minicube and tower Conatact")
            
            let towerY = (secondBody.node?.position.y)! + 250
            let towerX = secondBody.node?.position.x
            
            spawnMiniCubes(towX: towerX!, towY: towerY)
            
        }
        
        
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "ground" {
            NSLog("minicube and ground Conatact")
            score += 1
            scoreLabel?.text = String(score)
            
        }
    }
    
    
    
    
    
    
    //Replace the cube
    override func update(_ currentTime: TimeInterval) {
        if let cubePhysicsBody = player.physicsBody {
            if cubePhysicsBody.velocity.dx <= 0.1 && cubePhysicsBody.velocity.dy <= 0.1 && cubePhysicsBody.angularVelocity <= 0.1 && hasGone {
                
                numLifes -= 1
                lifeLabel?.text = String(numLifes)
                if numLifes == 0 {
                    
                    endGame()
                }
                
                player.position = originalCubePos
                hasGone = false

                }
            }
        }
    
    
    
    //PRINT AND GO TO MAIN MENU
    func endGame(){
        
        
        //PRINT GAME OVER
        if let scene = MainMenu(fileNamed: "MainMenuScene"){
            
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(2)))
        }
    }
    
    //Spawn Towers that will have the target
    func spawnTowers(){
        

        let numberOfTowers = numTowers * 2 + 1
        
        for _ in 1..<numberOfTowers {
            
        let tempTower:Tower = Tower()
        tempTower.position.x = randNumb(firstNum: CGFloat(640), secNum: CGFloat(-240))
        tempTower.position.y = -250;
        tempTower.size.height = randNumb(firstNum: CGFloat(700), secNum: CGFloat(250))
            
        addChild(tempTower)
            
        }
    }
    
    
    //Spawn the player
    func spawnPlayer(){
        originalCubePos = player.position
        addChild(player)
    }
    
    
    //Spawn the minicubes on contact
    func spawnMiniCubes(towX: CGFloat, towY: CGFloat){
        
        
        let numberOfTowers = numTowers * 2 + 1
        
        for _ in 1..<numberOfTowers {
            
            let tempMiniCube:MiniCube = MiniCube()
            tempMiniCube.position.x = towX
            tempMiniCube.position.y = towY
            
            addChild(tempMiniCube)
            let tempImpulse = CGVector(dx: randNumb(firstNum: -5, secNum: 5), dy: 15)
            tempMiniCube.physicsBody?.applyImpulse(tempImpulse)
            
        }
    }
    
    //Helper function returns random number
    func randNumb(firstNum: CGFloat, secNum: CGFloat)->CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secNum) + min(firstNum,secNum)
    }
    
}
    
    
    

