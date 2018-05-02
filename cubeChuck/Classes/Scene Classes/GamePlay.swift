//
//  GameScene.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 3/16/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

//THINGS TO TIGHTEN UP
//1) Bug: minicube can hit player =>may be fixed by playing on iphone or next bug fix
//2) Bug (Rare): Infinite minicube spawn=> fixed by Reduce the number of cubes that can spwan on each consecutive minicube towertop hit (reset it when player is tossed again
//3) Bug: Tile hits arent always detected => fixed with new smaller tile graphics
//5) Move Score Singelton in to player class
//6) Get rid of use of dificulty.numTowers and use local variables
//8) Make Bacground and tilemap move with towers so it looks like everything is moving
//9) Use better programing grammar(move bucket spawn in to bucket class)
//10) Make my own graphics

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

//Player needs to be global for now
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
    var highScore_label: SKLabelNode?
    var highScore_score: SKLabelNode?
    
    //Random Variables
    var pi = CGFloat(Double.pi)
    
    //Singeltons
    let score = Score.sharedInstance
    let scoreSingeltonProof = Score.sharedInstance
    let dificulty = Dificulty.sharedInstance
    
    //Factory Design Pattern
    var groundTiles: SKTileMapNode!
    
    //Limiters
    var hasGone = false  // to detect if cube has left
    var hitTower = false // to detect if a cube has hit a
    var originalCubePos: CGPoint! //to allow for cube updating(should be removed)
    var numberOfTowers = 0 //number of towers there are
    var levelNumber = 0 //to indicate the level we are on
    var spawnOutside = 1 //to indicate if this was the first toss or not
    var noMiniCubes = true//to indicate if there are any minicubes left on the screen
    
    
    
    
    
    
    //SET UP SCENE when this gamescene is presented
    override func didMove(to view: SKView) {
        
        //Create physics contact world
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
                    hitTower = false//we have not hit a tower if were touching the screen
                    hasGone = false//we have not fired the player yet
                }
                    
                    //BACK BUTTON
                else if atPoint(location).name == "back" {
                    
                    endGame()
                }
                    
                    //In case a glitch in the game where you loose the cube off the screen
                else if atPoint(location).name == "cubeReset" && hasGone{
                    
                    player.physicsBody?.isDynamic = false
                    cubeReset()
                    //self.removeChildren(in: [childNode(withName: "minicube")!])//remove all minicubes from map
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
                player.fire()//fire the player once the screen is released
                hasGone = true//the player has gone
                
            }
        }
    }
    
    
    
    
    
    
    
    
    //DETECTING COLLISIONS OF OBJECTS IN GAME
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();
        //let numberOfTowers = dificulty.numTowers
        
        //This is to detect what hits what first
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
        
        //Iterate through all the towers to check for a contact
        for i in 1..<dificulty.numTowers + levelNumber {
            
            if firstBody.node?.name == "Player" && secondBody.node?.name == "towertop\(i)" {
                //NSLog("Player and TOP CONTACT")
                
                spawnOutside = 2//after the first hit we can spawn towers outside screen so they move in to the screen during call to nextLevel()
                let towerY = (secondBody.node?.position.y)!
                let towerX = secondBody.node?.position.x
                
                hitStopper = towerX!//to mark where we hit a tower along the x axis
                
                //Remove the hit towers bucket so that it doesnt come in contact with the player again
                removeChildren(in: [self.childNode(withName: "towertop\(i)")!])
                removeChildren(in: [self.childNode(withName: "towerright\(i)")!])
                removeChildren(in: [self.childNode(withName: "towerleft\(i)")!])
                
                originalCubePos = player.position//to move the player after a missed shot
                player.physicsBody?.isDynamic = false//so the minicubes cant come in contact with the player
                
                spawnMiniCubes(towX: towerX!, towY: towerY)//spawn minicubes at the top of the tower
                self.spawnTowers()//spawn more towers for next level
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                    
                    //player.physicsBody?.affectedByGravity = false
                    //player.physicsBody?.isDynamic = true
                    
                })
                
                dificulty.numLifes += 1//gives player an extra live :)
                hitTower = true
                
            }
            
            if firstBody.node?.name == "minicube" && secondBody.node?.name == "towertop\(i)" {
                //NSLog("minicube and tower Conatact")
                noMiniCubes = false//mark that there are infact minicubes around
                
                removeChildren(in: [self.childNode(withName: "minicube")!])//in an effort to stop a bug where minicubes get caught in box and spawn infinetly
                
                //Spawn more minicubes!
                let towerY = (secondBody.node?.position.y)! + 20
                let towerX = secondBody.node?.position.x
                
                spawnMiniCubes(towX: towerX!, towY: towerY)
            }
            
            
        }
        
        //A minicube coming in contact with the ground determines the score of the game
        if firstBody.node?.name == "minicube" && secondBody.node?.name == "ground" {
            //NSLog("minicube and ground Conatact")
            //score.value += 1
            scoreLabel?.text = String(score.value)
            removeChildren(in: [self.childNode(withName: "minicube")!])//remove minicube once its contacted the ground
            
        }
    }
    
    
    
    
    
    
    
    
    //Is called every frame refresh
    //Handles when player missed the target, and when player hit the target, end of the game
    override func update(_ currentTime: TimeInterval) {
        
            //Detect a collision on a tile
            if let minicubePos = self.childNode(withName: "minicube")?.position {
                
                let column = groundTiles.tileColumnIndex(fromPosition: minicubePos)
                let row = groundTiles.tileRowIndex(fromPosition: minicubePos)
                let tile = groundTiles.tileDefinition(atColumn: column, row: row)
                
                if tile == nil {//if you havent hit a tile
                    
                    //do nothing
                } else {//youve hit a tile
                    
                    score.value += 1//increase score
                    groundTiles.setTileGroup(nil, forColumn: column, row: row)//render that space null
                }
                
            }
        
        if let cubePhysicsBody = player.physicsBody {
    
            //If player missed target (player has stoped moving and hitTower is false):
            if cubePhysicsBody.velocity.dx <= 0.1 && cubePhysicsBody.velocity.dy <= 0.1 && cubePhysicsBody.angularVelocity == 0.0 && hasGone && !hitTower {
                
                dificulty.numLifes -= 1//decrease number of lives
                shotCounter += 1
                lifeLabel?.text = String(dificulty.numLifes)//redisplay number of lives
                
                //If player has no more lives end the game
                if dificulty.numLifes == 0 {
                    
                    endGame()
                }
                
                player.physicsBody?.affectedByGravity = false//so that player doesnt fall out of sky when respawned
                player.position = originalCubePos//move the player back to position where he first shot from
                hasGone = false//
                
            }
            
            //If we have landed in a tower
            if cubePhysicsBody.velocity.dx <= 0.1 && cubePhysicsBody.velocity.dy <= 0.1 && cubePhysicsBody.angularVelocity == 0.0 && hasGone && hitTower {
                
                shotCounter += 1
                
                //Move the towers until the tower we hit is at the left of the screen
                if hitStopper > leftScreen {
                    
                    nextLevel()
                }
                    
                else {
                    //once the tower we hit is at the left of the screen we can shoot the player again and allow him to contact other objects
                    player.physicsBody?.affectedByGravity = false
                    player.physicsBody?.isDynamic = true
                    
                }
                
            }
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    //PRINT FINAL SCORE AND GO TO MAIN MENU
    func endGame(){
        
        saveHighscore(highscore: score.value)
        
        self.removeChildren(in: [self.childNode(withName: "Player")!])//remove all objects from teh scene
        
        //PRINT GAME OVER, Current Score and HighScore
        gameOver_label =  (childNode(withName: "GameOver") as? SKLabelNode?)!
        gameOver_label?.zPosition = 6
        finalScore_label =  (childNode(withName: "FinalScore_label") as? SKLabelNode?)!
        finalScore_label?.zPosition = 6
        finalScore_score =  (childNode(withName: "finalScore_score") as? SKLabelNode?)!
        finalScore_score?.text = String(score.value)
        finalScore_score?.zPosition = 6
        
        highScore_label =  (childNode(withName: "HighScore_label") as? SKLabelNode?)!
        highScore_label?.zPosition = 6
        highScore_score =  (childNode(withName: "highScore_score") as? SKLabelNode?)!
        if let currentHighscore:Int = UserDefaults.standard.value(forKey: "highscore") as? Int {
            
            highScore_score?.text = String(currentHighscore)
            highScore_score?.zPosition = 6
        }
        
        
        
        //Go to Main Menu Scene after displaying final score for 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            
            if let scene = MainMenu(fileNamed: "MainMenuScene"){
                
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene, transition: SKTransition.doorsCloseVertical(withDuration: TimeInterval(1)))
            }
        })
        
        
    }
    
    
    
    
    
    
    
    
    //SETS UP GAMPEPLAY
    func setupGame(){
        
        //SEE LINE 173 for Singelton Proof
        //Set singelton values
        scoreSingeltonProof.value = 0
        dificulty.numLifes = 10
        dificulty.numTowers = 4
        
        guard let groundTiles = childNode(withName: "groundTiles")
            as? SKTileMapNode else {
                fatalError("Background node not loaded")
        }
        self.groundTiles = groundTiles
        
        //INitialize Labels
        lifeLabel = (childNode(withName: "livesLabel") as? SKLabelNode?)!
        lifeLabel?.text = String(dificulty.numLifes)
        scoreLabel = (childNode(withName: "scoreLabel") as? SKLabelNode?)!
        scoreLabel?.text = String(scoreSingeltonProof.value)
        
        //Spawn towers and players
        spawnTowers()
        spawnPlayer()
    }
    
    
    
    
    
    //In case of a glitch in the game reset the cube back to its original position
    func cubeReset(){
        
        
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.position = originalCubePos
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //Moves the towers across the screen to the starting position again
    func nextLevel(){
        
        //let numberOfTowers = dificulty.numTowers
        
        //Move all towers and bucketsin the scene
        for i in 1..<numberOfTowers {
            
            let moveTower = self.childNode(withName: "tower\(i)")//recognize the towers
            let moveTop = self.childNode(withName: "towertop\(i)")
            let moveTopLeft = self.childNode(withName: "towerleft\(i)")
            let moveTopRight = self.childNode(withName: "towerright\(i)")
            moveTower?.position.x = (moveTower?.position.x)! - CGFloat(20)//move 20 pixels to the left
            moveTop?.position.x = (moveTop?.position.x)! - CGFloat(20)
            moveTopRight?.position.x = (moveTopRight?.position.x)! - CGFloat(20)
            moveTopLeft?.position.x = (moveTopLeft?.position.x)! - CGFloat(20)
            
        }
        
        player.position.x = player.position.x - CGFloat(20)//move player 20 pixels to the left
        player.physicsBody?.isDynamic = false//while towers are moving make sure player cant come in contact with anything
        hitStopper = hitStopper - CGFloat(20)//indicates how far we have moved
        originalCubePos = player.position//for moving the player on a missed toss
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    //Spawn Towers that will have the target
    func spawnTowers(){
        
        //Number of towers to spawn
        for i in 1..<dificulty.numTowers {
            
            //Spawn a Tower object randomly on map
            let tempTower:Tower = Tower()
            tempTower.name = "tower\(i+levelNumber)"//Use of level number to keep track of spawns after the first level (4,5,6, ...)
            //Spawn tower randomly between bounds 640 and -240 which are hardcoded positions on the screen
            tempTower.position.x = (randNumb(firstNum: CGFloat(640), secNum: CGFloat(-240))) * CGFloat(spawnOutside)
            tempTower.position.y = -250;
            tempTower.size.height = randNumb(firstNum: CGFloat(700), secNum: CGFloat(250))//randomly generate tower height
            
            //Spawn Bucket on top of each tower
            
            //Spawn bucket bottem
            towerTop = SKShapeNode(rectOf: CGSize(width: 4*tempTower.size.width, height: 3))//make size of bucket 4 times width of tower
            towerTop.fillColor = .red
            towerTop.name = "towertop\(i+levelNumber)"
            towerTop.strokeColor = .clear
            towerTop.position = CGPoint(x: tempTower.position.x, y: tempTower.position.y + tempTower.size.height/2)//position bucket bottem on top of tower
            towerTop.zPosition = 10//layer on screen
            towerTop.alpha = 1//togel visibility
            
            //Create the physics body of the tower
            towerTop.physicsBody = SKPhysicsBody(rectangleOf: towerTop.frame.size)//make the bounding box the size of the shape node
            towerTop.physicsBody? .categoryBitMask = ColliderType.TOWERTOP //to recognize a collision
            towerTop.physicsBody? .contactTestBitMask = ColliderType.PLAYER//to recognize a collision
            towerTop.physicsBody? .affectedByGravity = false
            towerTop.physicsBody? .isDynamic = false //doesnt move on contacts
            
            //Create left side of box
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
            
            //Create right side of box
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
            
            //Add children to the scene
            addChild(towerLeft)
            addChild(towerRight)
            addChild(towerTop)
            addChild(tempTower)
            
        }
        
        numberOfTowers = numberOfTowers + dificulty.numTowers
        levelNumber = levelNumber + (dificulty.numTowers - 1)//Increase the level number by how many towers you just spawned so that when your iterating through the towers you can hit towers (3,4,5,...)
        
        //Increase Dificulty as Game goes on
        //by decreasing the number of towers that can spawn
        if(levelNumber != 0 && levelNumber % 2 == 0 && dificulty.numTowers > 2){
            
            dificulty.numTowers = dificulty.numTowers - 1
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    //Spawn the player
    func spawnPlayer(){
        originalCubePos = player.position //For moving the player after a missed toss
        addChild(player)
    }
    
    
    
    
    
    
    
    
    
    //Spawn the minicubes on contact
    func spawnMiniCubes(towX: CGFloat, towY: CGFloat){
        
        noMiniCubes = false//indicating there are minicubes being shot
        
        //Adjusts Number of Cubes and Angular Velocity Upon Ejection
        let numberOfCubes = 3
        let xSpan = 13 //distance the minicubes will travel in the x direction
        let ySpan = 15 //distance the cubes will travel upward
        
        for _ in 1..<numberOfCubes+1 {
            
            //Spawn minicubes at hit tower
            let tempMiniCube:MiniCube = MiniCube()
            tempMiniCube.name = "minicube"
            tempMiniCube.position.x = towX
            tempMiniCube.position.y = towY
            
            addChild(tempMiniCube)
            //Apply Shooting to Minicubes
            let tempImpulse = CGVector(dx: randNumb(firstNum: CGFloat(-xSpan), secNum: CGFloat(xSpan)), dy: CGFloat(ySpan))
            tempMiniCube.physicsBody?.applyImpulse(tempImpulse)
            
        }
        
        //Indicate there are no minicubes left three seconds after they have launched (the aproximate max time it takes for them to hit the ground)
        //This will insure that the player will not be shoved by a minicube
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {

            self.noMiniCubes = true

        })
        
    }
    
    
    
    
    func saveHighscore(highscore:Int){
        
        //Check if there is already a highscore
        if let currentHighscore:Int = UserDefaults.standard.value(forKey: "highscore") as? Int{
            //If the new highscore is higher then the current highscore, save it.
            if(highscore > currentHighscore){
                UserDefaults.standard.setValue(highscore, forKey: "highscore")
            }
        }else{
            //If there isn't a highscore set yet, every highscore is higher then nothing. So add it.
            UserDefaults.standard.setValue(highscore, forKey: "highscore")
        }
    }
    

    
    
    
    
    
    //Helper function returns random number
    func randNumb(firstNum: CGFloat, secNum: CGFloat)->CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secNum) + min(firstNum,secNum)
    }
    
    
    
    
    
    
    
    
}




