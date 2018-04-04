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
var towerTop = SKShapeNode()
var shotCounter = 0

class GamePlay: SKScene, SKPhysicsContactDelegate {
    
    
    //LABELS
    var lifeLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    var gameOver_label: SKLabelNode?
    var finalScore_label: SKLabelNode?
    var finalScore_score: SKLabelNode?
    
    //Variables
    var pi = CGFloat(Double.pi)

    let score = Score.sharedInstance
    let scoreSingeltonProof = Score.sharedInstance
    
    var hasGone = false  // to detect if cube has left (should be removed)
    var hitTower = false // to detect if a cube has hit a
    var originalCubePos: CGPoint! //to allow for cube updating(should be removed)
    
    
    //SET UP SCENE
    override func didMove(to view: SKView) {
        
        //Create contact world
        self.physicsWorld.contactDelegate = self
        
        //SEE LINE 173 for Singelton Proof
        scoreSingeltonProof.value = 0
        
        //INitialize Labels
        lifeLabel = childNode(withName: "livesLabel") as? SKLabelNode!
        lifeLabel?.text = String(numLifes)
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode!
        scoreLabel?.text = String(scoreSingeltonProof.value)
        
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
                    
                    endGame()
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


        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "towertop" {
            NSLog("Player and TOP CONTACT")
            
            let towerY = (secondBody.node?.position.y)!
            let towerX = secondBody.node?.position.x
            
            spawnMiniCubes(towX: towerX!, towY: towerY)
            //hitTower == true
            //player.position = CGPoint(x: towerX!,y: towerY)
            numLifes += 1
            
        }
        
        
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "towertop" {
            NSLog("minicube and tower Conatact")
            
            let towerY = (secondBody.node?.position.y)! + 250
            let towerX = secondBody.node?.position.x
            
            spawnMiniCubes(towX: towerX!, towY: towerY)
            
        }
        
        
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "ground" {
            NSLog("minicube and ground Conatact")
            score.value += 1
            scoreLabel?.text = String(score.value)
            
        }
    }
    
    
    
    
    
    
    //Replace the cube
    override func update(_ currentTime: TimeInterval) {
        if let cubePhysicsBody = player.physicsBody {
            if cubePhysicsBody.velocity.dx <= 0.1 && cubePhysicsBody.velocity.dy <= 0.1 && cubePhysicsBody.angularVelocity <= 0.1 && hasGone && !hitTower {
                
                numLifes -= 1
                shotCounter += 1
                lifeLabel?.text = String(numLifes)
                if numLifes == 0 {
                    
                    endGame()
                }
                
                //FOR DIFICULTY
                
                if shotCounter % 2 == 0 {
                    self.removeChildren(in: [self.childNode(withName: "tower")!])
                    self.childNode(withName: "tower")
                }
                
                player.position = originalCubePos
                hasGone = false

                }
            }
        }
    
    
    
    //PRINT AND GO TO MAIN MENU
    func endGame(){
        
        gameOver_label =  childNode(withName: "GameOver") as? SKLabelNode!
        gameOver_label?.zPosition = 6
        finalScore_label =  childNode(withName: "FinalScore_label") as? SKLabelNode!
        finalScore_label?.zPosition = 6
        finalScore_score =  childNode(withName: "finalScore_score") as? SKLabelNode!
        finalScore_score?.text = String(score.value)
        finalScore_score?.zPosition = 6
        
        //PRINT GAME OVER
//        if let scene = MainMenu(fileNamed: "MainMenuScene"){
//
//            scene.scaleMode = .aspectFill
//            view?.presentScene(scene, transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(2)))
//        }
    }
    
    //Spawn Towers that will have the target
    func spawnTowers(){
        

        let numberOfTowers = numTowers * 2 + 1
        
        for _ in 1..<numberOfTowers {
            
        let tempTower:Tower = Tower()
        tempTower.position.x = randNumb(firstNum: CGFloat(640), secNum: CGFloat(-240))
        tempTower.position.y = -250;
        tempTower.size.height = randNumb(firstNum: CGFloat(700), secNum: CGFloat(250))
            
        //MOVE TO BUCKET CLASS
        towerTop = SKShapeNode(rectOf: CGSize(width: 4*tempTower.size.width, height: 3))
        towerTop.fillColor = .red
        towerTop.name = "towertop"
        towerTop.strokeColor = .clear
        towerTop.position = CGPoint(x: tempTower.position.x, y: tempTower.position.y+250)
        towerTop.zPosition = 10
        towerTop.alpha = 1
            
        towerTop.physicsBody = SKPhysicsBody(rectangleOf: towerTop.frame.size)
        towerTop.physicsBody? .categoryBitMask = ColliderType.TOWERTOP
        towerTop.physicsBody? .contactTestBitMask = ColliderType.PLAYER
        towerTop.physicsBody? .affectedByGravity = false
        towerTop.physicsBody? .isDynamic = false
        
        addChild(towerTop)
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
        
        //Adjusts Number of Cubes and Angular Velocity Upon Ejection
        let numberOfCubes = 3
        let xSpan = 10 //distance the minicubes will travel in the x direction
        let ySpan = 7.5 //distance the cubes will travel upward
        
        for _ in 1..<numberOfCubes {
            
            let tempMiniCube:MiniCube = MiniCube()
            tempMiniCube.position.x = towX
            tempMiniCube.position.y = towY
            
            addChild(tempMiniCube)
            let tempImpulse = CGVector(dx: randNumb(firstNum: CGFloat(-xSpan), secNum: CGFloat(xSpan)), dy: CGFloat(ySpan))
            tempMiniCube.physicsBody?.applyImpulse(tempImpulse)
            
        }
    }
    
    
    //Helper function returns random number
    func randNumb(firstNum: CGFloat, secNum: CGFloat)->CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secNum) + min(firstNum,secNum)
    }
    
}
    
    
    

