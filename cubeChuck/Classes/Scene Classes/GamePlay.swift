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
//Indicates if we are currently playing the game
enum GameState {

    case playing
    case menu
    case setting
    static var current = GameState.playing
}

//***ColliderType***//
//Used to detect what object hit what
struct ColliderType {
    
    static let PLAYER: UInt32 = 0;
    static let TOWER: UInt32 = 1;
    static let MINICUBE: UInt32 = 2;
    static let TOWERTOP: UInt32 = 3
}

//***Touch***//
//used to mark start and end of users touch on screen
struct tch {
    
    static var start = CGPoint()//has x and y cordinates
    static var end = CGPoint()
}

//Player Needs to be global for now
let player:Player = Player()

//Global limit variables need to be hard coded due to screen size
let leftScreen = CGFloat(-620)
var hitStopper = CGFloat()


class GamePlay: SKScene, SKPhysicsContactDelegate {
    
    
    //Gameplay variables
    
    var towerTop = SKShapeNode()
    var towerLeft = SKShapeNode()
    var towerRight = SKShapeNode()
    var shotCounter = 0
    
    //LABELS
    var lifeLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    var gameOver_label: SKLabelNode?
    var finalScore_label: SKLabelNode?
    var finalScore_score: SKLabelNode?
    
    //Random Variables
    var pi = CGFloat(Double.pi)
    
    //Singeltons
    let score = Score.sharedInstance
    let scoreSingeltonProof = Score.sharedInstance
    let dificulty = Dificulty.sharedInstance
    
    var hasGone = false  // to detect if cube has left
    var hitTower = false // to detect if a cube has hit a
    var originalCubePos: CGPoint! //to allow for cube updating(should be removed)
    var numberOfTowers = 0
    var levelNumber = 0
    var spawnOutside = 1
    
    
    
    
    
    
    //SET UP SCENE
    override func didMove(to view: SKView) {
        
        //Create contact world
        self.physicsWorld.contactDelegate = self
        
       setupGame()
    }
    
    
    
    
    
    
    
    
    
    //REGISTER A TOUCH ON THE SCREEN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            //IF WE TOUCH THE CUBE
            if GameState.current == .playing {
                
                if player.contains(location){
                    
                    tch.start = location
                    hitTower = false
                    hasGone = false
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
        //let numberOfTowers = dificulty.numTowers
        
        //This is to detect what hits what
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "ground" {
            //NSLog("Player and ground Conatact")
            
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "tower" {
            //NSLog("Player and tower Conatact")
            
            
        }
        
        for i in 1..<dificulty.numTowers + levelNumber {
            
            if firstBody.node?.name == "Player" && secondBody.node?.name == "towertop\(i)" {
                //NSLog("Player and TOP CONTACT")
                
                spawnOutside = 2
                let towerY = (secondBody.node?.position.y)!
                let towerX = secondBody.node?.position.x
                
                hitStopper = towerX!
                
                removeChildren(in: [self.childNode(withName: "towertop\(i)")!])
                removeChildren(in: [self.childNode(withName: "towerright\(i)")!])
                removeChildren(in: [self.childNode(withName: "towerleft\(i)")!])
                
                originalCubePos = player.position
                player.physicsBody?.isDynamic = false
                
                spawnMiniCubes(towX: towerX!, towY: towerY)
                self.spawnTowers()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                    
                    player.physicsBody?.affectedByGravity = false
                    player.physicsBody?.isDynamic = true
                    
                })

                dificulty.numLifes += 1
                hitTower = true
                
            }
            
            if firstBody.node?.name == "minicube" && secondBody.node?.name == "towertop\(i)" {
                //NSLog("minicube and tower Conatact")
                
                removeChildren(in: [self.childNode(withName: "minicube")!])
                let towerY = (secondBody.node?.position.y)! + 20
                let towerX = secondBody.node?.position.x
                
                spawnMiniCubes(towX: towerX!, towY: towerY)
            }
            
            
        }
        
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "ground" {
            //NSLog("minicube and ground Conatact")
            score.value += 1
            scoreLabel?.text = String(score.value)
            removeChildren(in: [self.childNode(withName: "minicube")!])
            
            
        }
    }
    
    
    
    
    
    
    
    
    //Replace the cube
    override func update(_ currentTime: TimeInterval) {
        
        if let cubePhysicsBody = player.physicsBody {
            
            //If we have missed
            if cubePhysicsBody.velocity.dx <= 0.1 && cubePhysicsBody.velocity.dy <= 0.1 && cubePhysicsBody.angularVelocity == 0.0 && hasGone && !hitTower {
                
                dificulty.numLifes -= 1
                shotCounter += 1
                lifeLabel?.text = String(dificulty.numLifes)
                
                if dificulty.numLifes == 0 {
                    
                    endGame()
                }
                
                
                player.physicsBody?.affectedByGravity = false
                player.position = originalCubePos
                hasGone = false
                
            }
            
            //If we have landed in a tower
            if cubePhysicsBody.velocity.dx <= 0.1 && cubePhysicsBody.velocity.dy <= 0.1 && cubePhysicsBody.angularVelocity == 0.0 && hasGone && hitTower {
                
                shotCounter += 1
                //hasGone = false
                
                if hitStopper > leftScreen {
                        
                    nextLevel()
                }
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    //PRINT AND GO TO MAIN MENU
    func endGame(){
        
        self.removeChildren(in: [self.childNode(withName: "Player")!])
        
        //PRINT GAME OVER
        gameOver_label =  (childNode(withName: "GameOver") as? SKLabelNode?)!
        gameOver_label?.zPosition = 6
        finalScore_label =  (childNode(withName: "FinalScore_label") as? SKLabelNode?)!
        finalScore_label?.zPosition = 6
        finalScore_score =  (childNode(withName: "finalScore_score") as? SKLabelNode?)!
        finalScore_score?.text = String(score.value)
        finalScore_score?.zPosition = 6
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            
            if let scene = MainMenu(fileNamed: "MainMenuScene"){
                
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(1)))
            }
        })
        //Go to Main Menu Scene
        
    }
    
    
    
    
    
    
    
    
    
    func setupGame(){
        
        //SEE LINE 173 for Singelton Proof
        scoreSingeltonProof.value = 0
        dificulty.numLifes = 10
        dificulty.numTowers = 4
        
        //INitialize Labels
        lifeLabel = (childNode(withName: "livesLabel") as? SKLabelNode?)!
        lifeLabel?.text = String(dificulty.numLifes)
        scoreLabel = (childNode(withName: "scoreLabel") as? SKLabelNode?)!
        scoreLabel?.text = String(scoreSingeltonProof.value)
        
        //Spawn towers and players
        spawnTowers()
        spawnPlayer()
    }
    
    
    
    
    
    
    
    
    
    
    
    func nextLevel(){
        
        //let numberOfTowers = dificulty.numTowers
        
        for i in 1..<numberOfTowers {
            
            let moveTower = self.childNode(withName: "tower\(i)")
            let moveTop = self.childNode(withName: "towertop\(i)")
            let moveTopLeft = self.childNode(withName: "towerleft\(i)")
            let moveTopRight = self.childNode(withName: "towerright\(i)")
            moveTower?.position.x = (moveTower?.position.x)! - CGFloat(20)
            moveTop?.position.x = (moveTop?.position.x)! - CGFloat(20)
            moveTopRight?.position.x = (moveTopRight?.position.x)! - CGFloat(20)
            moveTopLeft?.position.x = (moveTopLeft?.position.x)! - CGFloat(20)
            
        }
        
        player.position.x = player.position.x - CGFloat(20)
        hitStopper = hitStopper - CGFloat(20)
        originalCubePos = player.position
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //Spawn Towers that will have the target
    func spawnTowers(){
        
        for i in 1..<dificulty.numTowers {
            
            let tempTower:Tower = Tower()
            tempTower.name = "tower\(i+levelNumber)"
            tempTower.position.x = (randNumb(firstNum: CGFloat(640), secNum: CGFloat(-240))) * CGFloat(spawnOutside)
            tempTower.position.y = -250;
            tempTower.size.height = randNumb(firstNum: CGFloat(700), secNum: CGFloat(250))
            
            //MOVE TO BUCKET CLASS
            towerTop = SKShapeNode(rectOf: CGSize(width: 4*tempTower.size.width, height: 3))
            towerTop.fillColor = .red
            towerTop.name = "towertop\(i+levelNumber)"
            towerTop.strokeColor = .clear
            towerTop.position = CGPoint(x: tempTower.position.x, y: tempTower.position.y + tempTower.size.height/2)
            towerTop.zPosition = 10
            towerTop.alpha = 1
            
            towerTop.physicsBody = SKPhysicsBody(rectangleOf: towerTop.frame.size)
            towerTop.physicsBody? .categoryBitMask = ColliderType.TOWERTOP
            towerTop.physicsBody? .contactTestBitMask = ColliderType.PLAYER
            towerTop.physicsBody? .affectedByGravity = false
            towerTop.physicsBody? .isDynamic = false
            
            towerLeft = SKShapeNode(rectOf: CGSize(width: 3, height: towerTop.frame.size.width/2))
            towerLeft.fillColor = .red
            towerLeft.name = "towerleft\(i+levelNumber)"
            towerLeft.strokeColor = .clear
            towerLeft.position = CGPoint(x: towerTop.position.x - towerTop.frame.size.width/2, y: towerTop.position.y + towerLeft.frame.size.height/2)
            towerLeft.zPosition = 10
            towerLeft.alpha = 1 //do we want to see grids or not
            
            towerLeft.physicsBody = SKPhysicsBody(rectangleOf: towerLeft.frame.size)
            towerLeft.physicsBody? .categoryBitMask = ColliderType.TOWER
            towerLeft.physicsBody? .collisionBitMask = ColliderType.PLAYER
            towerLeft.physicsBody? .affectedByGravity = false
            towerLeft.physicsBody? .isDynamic = false
            towerLeft.zRotation = pi / 70
            
            towerRight.physicsBody = SKPhysicsBody(rectangleOf: towerRight.frame.size)
            towerRight.physicsBody? .categoryBitMask = ColliderType.TOWER
            towerRight.physicsBody? .contactTestBitMask = ColliderType.PLAYER
            towerRight.physicsBody? .affectedByGravity = false
            towerRight.physicsBody? .isDynamic = false
            towerRight.zRotation = -pi / 70
            
            towerRight = SKShapeNode(rectOf: CGSize(width: 3, height: towerTop.frame.size.width/2))
            towerRight.fillColor = .red
            towerRight.name = "towerright\(i+levelNumber)"
            towerRight.strokeColor = .clear
            towerRight.position = CGPoint(x: towerTop.position.x + towerTop.frame.size.width/2, y: towerTop.position.y + towerRight.frame.size.height/2)
            towerRight.zPosition = 10
            towerRight.alpha = 1 //do we want to see grids or not
            
            
            addChild(towerLeft)
            addChild(towerRight)
            addChild(towerTop)
            addChild(tempTower)
            
        }
        
        numberOfTowers = numberOfTowers + dificulty.numTowers
        levelNumber = levelNumber + (dificulty.numTowers - 1)
        
        //Increase Dificulty as Game goes on
        //by decreasing the number of towers that can spawn
        if(levelNumber != 0 && levelNumber % 2 == 0 && dificulty.numTowers > 2){
            
            dificulty.numTowers = dificulty.numTowers - 1
            
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
        let xSpan = 13 //distance the minicubes will travel in the x direction
        let ySpan = 15 //distance the cubes will travel upward
        
        for _ in 1..<numberOfCubes+1 {
            
            //Spawn minicubes at hit tower
            let tempMiniCube:MiniCube = MiniCube()
            tempMiniCube.position.x = towX
            tempMiniCube.position.y = towY
            
            addChild(tempMiniCube)
            //Apply Shooting to Minicubes
            let tempImpulse = CGVector(dx: randNumb(firstNum: CGFloat(-xSpan), secNum: CGFloat(xSpan)), dy: CGFloat(ySpan))
            tempMiniCube.physicsBody?.applyImpulse(tempImpulse)
            
        }
    }
    
    
    
    
    
    
    
    
    
    //Helper function returns random number
    func randNumb(firstNum: CGFloat, secNum: CGFloat)->CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secNum) + min(firstNum,secNum)
    }
    
    
    
    
    
    
    
    
}




