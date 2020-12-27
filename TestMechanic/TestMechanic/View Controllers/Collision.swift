//
//  Collision.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 24.12.2020.
//

import Foundation
import SceneKit


//MARK:- prevent
/*
 Предотвращяем прохождение сквозь стены
 */
extension ViewController  {
    
//    func continuousAffectionDetection(scene: SCNScene) {
//        let contacts = scene.physicsWorld.contactTest(with: heroNode.physicsBody!, options: nil)
//        print(getAffection(contacts: contacts))
//    }
    
    
//    func preventPassingThroughWalls(scene: SCNScene) {
//        let contacts = scene.physicsWorld.contactTest(with: heroNode.physicsBody!, options: nil)
//        
//        for contact in contacts {
//            
//            if contact.nodeA.physicsBody?.categoryBitMask != BitMaskHero { continue }
//            
//            let cn = SCNVector3( round(contact.contactNormal.x),
//                                 round(contact.contactNormal.y),
//                                 round(contact.contactNormal.z))
//            
//            var dx: CGFloat = 0
//            var dz: CGFloat = 0
//            if cn.x != 0 {
//                dx = cn.x > 0 ? 0.1 : -0.1
//            }
//            if cn.z != 0 {
//                dz = cn.z > 0 ? 0.1 : -0.1
//            }
//            
//            if cn.x != 0 || cn.z != 0 {
//                let action = SCNAction.moveBy(x: dx, y: 0, z: dz, duration: 0.1)
//                
//                let updateAction = SCNAction.customAction(duration: 0.1) {_,_ in
//                    self.touchControler.lastHeroPosition = self.heroNode.presentation.worldPosition
//                }
//                let group = SCNAction.group([updateAction, action])
//                heroNode.runAction(group)
//            }
//        }
//    }
    
    
//    func getAffection(contacts: [SCNPhysicsContact]) -> Hero.Affection? {
//        for contact in contacts {
//            var contactingNode: SCNNode!
//
//            if contact.nodeA.physicsBody?.categoryBitMask == BitMaskHero {
//                contactingNode = contact.nodeB
//            } else {
//                contactingNode = contact.nodeA
//            }
//            if contactingNode.physicsBody?.categoryBitMask == BitMaskGravityUP {
//                return .gravity
//            }
//        }
//        return nil
//    }
}


//MARK:- Collision
extension ViewController : SCNPhysicsContactDelegate {
    
    func setupCollisionNodes(){
        heroNode.physicsBody?.contactTestBitMask = BitMaskEnemy | BitMaskObstacle | BitMaskGravityUP | BitMaskBreakable
    }
    
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        var contactingNode: SCNNode!
        
        if contact.nodeA.physicsBody?.categoryBitMask == BitMaskHero {
            contactingNode = contact.nodeB
        } else {
            contactingNode = contact.nodeA
        }
        
        if contactingNode.physicsBody?.categoryBitMask == BitMaskEnemy {
            stopGame()
        }
        
        if contactingNode.physicsBody?.categoryBitMask == BitMaskGravityUP {
            if hero.affectedBy != .gravity {
                hero.affectedBy = .gravity
                hero.lastPosY = Float(getNodeBottom(contactingNode))
            }
        }
        
        if contactingNode.physicsBody?.categoryBitMask == BitMaskObstacle {
            hero.affectedBy = nil
            
            /*
             TODO: startWaitingBeforeFallDown лучще обнулять когда герой точно прилетает сверху на любую поверхность.
             Тогда не возникнет случайного эффекта "отмены свободного падения" в случае когда герой, падая, ударяется боком об блок.
             
             */
            startWaitingBeforeFallDown = nil
        }
        
        
        if contactingNode.physicsBody?.categoryBitMask == BitMaskBreakable {
            let color = contactingNode.geometry!.materials.first?.diffuse.contents as! UIColor
            createExplosion(color: color, geometry: contactingNode.geometry!, position: contactingNode.presentation.worldPosition, rotation: contactingNode.presentation.rotation)
            
            let container = contactingNode.parent
            container?.removeFromParentNode()
        }
    }
}
