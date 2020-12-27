//
//  MenuViewController.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 19.12.2020.
//

import UIKit
import SceneKit


class MenuViewController: UIViewController {
    
    var game = GameHelper.shared
    var scnView: SCNView!
    var menuScene: SCNScene!
    var tapRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        setupScene()
        setupGestureRecognizer()
        setupSounds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        menuScene.isPaused = false
        game.state = .tapToPlay
    }
    
    func setupScene() {
        scnView = SCNView(frame: view.frame)
        self.view.addSubview(scnView)
        scnView.delegate = self
        menuScene = SCNScene(named: "/Mech.scnassets/SplashScene.scn")
        scnView.scene = menuScene
        scnView.isPlaying = true
    }
    
    func setupGestureRecognizer(){
        tapRecognizer.addTarget(self, action: #selector(handleTapGesture))
        tapRecognizer.numberOfTapsRequired = 1
        scnView.addGestureRecognizer(tapRecognizer)
    }
    
    func startGame() {
       // menuScene.rootNode.removeAllAudioPlayers()
        game.state = .playing
        menuScene.isPaused = true
        performSegue(withIdentifier: "SegueStart", sender: self)
    }
    
    
    func setupSounds() {
        if game.state == .tapToPlay {
            let music = SCNAudioSource(fileNamed: "Mech.scnassets/Audio/Music.mp3")!
            music.volume = 0.001
            music.loops = true
            music.shouldStream = false
            music.isPositional = false
            let musicPlayer = SCNAudioPlayer(source: music)
            menuScene.rootNode.addAudioPlayer(musicPlayer)
        }
    }
}


//MARK:- Renderer
extension MenuViewController : SCNSceneRendererDelegate {
    
}


extension MenuViewController {
    @objc func handleTapGesture() {
        self.startGame()
    }
}
