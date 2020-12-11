//
//  GameViewController.swift
//  Marble Maze
//
//  Created by Igor Ivanov on 11.12.2020.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    var scnView:SCNView!
    var scnScene:SCNScene!
    var ballNode:SCNNode!
    var game = GameHelper.sharedInstance
    var motion = CoreMotionHelper()
    var motionForce = SCNVector3(x:0 , y:0, z:0)
    var cameraNode:SCNNode!
    var cameraFollowNode:SCNNode!
    var lightFollowNode:SCNNode!
    
    let CollisionCategoryBall = 1
    let CollisionCategoryStone = 2
    let CollisionCategoryPillar = 4
    let CollisionCategoryCrate = 8
    let CollisionCategoryPearl = 16
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupNodes()
        setupSounds()
        resetGame()
        scnView.isPlaying = true
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupScene(){
        scnView = self.view as! SCNView
        scnView.delegate = self
        scnView.showsStatistics = false
        scnScene = SCNScene(named: "art.scnassets/game.scn")
        scnView.scene = scnScene
        scnScene.physicsWorld.contactDelegate = self
        scnView.allowsCameraControl = false
    }
    
    func setupNodes(){
        ballNode = scnScene.rootNode.childNode(withName: "ball", recursively: true)!
        ballNode.physicsBody!.contactTestBitMask = CollisionCategoryPillar | CollisionCategoryCrate | CollisionCategoryPearl
        
        cameraNode = scnScene.rootNode.childNode(withName: "dcamera", recursively: true)!
        let constraint = SCNLookAtConstraint(target: ballNode)
        cameraNode.constraints = [constraint]
        constraint.isGimbalLockEnabled = true
        cameraFollowNode = scnScene.rootNode.childNode(withName: "follow_camera", recursively: true)!
        game.state = GameStateType.tapToPlay
        game.hudNode.position = SCNVector3(x: 0, y: 0.7, z: -2)
        cameraNode.addChildNode(game.hudNode)
        lightFollowNode = scnScene.rootNode.childNode(withName: "follow_light", recursively: true)!
    }
    
    func setupSounds(){
        game.loadSound(name: "GameOver", fileNamed: "GameOver.wav")
        game.loadSound(name: "Powerup", fileNamed: "Powerup.wav")
        game.loadSound(name: "Reset", fileNamed: "Reset.wav")
        game.loadSound(name: "Bump", fileNamed: "Bump.wav")
    }
}


extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer,updateAtTime time: TimeInterval) {
       
        updateHUD()
        if game.state == GameStateType.playing {
            updateMotionControl()
            updateCameraAndLights()
           
            testForGameOver()
           // diminishLife()
        }
    }
}


//MARK:- Game Flow
extension GameViewController {
    
    func playGame() {
        game.state = GameStateType.playing
        cameraFollowNode.eulerAngles.y = 0
        cameraFollowNode.position = SCNVector3Zero
        replenishLife()
    }
    
    func resetGame() {
        game.state = GameStateType.tapToPlay
       // game.playSound(node: ballNode, name: "Reset")
        ballNode.physicsBody?.velocity = SCNVector3Zero
        ballNode.position = SCNVector3(x:0, y:2, z:0)
        cameraFollowNode.position = ballNode.position
        lightFollowNode.position = ballNode.position
       // scnView.isPlaying = true
        game.reset()
    }
    
    
    func testForGameOver() {
        
        if ballNode.presentation.position.y < -40 {
            game.state = GameStateType.gameOver
         //   game.playSound(node: ballNode, name: "GameOver")
         //   self.resetGame()
            ballNode.runAction(SCNAction.waitForDurationThenRunBlock( duration: 2) {
                                (node:SCNNode!) -> Void in
                                self.resetGame() })
        }
        
    }
}




extension GameViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == GameStateType.tapToPlay {
            playGame()
        } }
}


extension GameViewController {
    func updateCameraAndLights() {
        let lerpX = (ballNode.presentation.position.x - cameraFollowNode.position.x) * 0.01
        let lerpY = (ballNode.presentation.position.y - cameraFollowNode.position.y) * 0.01
        let lerpZ = (ballNode.presentation.position.z - cameraFollowNode.position.z) * 0.01
        cameraFollowNode.position.x += lerpX
        cameraFollowNode.position.y += lerpY
        cameraFollowNode.position.z += lerpZ
        lightFollowNode.position = cameraFollowNode.position
        if game.state == GameStateType.tapToPlay {
            cameraFollowNode.eulerAngles.y += 0.005
        }
    }
    
    func updateMotionControl() {
        if game.state == GameStateType.playing {
            motion.getAccelerometerData(interval: 0.1) { (x,y,z) in
                self.motionForce = SCNVector3(x: Float(x) * 0.05, y:0, z: Float(y+0.8) * -0.05) }
        }
        ballNode.physicsBody!.velocity += motionForce
    }
    
    func updateHUD() {
        switch game.state {
        case .playing:
            game.updateHUD()
        case .gameOver:
            game.updateHUD(s: "👾👾👾👾👾 Ты Проиграл 👾👾👾👾👾👾")
        case .tapToPlay:
            game.updateHUD(s: "Нажми чтобы начать 🚀🚀🚀") }
    }
}



//MARK:- Collision Detection
extension GameViewController : SCNPhysicsContactDelegate {
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode:SCNNode!
        
        if contact.nodeA.name == "ball" {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPearl {
            contactNode.isHidden = true
            replenishLife()
            contactNode.runAction(
                SCNAction.waitForDurationThenRunBlock(duration: 30) { (node:SCNNode!) -> Void in
                    node.isHidden = false
                    
                })
        }
        
        if contactNode.physicsBody?.categoryBitMask == CollisionCategoryPillar ||
            contactNode.physicsBody?.categoryBitMask == CollisionCategoryCrate {
            game.playSound(node: ballNode, name: "Bump")
        }
    }
    
    
    func replenishLife() {
        let material = ballNode.geometry!.firstMaterial!
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        material.emission.intensity = 1.0
        SCNTransaction.commit()
        game.score += 1
        
        game.playSound(node: ballNode, name: "art.scnassets/Money.mp3")
    }
    
    func diminishLife() {
        let material = ballNode.geometry!.firstMaterial!
        if material.emission.intensity > 0 {
            material.emission.intensity -= 0.001
        } else {
            resetGame()
        }
    }
    
}
