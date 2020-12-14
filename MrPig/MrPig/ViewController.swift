//
//  ViewController.swift
//  MrPig
//
//  Created by Igor Ivanov on 12.12.2020.
//

import UIKit
import SceneKit
import SpriteKit

class ViewController: UIViewController {
    
    let game = GameHelper.sharedInstance
    var scnView: SCNView!
    var gameScene: SCNScene!
    var splashScene: SCNScene!
    var pigNode: SCNNode!
    var cameraNode: SCNNode!
    var cameraFollowNode: SCNNode!
    var lightFollowNode: SCNNode!
    var trafficNode: SCNNode!
    
    var driveLeftAction: SCNAction!
    var driveRightAction: SCNAction!
    
    var jumpLeftAction: SCNAction!
    var jumpRightAction: SCNAction!
    var jumpForwardAction: SCNAction!
    var jumpBackwardAction: SCNAction!
    
    var triggerGameOver: SCNAction!
    
    
    //Collisions:
    var collisionNode: SCNNode!
    var frontCollisionNode: SCNNode!
    var backCollisionNode: SCNNode!
    var leftCollisionNode: SCNNode!
    var rightCollisionNode: SCNNode!
    
    let BitMaskPig = 1
    let BitMaskVehicle = 2
    let BitMaskObstacle = 4
    let BitMaskFront = 8
    let BitMaskBack = 16
    let BitMaskLeft = 32
    let BitMaskRight = 64
    let BitMaskCoin = 128
    let BitMaskHouse = 256
    var activeCollisionsBitMask: Int = 0
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScenes()
        setupNodes()
        setupCollisionNodes()
        setupPigActions()
        setupTriggerGameOver()
        setupTraffic()
        setupGestures()
        setupSounds()
    }
    
    
    func setupScenes() {
        scnView = SCNView(frame: self.view.frame)
        self.view.addSubview(scnView)
        scnView.delegate = self
        gameScene = SCNScene(named: "/MrPig.scnassets/GameScene.scn")
        splashScene = SCNScene(named: "/MrPig.scnassets/SplashScene.scn")
        scnView.scene = splashScene
        gameScene.physicsWorld.contactDelegate = self
        scnView.isPlaying = true
    }
    
    func setupNodes() {
        pigNode = gameScene.rootNode.childNode(withName: "MrPig", recursively: true)!
        cameraNode = gameScene.rootNode.childNode(withName: "camera", recursively: true)!
        cameraNode.addChildNode(game.hudNode)
        cameraFollowNode = gameScene.rootNode.childNode(withName: "FollowCamera", recursively: true)!
        lightFollowNode = gameScene.rootNode.childNode(withName: "FollowLight", recursively: true)!
        trafficNode = gameScene.rootNode.childNode(withName: "Traffic", recursively: true)!
    }
    
    
    func setupTraffic() {
        driveLeftAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(-2.0, 0, 0), duration: 1.0))
        driveRightAction = SCNAction.repeatForever(SCNAction.move(by: SCNVector3Make(2.0, 0, 0), duration: 1.0))
        
        for node in trafficNode.childNodes {
            if node.name?.contains("Bus") == true {
                driveLeftAction.speed = 1.0
                driveRightAction.speed = 1.0
            } else {
                driveLeftAction.speed = 2.0
                driveRightAction.speed = 2.0
            }
            
            if node.eulerAngles.y > 0 {
                node.runAction(driveLeftAction)
            } else {
                node.runAction(driveRightAction)
            }
        }
    }
    
    func setupSounds() { }
    
    override var prefersStatusBarHidden : Bool { return true }
    
    override var shouldAutorotate : Bool { return false }
}



//MARK:- Renderer
extension ViewController : SCNSceneRendererDelegate {
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        guard game.state == .playing else { return }
        game.updateHUD()
        updatePositions()
        updateCamera()
    }
}



//MARK:- Pig Action
extension ViewController {
    
    func setupPigActions() {
        
        let duration = 0.2
        
        // Bounce:
        let bounceUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: duration * 0.5)
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        
        
        // Moving:
        let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: duration)
        let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: duration)
        let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration: duration)
        let moveBackwardAction = SCNAction.moveBy(x: 0, y: 0, z: 1.0, duration: duration)
        
        let turnLeftAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: -90), z: 0, duration: duration, usesShortestUnitArc: true)
        
        let turnRightAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 90), z: 0, duration: duration, usesShortestUnitArc: true)
        
        let turnForwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 180),z: 0, duration: duration, usesShortestUnitArc: true)
        
        let turnBackwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 0), z: 0, duration: duration, usesShortestUnitArc: true)
        
        
        jumpLeftAction = SCNAction.group([turnLeftAction, bounceAction, moveLeftAction])
        
        jumpRightAction = SCNAction.group([turnRightAction, bounceAction, moveRightAction])
        
        jumpForwardAction = SCNAction.group([turnForwardAction, bounceAction, moveForwardAction])
        
        jumpBackwardAction = SCNAction.group([turnBackwardAction, bounceAction, moveBackwardAction])
        
    }
    
}



//MARK:- Camera
extension ViewController  {
    func updateCamera() {
        let lerpX = (pigNode.position.x - cameraFollowNode.position.x) * 0.05
        let lerpZ = (pigNode.position.z - cameraFollowNode.position.z) * 0.05
        cameraFollowNode.position.x += lerpX
        cameraFollowNode.position.z += lerpZ
    }
}



//MARK:- Collision
extension ViewController : SCNPhysicsContactDelegate {
    
    func setupCollisionNodes(){
        collisionNode = gameScene.rootNode.childNode(withName: "Collision", recursively: true)!
        frontCollisionNode = gameScene.rootNode.childNode(withName: "Front", recursively: true)!
        backCollisionNode = gameScene.rootNode.childNode(withName: "Back", recursively: true)!
        leftCollisionNode = gameScene.rootNode.childNode(withName: "Left", recursively: true)!
        rightCollisionNode = gameScene.rootNode.childNode(withName: "Right", recursively: true)!
        
        pigNode.physicsBody?.contactTestBitMask = BitMaskVehicle | BitMaskCoin | BitMaskHouse
        frontCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        backCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        leftCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
        rightCollisionNode.physicsBody?.contactTestBitMask = BitMaskObstacle
    }
    
    
    
    func updatePositions() {
        collisionNode.position = pigNode.position
    }
    
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard game.state == .playing else { return }
        
        
        // check Obstacles:::
//        var collisionBoxNode: SCNNode!
//        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
//            collisionBoxNode = contact.nodeB
//        } else {
//            collisionBoxNode = contact.nodeA
//        }
//        //bitwise OR operation to add the colliding box’s category bit mask to activeCollisionsBitMask
//        activeCollisionsBitMask |= collisionBoxNode.physicsBody!.categoryBitMask
//
//
        
        // check Vehicles:::
        var contactNode: SCNNode!
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskPig {
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeA
        }
        
        if contactNode.physicsBody?.categoryBitMask == BitMaskVehicle {
            stopGame()
        }
        
        // check Coins:::
        if contactNode.physicsBody?.categoryBitMask == BitMaskCoin {
            contactNode.isHidden = true
            contactNode.runAction(SCNAction.waitForDurationThenRunBlock(duration: 60) { (node: SCNNode!) -> Void in
                node.isHidden = false
            })
            game.collectCoin()
        }
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard game.state == .playing else { return }
        
        var collisionBoxNode: SCNNode!
        
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskObstacle {
            collisionBoxNode = contact.nodeB
        } else {
            collisionBoxNode = contact.nodeA
        }
        //bitwise NOT operation followed by a bitwise AND operation to remove the collision box category bit mask from the activeCollisionsBitMask
        activeCollisionsBitMask &= ~collisionBoxNode.physicsBody!.categoryBitMask
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if pigNode != nil {
            let axisVector:SCNVector3 = SCNVector3Make(1,0,1)
            let contacts = scene.physicsWorld.contactTest(with: pigNode.physicsBody!, options: nil)
            for contact in contacts {
                let cn = SCNVector3( round(contact.contactNormal.x),
                                     round(contact.contactNormal.y),
                                     round(contact.contactNormal.z))
                if abs(cn.x) == axisVector.x || abs(cn.z)==axisVector.z  {
                    let normal = contact.contactNormal
                    let transform = SCNMatrix4MakeTranslation( round(normal.x) * 3*Float(contact.penetrationDistance),
                                                               0,//round(normal.y) * Float(contact.penetrationDistance),
                                                               round(normal.z) * 3*Float(contact.penetrationDistance))
                    pigNode.transform = SCNMatrix4Mult(pigNode.transform, transform)
                    if pigNode.position.y > 0 {
                        pigNode.removeAllActions()
                        let bounceUpAction = SCNAction.move(to: SCNVector3(pigNode.position.x, 1, pigNode.position.z), duration: 0.25)
                        let bounceDownAction = SCNAction.move(to: SCNVector3(pigNode.position.x, 0, pigNode.position.z), duration: 0.25)
                        let jumpAction = SCNAction.group([bounceUpAction, bounceDownAction])
                        pigNode.runAction(jumpAction)
                    }
                    // break to prevent repeated contacts
                    break;
                }
            }
        }
    }
    
}


//MARK:- Flow
extension ViewController {
    
    func startGame() {
        splashScene.isPaused = true
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        scnView.present(gameScene, with: transition, incomingPointOfView: nil, completionHandler: {
            self.game.state = .playing
            self.setupSounds()
            self.gameScene.isPaused = false
        })
    }
    
    
    func stopGame() {
        game.state = .gameOver
        game.reset()
        pigNode.runAction(triggerGameOver)
    }
    
    
    func startSplash() {
        gameScene.isPaused = true
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        scnView.present(splashScene, with: transition, incomingPointOfView: nil, completionHandler: {
            self.game.state = .tapToPlay
            self.setupSounds()
            self.splashScene.isPaused = false
        })
    }
    
    
    func setupTriggerGameOver() {
        let spinAround = SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 720), z: 0, duration: 2.0)
        let riseUp = SCNAction.moveBy(x: 0, y: 10, z: 0, duration: 2.0)
        let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 2.0)
        let goodByePig = SCNAction.group([spinAround, riseUp, fadeOut])
        
        let gameOver = SCNAction.run { (node:SCNNode) -> Void in
            self.pigNode.position = SCNVector3(x:0, y:0, z:0)
            self.pigNode.opacity = 1.0
            self.startSplash()
        }
        triggerGameOver = SCNAction.sequence([goodByePig, gameOver])
    }
}


//MARK:- Touch
extension ViewController {
    
    func setupGestures() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeRight.direction = .right
        scnView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeLeft.direction = .left
        scnView.addGestureRecognizer(swipeLeft)
        
        let swipeForward = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeForward.direction = .up
        scnView.addGestureRecognizer(swipeForward)
        
        let swipeBackward = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeBackward.direction = .down
        scnView.addGestureRecognizer(swipeBackward)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == .tapToPlay {
            startGame()
        }
    }
    
    
    @objc func handleGesture(_ sender: UISwipeGestureRecognizer) {
        guard game.state == .playing else { return }
        
        //uses a bitwise AND to check for active collisions in each direction stored in activeCollisionsBitMask and saves them in individual constants
        let activeFrontCollision = activeCollisionsBitMask & BitMaskFront == BitMaskFront
        let activeBackCollision = activeCollisionsBitMask & BitMaskBack == BitMaskBack
        let activeLeftCollision = activeCollisionsBitMask & BitMaskLeft == BitMaskLeft
        let activeRightCollision = activeCollisionsBitMask & BitMaskRight == BitMaskRight
        
        
        //check if there is no active collision in the direction of the gesture
        guard (sender.direction == .up && !activeFrontCollision) ||
                (sender.direction == .down && !activeBackCollision) ||
                (sender.direction == .left && !activeRightCollision) ||
                (sender.direction == .right && !activeLeftCollision)
        else { return }
        
        switch sender.direction {
        case .up: pigNode.runAction(jumpForwardAction)
        case .down: pigNode.runAction(jumpBackwardAction)
        case .left:
            
            pigNode.runAction(jumpLeftAction)
        case .right:
            pigNode.runAction(jumpRightAction)
        default: break
        }
    }
}
