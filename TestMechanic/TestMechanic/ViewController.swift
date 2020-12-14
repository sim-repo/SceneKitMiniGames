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


class ViewController: UIViewController, VCDelegateProtocol {

    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    var scnView: SCNView!
    var gameScene: SCNScene!
    var hero: SCNNode!
    var camera: SCNNode!
    var cameraFollow: SCNNode!
    
    let touchControler = TouchController()

    
    //sliders for test only: >>
    @IBOutlet weak var speedKF: UISlider!
    @IBOutlet weak var speedKfLabel: UILabel!
    
    @IBAction func speedMoveSlider(_ sender: Any) {
        speedKf = CGFloat(speedKF.value)*0.01
        updateSpeedMoveSlider()
    }
    
    func updateSpeedMoveSlider(){
        DispatchQueue.main.async {
            self.speedKfLabel.text = "Speed Koeff:  \(self.speedKF.value*0.01)  : \(speedType)"
        }
    }
    
    
    @IBOutlet weak var jumpDistanceSlider: UISlider!
    @IBOutlet weak var jumpDistanceLabel: UILabel!
    
    @IBAction func jumpDistanceAction(_ sender: Any) {
        jumpDistanceKf = CGFloat(jumpDistanceSlider.value)
        updateJumpDistanceSlider()
    }
    
    func updateJumpDistanceSlider(){
        
        DispatchQueue.main.async {
            self.jumpDistanceLabel.text = "Jump Distance: \(self.jumpDistanceSlider.value)"
        }
    }
    
    
    
    @IBOutlet weak var jumpDurationSlider: UISlider!
    @IBOutlet weak var jumpDurationLabel: UILabel!
    
    @IBAction func updateJumpDurationAction(_ sender: Any) {
        jumpDurationKf = Double(jumpDurationSlider.value)
        DispatchQueue.main.async {
            self.jumpDurationLabel.text = "Jump Duration: \(self.jumpDurationSlider.value)"
        }
    }

    
    @IBOutlet weak var jumpHighSlider: UISlider!
    @IBOutlet weak var jumpHighLabel: UILabel!
    
    @IBAction func jumpHighAction(_ sender: Any) {
        jumpHighKf = CGFloat(jumpHighSlider.value)
        DispatchQueue.main.async {
            self.jumpHighLabel.text = "Jump High: \(self.jumpHighSlider.value)"
        }
    }
    
    
    //sliders for test only: <<
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScenes()
        setupNodes()
        setupCollisionNodes()
        setupTouchController()
    }
    
    
    func setupTouchController(){
        touchControler.setup(scnView: scnView, heroNode: hero)
        
        touchControler.panRecognizer.delegate = self
        touchControler.tapRecognizer.delegate = self
      //  touchControler.delegate = self
    }
    
    
    func setupScenes() {
        let height = view.frame.size.height * 0.65
        let width = view.frame.size.width
        let frame = CGRect(x:0, y:0, width: width, height: height)
        
        scnView = SCNView(frame: frame)
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
}




var velocitySnapshots: [SCNVector3] = []
var freeFallStarted = false
func checkFreeFalls(node: SCNNode){
    guard let velocity = node.physicsBody?.velocity else { return }
    
    //first detect
    
    if freeFallStarted == false,
       velocitySnapshots.count == 0,
       velocity.x == 0 &&  velocity.y < 0 && velocity.z == 0 {
        
            freeFallStarted = true
            velocitySnapshots.append(velocity)
            return
    }
    
    if freeFallStarted == false {
        return
    }
    
    if velocity.x != 0 || velocity.z != 0 || velocity.y >= 0 {
    
        freeFallStarted = false
        velocitySnapshots = []
        return
    }
       
    velocitySnapshots.append(velocity)
       
    let Y = velocitySnapshots.map{$0.y}
    if !velocitySnapshots.contains(where: {$0.x != 0}) &&
       !velocitySnapshots.contains(where: {$0.z != 0}) &&
       !velocitySnapshots.contains(where: {$0.y >= 0}) &&
        Y.count > 5 {
         //print("FREE FALL!")
    }
}



//MARK:- Renderer
extension ViewController : SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        let currentTime = Date().timeIntervalSince1970
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        updateCamera()
        touchControler.move()
    }
}



//MARK:- Camera
extension ViewController  {
    func updateCamera() {
        let lerpX = (hero.position.x - cameraFollow.position.x) * 0.05
        let lerpZ = (hero.position.z - cameraFollow.position.z) * 0.05
        cameraFollow.position.x += lerpX
        cameraFollow.position.z += lerpZ
    }
}



//MARK:- Collision
extension ViewController : SCNPhysicsContactDelegate {
    
    func setupCollisionNodes(){
        hero.physicsBody?.contactTestBitMask = BitMaskObstacle
    }
}




extension ViewController: UIGestureRecognizerDelegate {
    
//
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return false
//    }
//
//
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return false
//    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
}
