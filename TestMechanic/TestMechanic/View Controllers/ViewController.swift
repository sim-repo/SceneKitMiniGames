//
//  ViewController.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import UIKit
import SceneKit


let BitMaskHero = 1
let BitMaskObstacle = 4
let BitMaskEnemy = 8
let BitMaskGravityUP = 16
let BitMaskBreakable = 32

class ViewController: UIViewController {
    
    var game = GameHelper.shared
    
    var scnView: SCNView!
    var gameScene: SCNScene!
    var hero:Hero!
    var heroNode: SCNNode!
    var horizTopCamera: SCNNode!
    var horizZoomCamera: SCNNode!
    var cameraFollow: SCNNode!
    let touchControler = TouchController()
    var panView = UIView()
    var panRecognizer: UIPanGestureRecognizer?
    var tapView = UIView()
    var tapRecognizer: UITapGestureRecognizer? // прыжки героя
    
    var switchCameraView = UIView()
    var tapCameraRecognizer = UITapGestureRecognizer() // прыжки героя
    
    var triggerGameOver: SCNAction!
    
    var startWaitingBeforeFallDown: TimeInterval?
    
    
    
    //unnecessaries:
    var pigs: SCNNode!
    
    let p = Pathfinder()
    
    var timerHideObstacles: Timer?
    
    //HUD:
    
    let hud = UIView()
    let heroStateLabel = UILabel()
    var heroStatesSeq: [String] = []
    let joyPanCircleLayer = CAShapeLayer()
    let joyTapCircleLayer = CAShapeLayer()
    
    //Pathfinding:
    var timerScanHeroLocation: Timer?
    var firstTime = true
    var lastDistance: CGFloat = 10000
    var enemies = [SCNNode]()
    var enemyParent: SCNNode!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hero = Hero(hudDelegate: self)
        setupScenes()
        setupHUD()
        setupPanTapView()
        setupNodes()
        setupCollisionNodes()
        setupTouchController()
        setupTriggerGameOver()
        setupSounds()
        setupHeroModel()
        setupTimers()
    }
    
    
    func setupHeroModel(){
        hero.size = getNodeSize(heroNode)
    }
    
    func setupTouchController(){
        touchControler.setup(panView: panView, tapView: tapView, heroNode: heroNode, heroModel: hero)
        
        touchControler.panRecognizer.delegate = self
        touchControler.tapRecognizer.delegate = self
        
        tapRecognizer = touchControler.tapRecognizer
        panRecognizer = touchControler.panRecognizer
    }
    

    func setupScenes() {
        scnView = SCNView(frame: view.frame)
        self.view.addSubview(scnView)
        scnView.delegate = self
        gameScene = SCNScene(named: "/Mech.scnassets/Game.scn")
        gameScene.physicsWorld.contactDelegate = self
        scnView.scene = gameScene
        scnView.isPlaying = true
        scnView.showsStatistics = true
    }
    
    
    func setupNodes() {
        heroNode = gameScene.rootNode.childNode(withName: "Hero", recursively: true)!
        horizTopCamera = gameScene.rootNode.childNode(withName: "HorizTopCamera", recursively: true)!
        horizZoomCamera = gameScene.rootNode.childNode(withName: "HorizZoomCamera", recursively: true)!
        cameraFollow = gameScene.rootNode.childNode(withName: "FollowCam", recursively: true)!
        scnView.pointOfView = horizTopCamera
    }
    
    
    override var prefersStatusBarHidden : Bool { return true }
    override var shouldAutorotate : Bool { return false }
    
    
    func setupSounds() {
        game.loadSound("Jump", fileNamed: "Mech.scnassets/Audio/Jump.wav")
        game.loadSound("Blocked", fileNamed: "Mech.scnassets/Audio/Blocked.wav")
        game.loadSound("Crash", fileNamed: "Mech.scnassets/Audio/Crash.wav")
        game.loadSound("CollectCoin", fileNamed: "Mech.scnassets/Audio/CollectCoin.wav")
        game.loadSound("BankCoin", fileNamed: "Mech.scnassets/Audio/BankCoin.wav")
    }
    
    
    func setupTimers(){
        makeTransparentHidingObjects()
    }
}
 


//MARK:- Renderer
extension ViewController : SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        

        
        updateCamera()
        touchControler.tryMove()
        
        
        
        //STAND
        detectStandState(time: time)
        detectFallDownState(time: time)
        
        triggerActions()
//        if firstTime {
//            firstTime = false
//            setupPathfinding()
//            runEnemy()
//        }
    }
    
//    
//    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//       // preventPassingThroughWalls(scene: scene)
//       // continuousAffectionDetection(scene: scene)
//    }
}





extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}




//MARK:- Flow
extension ViewController  {
    func stopGame() {
        game.playSound(heroNode, name: "Crash")
        game.state = .gameOver
        game.reset()
        heroNode.runAction(triggerGameOver)
    }
    
    
    func setupTriggerGameOver() {
        let spinAround = SCNAction.rotateBy(x: 0, y: convertToRadians(angle: 180), z: 0, duration: 1)
        let riseUp = SCNAction.moveBy(x: 0, y: 4, z: 0, duration: 1)
        let down = SCNAction.moveBy(x: 0, y: -4, z: 0, duration: 1)
        let goodByePig = SCNAction.group([spinAround, riseUp])
        
        let gameOver = SCNAction.run { (node:SCNNode) -> Void in
            self.heroNode.position = SCNVector3(x:0, y:0, z:0)
            DispatchQueue.main.sync {
                self.navigationController?.popViewController(animated: true)
            }
        }
        triggerGameOver = SCNAction.sequence([goodByePig, down, gameOver])
    }
}

