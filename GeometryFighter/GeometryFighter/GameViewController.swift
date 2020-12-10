import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var spawnTime: TimeInterval = 0
    var game = GameHelper.sharedInstance
    var splashNodes:[String:SCNNode] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
        setupHUD()
        setupSplash()
        setupSounds()
    }
    
    override var shouldAutorotate: Bool { return true }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.delegate = self
        scnView.showsStatistics = true
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true
        scnView.allowsCameraControl = false
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.jpg"
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        scnScene.rootNode.addChildNode(cameraNode)
        
    }
    
    
    
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
}





extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > spawnTime {
            cleanScene()
            spawnShape()
            spawnTime = time + TimeInterval(Float.random(in: 0.2 ..< 1.5))
            game.updateHUD()
        }
        
    }
}




//MARK:- Splash Screen
extension GameViewController {
    
    func setupSplash() {
        splashNodes["TapToPlay"] = createSplash(name: "TAPTOPLAY",
                                                imageFileName: "GeometryFighter.scnassets/Textures/TapToPlay_Diffuse.png")
        splashNodes["GameOver"] = createSplash(name: "GAMEOVER",
                                               imageFileName: "GeometryFighter.scnassets/Textures/GameOver_Diffuse.png")
        showSplash(splashName: "TapToPlay")
    }
    
    
    func showSplash(splashName:String) {
        for (name,node) in splashNodes {
            if name == splashName {
                node.isHidden = false
            } else {
                node.isHidden = true
            }
        }
    }
    
    
    func createSplash(name:String, imageFileName:String) -> SCNNode {
        let plane = SCNPlane(width: 5, height: 5)
        let splashNode = SCNNode(geometry: plane)
        splashNode.position = SCNVector3(x: 0, y: 5, z: 0)
        splashNode.name = name
        splashNode.geometry?.materials.first?.diffuse.contents = imageFileName
        scnScene.rootNode.addChildNode(splashNode)
        return splashNode
    }
    
}


//MARK:- Sound
extension GameViewController {
    func setupSounds() {
        game.loadSound("ExplodeGood",
          fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeGood.wav")
        game.loadSound("SpawnGood",
          fileNamed: "GeometryFighter.scnassets/Sounds/SpawnGood.wav")
        game.loadSound("ExplodeBad",
          fileNamed: "GeometryFighter.scnassets/Sounds/ExplodeBad.wav")
        game.loadSound("SpawnBad",
          fileNamed: "GeometryFighter.scnassets/Sounds/SpawnBad.wav")
        game.loadSound("GameOver",
          fileNamed: "GeometryFighter.scnassets/Sounds/GameOver.wav")
      }
}



//MARK:- Touch Handle
extension GameViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if game.state == .GameOver {
            return
        }
        
        if game.state == .TapToPlay {
            game.reset()
            game.state = .Playing
            showSplash(splashName: "")
            return
        }
        
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        
        if hitResults.count > 0 {
            let result: AnyObject! = hitResults[0]
            let node = result.node!
            if node.name == "HUD" ||
                node.name == "GAMEOVER" ||
                node.name == "TAPTOPLAY" {
                return
            } else if node.name == "GOOD" {
                handleGoodCollision()
            } else if node.name == "BAD" {
                handleBadCollision()
            }
            
            let color = node.geometry!.materials.first?.diffuse.contents as! UIColor
            createExplosion(color: color, geometry: node.geometry!, position: node.presentation.position, rotation: node.presentation.rotation)
            node.removeFromParentNode()
        }
    }
    
    func handleGoodCollision() {
        game.score += 1
        game.playSound(scnScene.rootNode, name: "ExplodeGood")
    }
    
    
    func handleBadCollision() {
        game.lives -= 1
        game.playSound(scnScene.rootNode, name: "ExplodeBad")
        game.shakeNode(cameraNode)
        
        if game.lives <= 0 {
            game.saveState()
            showSplash(splashName: "GameOver")
            game.playSound(scnScene.rootNode, name: "GameOver")
            game.state = .GameOver
            scnScene.rootNode.runAction(SCNAction.waitForDurationThenRunBlock(5) { (node:SCNNode!) -> Void in
                self.showSplash(splashName: "TapToPlay")
                self.game.state = .TapToPlay
            })
        }
    }
    
    
    func handleTouchFor(node: SCNNode) {
        
        if node.name == "GOOD" {
            game.score += 1
            
        } else if node.name == "BAD" {
            game.lives -= 1
        }
        let color = node.geometry!.materials.first?.diffuse.contents as! UIColor
        createExplosion(color: color, geometry: node.geometry!, position: node.presentation.position, rotation: node.presentation.rotation)
        node.removeFromParentNode()
    }
}


//MARK:- Spawn Shape
extension GameViewController {
    
    func spawnShape() {
        var geometry:SCNGeometry
        
        switch ShapeType.random() {
        case .box:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        case .sphere:
            geometry = SCNSphere(radius: 0.5)
        case .pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.25)
        case .capsule:
            geometry = SCNCapsule(capRadius: 0.3, height: 2.5)
        case .cylinder:
            geometry = SCNCylinder(radius: 0.3, height: 2.5)
        case .cone:
            geometry = SCNCone(topRadius: 0.25, bottomRadius: 0.5, height: 1.0)
        case .tube:
            geometry = SCNTube(innerRadius: 0.25, outerRadius: 0.5, height: 1.0)
        }
        
        let color: UIColor = UIColor.random
        geometry.materials.first?.diffuse.contents = color
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.name =  color == UIColor.black ? "BAD" : "GOOD"
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        let randomX: Float = Float.random(in: -2.0 ..< 2.0)
        let randomY = Float.random(in: 10.0 ..< 18.0)
        let force = SCNVector3(x: randomX, y: randomY , z: 0)
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
        scnScene.rootNode.addChildNode(geometryNode)
    }
}



//MARK:- Particles
extension GameViewController {
    
    func createExplosion(color: UIColor, geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 150
        particleSystem.birthRateVariation = 0
        particleSystem.particleLifeSpan = 2
        particleSystem.warmupDuration = 0
        particleSystem.loops = false
        particleSystem.birthLocation = .volume
        particleSystem.birthDirection = .surfaceNormal
        particleSystem.particleColor = color == .black ? .red : color
        particleSystem.speedFactor = 2
        particleSystem.particleSize = 0.05
        particleSystem.particleVelocity = 2.5
        particleSystem.particleMass = 1
        particleSystem.particleBounce = 0.7
        particleSystem.particleFriction = 1
        particleSystem.emissionDuration = 0.01
        particleSystem.emitterShape = geometry
        // particleSystem.particleImage = UIImage(named: "CircleParticle.png")
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x,rotation.y, rotation.z)
        
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y,position.z)
        
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(particleSystem, transform: transformMatrix)
    }
    
    
    func createExplosion2(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
        
        let explosion = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
        explosion.emitterShape = geometry
        explosion.birthLocation = .surface
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x,rotation.y, rotation.z)
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y,position.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(explosion, transform: transformMatrix)
    }
}
