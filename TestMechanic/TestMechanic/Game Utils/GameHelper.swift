//
//  GameHelper.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 19.12.2020.
//

import Foundation
import SceneKit

public enum GameStateType {
    case playing
    case tapToPlay
    case gameOver
}


class GameHelper {
    static let shared = GameHelper()
    
    var state = GameStateType.tapToPlay
    //var obstacleHeight:
    var sounds:[String:SCNAudioSource] = [:]
    
    var coinsBanked:Int
    var coinsCollected:Int
    
    private init() {
        coinsCollected = 0
        coinsBanked = 0
    }
    
    func reset() {
        coinsCollected = 0
        coinsBanked = 0
    }
    
    func loadSound(_ name:String, fileNamed:String) {
        if let sound = SCNAudioSource(fileNamed: fileNamed) {
            sound.shouldStream = false
            sound.load()
            sounds[name] = sound
        }
    }
    
    func playSound(_ node:SCNNode, name:String) {
        let sound = sounds[name]
        let keys = node.actionKeys
        if keys.contains("\(node.name)_sound") == false {
            node.runAction(SCNAction.playAudio(sound!, waitForCompletion: true), forKey: "\(node.name)_sound")
        }
    }
}