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
}

//***Touch***//
struct tch { //start and end touch points
    
    static var start = CGPoint()//has x and y cordinates
    static var end = CGPoint()
}

var numTowers = 2
let player:Player = Player()

class GamePlay: SKScene, SKPhysicsContactDelegate {
    
    //Player and Tower Objects
//    private var spawnContoller = SpawnItems()
//    private var player : Player?
    
    //(Temp Cube Object)
    var cube: SKSpriteNode!
    
    //LABELS
    var lifeLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    
    //Variables
    var pi = CGFloat(Double.pi)
    var numLifes = 3//number of lives the player has (should be moved to player class)
    var score = 1
    var hasGone = false  // to detect if cube has left (should be removed)
    var originalCubePos: CGPoint! //to allow for cube updating(should be removed)
    
    
    
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        lifeLabel = childNode(withName: "livesLabel") as? SKLabelNode!
        lifeLabel?.text = String(numLifes)
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode!
        scoreLabel?.text = String(score)
        
        //Create Game Enviroment
        //setupGame();
        spawnTowers()
        spawnPlayer()
        //let tempVec = CGVector(dx: 50, dy: 50)
        //player.physicsBody?.applyImpulse(tempVec)
    }
    
    
    
    
    //REGISTER A TOUCH ON THE SCREEN
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            //IF WE TOUCH THE CUBE
            if GameState.current == .playing {

//                if cube.contains(location){
//
//                    tch.start = location
//                }
//
                if player.contains(location){

                    tch.start = location
                }
            
                //BACK BUTTON
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
    
    
    
    
    //REGISTER END TOUCH ON THE SCREEN
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if GameState.current == .playing && !player.contains(location) {

                tch.end = location
                firePlayer()
                //player?.fire(tchStrt: tch.start,tchEnd: tch.end);
                hasGone = true


            }
        }
    }
    
    
    //DETECTING COLLISION
    func didBegin(_ contact: SKPhysicsContact) {

        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();
        //var thirdBody = SKPhysicsBody();

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
            
            
            //lifeLabel?.text = String(numLifes)

        }
        
        
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "tower" {
            NSLog("minicube and tower Conatact")
            
            let towerY = (secondBody.node?.position.y)! + 250
            let towerX = secondBody.node?.position.x
            
            spawnMiniCubes(towX: towerX!, towY: towerY)
            
            
            //lifeLabel?.text = String(numLifes)
            
        }
        
        
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "ground" {
            NSLog("minicube and ground Conatact")
            score += 1
            scoreLabel?.text = String(score)
            
            
        }
        
        
       
        
        
    }
    
    
    
    
    
    
    //SETUP GAME ENVIROMENT
//    private func setupGame (){
//
//        //cube.removeFromParent()
//
//        //Gamestate
//        GameState.current = .playing;
//
//        lifeLabel = childNode(withName: "livesLabel") as? SKLabelNode!
//        lifeLabel?.text = String(numLifes)
//
//
//        physicsWorld.contactDelegate = self;
//
//        //Create Playing Cube for the first time
//        cube = childNode(withName: "cube") as! SKSpriteNode
//        //cube.name = "Player"
//        originalCubePos = cube.position
//        cube.physicsBody?.categoryBitMask = ColliderType.PLAYER
//
//        //Sets a physics bound around the frame of the iphone
//        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
//
//        //ABSTRACTED PLAYER CLASS is bugging running it within gamescene for now
//        //player = childNode(withName: "cube") as? Player!
//        //player?.initPlayer();
//
//
//        spawnTowers();
//        spawnTowers();
//        spawnTowers();
//    }
    
    
    
    
    
    //FIRE THE CUBE
    func firePlayer(){
        
        let xChange = tch.end.x - tch.start.x
        let yChange = (tch.end.y -  tch.start.y)/5
        
        let angle = (atan(xChange / (tch.end.y - tch.start.y)) * 180 / pi)
        //Because we limit the yvalue of our toss we need to account for that in our x
        let ammendedX = (tan(angle * pi / 180) * yChange) * 0.5 //Play with this
        
        //Throw Cube
        let throwVec = CGVector(dx: ammendedX, dy: yChange)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.applyImpulse(throwVec, at: tch.start)
    }
    
    
    
    
    
    //SPAWNS RANDOM TOWERS
//    func spawnTowers(){
//
////        let itemOne: SKSpriteNode?;
////        itemOne = spawnContoller.spawnItems().0
////        let itemTwo: SKSpriteNode?;
////        itemTwo = spawnContoller.spawnItems().1
////        self.scene?.addChild(itemOne!)
////        self.scene?.addChild(itemTwo!)
//          self.scene?.addChild(spawnContoller.spawnItems())
//
//    }
    
    
    
    
    
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
                //setupGame()
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
    
    
    
    
    
    func spawnPlayer(){
        originalCubePos = player.position
        addChild(player)
    }
    
    
    
    
    
    
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
    
    func randNumb(firstNum: CGFloat, secNum: CGFloat)->CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secNum) + min(firstNum,secNum)
    }
    
}
    
    
    

