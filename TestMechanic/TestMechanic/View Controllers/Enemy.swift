//
//  Enemy.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 25.12.2020.
//

import Foundation
import SceneKit

extension ViewController {
    
    
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
    
    
    func runPigsAction() {
        pigs = gameScene.rootNode.childNode(withName: "Pigs", recursively: true)!
        let children = pigs.childNodes
        for child in children {
            if !child.hasActions {
              //  print("run piggy")
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
               // print("remove piggy")
            }
        }
    }
    
    func triggerActions() {
        //        let nodes = scnView.nodesInsideFrustum(of: camera)
        //        nodes.forEach {n in
        //            if n.name == "Piggy" {
        //                runPigsAction()
        //            }
        //        }
        
        let children = gameScene.rootNode.childNodes
        for child in children {
            if scnView.isNode(child, insideFrustumOf: horizTopCamera) {
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
