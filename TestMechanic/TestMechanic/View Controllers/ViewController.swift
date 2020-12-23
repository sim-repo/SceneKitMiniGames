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
var activeCollisionsBitMask: Int = 0

class ViewController: UIViewController {
    
    var game = GameHelper.shared
    
    var scnView: SCNView!
    var gameScene: SCNScene!
    var hero = Hero()
    var heroNode: SCNNode!
    var camera: SCNNode!
    var cameraFollow: SCNNode!
    let touchControler = TouchController()
    var panView: UIView?
    var panRecognizer: UIPanGestureRecognizer?
    var tapView: UIView?
    var tapRecognizer: UITapGestureRecognizer? // прыжки героя
    
    
    var triggerGameOver: SCNAction!
    
    //unnecessaries:
    var centroidView: UIView?
    var pigs: SCNNode!
    
    let p = Pathfinder()
    
    var timerHideObstacles: Timer?
    
    //perfomance:
    //var staticModel: [StaticModel]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScenes()
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
        guard let panView = panView,
              let tapView = tapView,
              let centroidView = centroidView else { return }
        
        touchControler.setup(panView: panView, tapView: tapView, centroidView: centroidView, heroNode: heroNode, heroModel: hero)
        
        touchControler.panRecognizer.delegate = self
        touchControler.tapRecognizer.delegate = self
        
        tapRecognizer = touchControler.tapRecognizer
        panRecognizer = touchControler.panRecognizer
    }
    
    
    //Pathfinding:
    var timerScanHeroLocation: Timer?
    var firstTime = true
    var lastDistance: CGFloat = 10000
    var enemies = [SCNNode]()
    var enemyParent: SCNNode!
    
    func setupPathfinding(){
        p.fillGraph(gameScene: gameScene)
        enemyParent = gameScene.rootNode.childNode(withName: "Enemies", recursively: true)!
        enemies = enemyParent.childNodes
    }
    
    
    func runEnemy(){
        timerScanHeroLocation = Timer.init(fire: Date().addingTimeInterval(5), interval: 0.1, repeats: true) {_ in
            DispatchQueue.global(qos: .background).async {
                for enemy in self.enemies {
//                    var canCalcPath = false
//                    let curDistance = calcDistance(node1: enemy, node2: self.heroNode)
//                    if curDistance < 5 {
//                        if enemy.hasActions == false {
//                            canCalcPath = true
//                        }
//                    } else
//
//
                    if enemy.hasActions == false {
                        if !SCNVector3EqualToVector3(self.heroNode.position, enemy.position) {
                            self.p.animatePath(enemy: enemy, enemyParentWorld: self.enemyParent, target: self.heroNode)
                        }
                    }
                    
//                    if canCalcPath {
//                        if enemy.hasActions {
//                            enemy.removeAllActions()
//                        }
//                    }
                }
            }
        }
        RunLoop.main.add(timerScanHeroLocation!, forMode: .common)
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
        camera = gameScene.rootNode.childNode(withName: "Cam", recursively: true)!
        cameraFollow = gameScene.rootNode.childNode(withName: "FollowCam", recursively: true)!
    }
    
    
    func runPigsAction() {
        pigs = gameScene.rootNode.childNode(withName: "Pigs", recursively: true)!
        let children = pigs.childNodes
        for child in children {
            if !child.hasActions {
                print("run piggy")
                moveBySquare(node: child)
            }
        }
    }
    
    func removePigsAction() {
        pigs = gameScene.rootNode.childNode(withName: "Pigs", recursively: true)!
        let children = pigs.childNodes
        for child in children {
            if child.hasActions {
                child.removeAllActions()
                print("remove piggy")
            }
        }
    }
    
    
    override var prefersStatusBarHidden : Bool { return true }
    override var shouldAutorotate : Bool { return false }
    
    
    func setupPanTapView(){
        panView = UIView()
        tapView = UIView()
        centroidView = UIView()
        
        guard let panView = panView,
              let tapView = tapView,
              let centroid = centroidView
        else { return }
        
        panView.backgroundColor = .clear
        self.view.addSubview(panView)
        
        tapView.backgroundColor = .clear
        self.view.addSubview(tapView)
        
        
        tapView.translatesAutoresizingMaskIntoConstraints = false
        let tapLead = tapView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let tapBottom = tapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let tapTrail = tapView.trailingAnchor.constraint(equalTo: panView.leadingAnchor)
        let tapHeight = tapView.heightAnchor.constraint(equalToConstant: 300)
        view.addConstraints([tapLead, tapBottom, tapTrail, tapHeight])
        
        
        panView.translatesAutoresizingMaskIntoConstraints = false
        let panLead = panView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        let panBottom = panView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let panTrail = panView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let panHeight = panView.heightAnchor.constraint(equalToConstant: 300)
        view.addConstraints([panLead, panBottom, panTrail, panHeight])
        
        centroid.translatesAutoresizingMaskIntoConstraints = false
        centroid.backgroundColor = .clear
        centroid.frame = CGRect(x:0, y:0, width: 50, height: 50)
        centroid.bounds = centroid.frame
        
        panView.addSubview(centroid)
    }
    
    
    
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
        

        triggerActions()
        if firstTime {
            firstTime = false
            setupPathfinding()
            runEnemy()
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        preventPassingThroughWalls(scene: scene)
    }
}



//MARK:- prevent
/*
 Предотвращяем прохождение сквозь стены
 */
extension ViewController  {
    func preventPassingThroughWalls(scene: SCNScene) {
        let contacts = scene.physicsWorld.contactTest(with: heroNode.physicsBody!, options: nil)
        for contact in contacts {
            let cn = SCNVector3( round(contact.contactNormal.x),
                                 round(contact.contactNormal.y),
                                 round(contact.contactNormal.z))
            
            var dx: CGFloat = 0
            var dz: CGFloat = 0
            if cn.x != 0 {
                dx = cn.x > 0 ? 0.1 : -0.1
            }
            if cn.z != 0 {
                dz = cn.z > 0 ? 0.1 : -0.1
            }
            
            if cn.x != 0 || cn.z != 0 {
                let action = SCNAction.moveBy(x: dx, y: 0, z: dz, duration: 0.1)
                
                let updateAction = SCNAction.customAction(duration: 0.1) {_,_ in
                    self.touchControler.lastHeroPosition = self.heroNode.presentation.worldPosition
                }
                let group = SCNAction.group([updateAction, action])
                heroNode.runAction(group)
            }
            
        }
    }
}


//MARK:- hiding obstacles
extension ViewController  {
    func makeTransparentHidingObjects(){
        return
        timerHideObstacles = Timer.init(fire: Date().addingTimeInterval(0), interval: 0.2, repeats: true) {_ in
            DispatchQueue.global(qos: .utility).async {
                let nodes = self.scnView.nodesInsideFrustum(of: self.camera)
                
                DispatchQueue.main.sync {
                    nodes.forEach {n in
                        n.opacity = 1
                    }
                }
                
                let nearZ = nodes.filter{$0.worldPosition.z > self.heroNode.worldPosition.z}
                
                let heroTop = self.hero.getHeroTop(self.heroNode)
                let higher = nearZ.filter{ (getNodeTop($0) - 2) > heroTop }
    
                DispatchQueue.main.sync {
                    for n in higher {
                        n.opacity = 0.4
                    }
                }
            }
        }
        RunLoop.main.add(timerHideObstacles!, forMode: .common)
    }
}



//MARK:- Camera
extension ViewController  {
    func updateCamera() {
        if !(-0.1...0.1 ~= (heroNode.presentation.worldPosition.x - cameraFollow.position.x) ) ||
            !(-0.1...0.1 ~= (heroNode.presentation.worldPosition.y - cameraFollow.position.y) ) ||
            !(-0.1...0.1 ~= (heroNode.presentation.worldPosition.z - cameraFollow.position.z) ) {
            let lerpX = (self.heroNode.presentation.worldPosition.x - self.cameraFollow.position.x) * 0.05
            let lerpY = (self.heroNode.presentation.worldPosition.y - self.cameraFollow.position.y) * 0.05
            let lerpZ = (self.heroNode.presentation.worldPosition.z - self.cameraFollow.position.z) * 0.05
            self.cameraFollow.position.x += lerpX
            self.cameraFollow.position.y += lerpY
            self.cameraFollow.position.z += lerpZ
        }
    }
}


//MARK:- Collision
extension ViewController : SCNPhysicsContactDelegate {
    func setupCollisionNodes(){
        heroNode.physicsBody?.contactTestBitMask = BitMaskEnemy | BitMaskObstacle
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var enemyNode: SCNNode!
        
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskHero {
            enemyNode = contact.nodeB
        } else {
            enemyNode = contact.nodeA
        }
        if enemyNode.physicsBody?.categoryBitMask == BitMaskEnemy {
            stopGame()
        }
        
        //        if enemyNode.physicsBody?.categoryBitMask == BitMaskObstacle {
        //            game.playSound(hero, name: "Blocked")
        //        }
    }
}


extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}



//MARK:- trigger actions
extension ViewController  {
    func triggerActions() {
        //        let nodes = scnView.nodesInsideFrustum(of: camera)
        //        nodes.forEach {n in
        //            if n.name == "Piggy" {
        //                runPigsAction()
        //            }
        //        }
        
        let children = gameScene.rootNode.childNodes
        for child in children {
            if scnView.isNode(child, insideFrustumOf: camera) {
                if child.name == "Pigs" {
                    runPigsAction()
                }
            } else {
                if child.name == "Pigs" {
                    removePigsAction()
                }
            }
        }
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
        // let fadeOut = SCNAction.fadeOpacity(to: 0.2, duration: 0.5)
        let down = SCNAction.moveBy(x: 0, y: -4, z: 0, duration: 1)
        
        
        let goodByePig = SCNAction.group([spinAround, riseUp])
        
        
        let gameOver = SCNAction.run { (node:SCNNode) -> Void in
            self.heroNode.position = SCNVector3(x:0, y:0, z:0)
            //  self.hero.opacity = 1.0
            DispatchQueue.main.sync {
                self.navigationController?.popViewController(animated: true)
            }
        }
        triggerGameOver = SCNAction.sequence([goodByePig, down, gameOver])
    }
}

