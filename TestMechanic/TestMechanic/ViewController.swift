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

// for test only: >>
protocol VCDelegateProtocol {
    func updateSpeedMoveSlider()
}
// for test only: <<


class ViewController: UIViewController {
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var scnView: SCNView!
    var gameScene: SCNScene!
    var hero: SCNNode!
    var camera: SCNNode!
    var cameraFollow: SCNNode!
    
    let touchControler = TouchController()
    
    
    var panView: UIView?
    var panRecognizer: UIPanGestureRecognizer?
    
    var tapView: UIView?
    var tapRecognizer: UITapGestureRecognizer? // прыжки героя
    
    var centroidView: UIView?
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScenes()
        setupPanTapView()
        setupNodes()
        setupCollisionNodes()
        setupTouchController()
       
    }
    
    
    func setupTouchController(){
        guard let panView = panView,
              let tapView = tapView,
              let centroidView = centroidView else { return }
        
        touchControler.setup(panView: panView, tapView: tapView, centroidView: centroidView, heroNode: hero)
        
        touchControler.panRecognizer.delegate = self
        touchControler.tapRecognizer.delegate = self
        
        tapRecognizer = touchControler.tapRecognizer
        panRecognizer = touchControler.panRecognizer
    }
    
    
    func setupScenes() {
        let height = view.frame.size.height * 0.65
        let width = view.frame.size.width
        let frame = CGRect(x:0, y:0, width: width, height: height)
        
        scnView = SCNView(frame: view.frame)
        self.view.addSubview(scnView)
        scnView.delegate = self
        gameScene = SCNScene(named: "/Mech.scnassets/Game.scn")
        gameScene.physicsWorld.contactDelegate = self
        scnView.scene = gameScene
        scnView.isPlaying = true
    }
    
    
    func setupNodes() {
        hero = gameScene.rootNode.childNode(withName: "Hero", recursively: true)!
        camera = gameScene.rootNode.childNode(withName: "Cam", recursively: true)!
        cameraFollow = gameScene.rootNode.childNode(withName: "FollowCam", recursively: true)!
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
}


//MARK:- Renderer
extension ViewController : SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        updateCamera()
        touchControler.tryMove()
    }
}



//MARK:- Camera
extension ViewController  {
    func updateCamera() {
        if !(-0.1...0.1 ~= (hero.presentation.worldPosition.x - cameraFollow.position.x) ) ||
            !(-0.1...0.1 ~= (hero.presentation.worldPosition.y - cameraFollow.position.y) ) ||
            !(-0.1...0.1 ~= (hero.presentation.worldPosition.z - cameraFollow.position.z) ) {
            let lerpX = (self.hero.presentation.worldPosition.x - self.cameraFollow.position.x) * 0.05
            let lerpY = (self.hero.presentation.worldPosition.y - self.cameraFollow.position.y) * 0.05
            let lerpZ = (self.hero.presentation.worldPosition.z - self.cameraFollow.position.z) * 0.05
            self.cameraFollow.position.x += lerpX
            self.cameraFollow.position.y += lerpY
            self.cameraFollow.position.z += lerpZ
        }
    }
}


//MARK:- Collision
extension ViewController : SCNPhysicsContactDelegate {
    func setupCollisionNodes(){
        hero.physicsBody?.contactTestBitMask = BitMaskObstacle
    }
}


extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
}
