//
//  Camera.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 24.12.2020.
//

import Foundation
import SceneKit



//MARK:- Camera
extension ViewController  {
    
    func updateCamera() {
        let dx = heroNode.presentation.worldPosition.x - cameraFollow.position.x
        let dy = heroNode.presentation.worldPosition.y - cameraFollow.position.y
        let dz = heroNode.presentation.worldPosition.z - cameraFollow.position.z
        
        if !(-0.1...0.1 ~= dx) ||
            !(-0.1...0.1 ~= dy) ||
            !(-0.1...0.1 ~= dz) {
            
            let koeff: Float = getSpeedKoeff(dx: abs(dx), dz: abs(dz))
            let koeffY: Float = getSpeedKoeffY(dy: abs(dy))
            
            var lerpX: Float = 0
            var lerpY: Float = 0
            var lerpZ: Float = 0
            
            if !(-0.1...0.1 ~= dx) {
                 lerpX = dx * koeff
            }
            if !(-0.1...0.1 ~= dy) {
                 lerpY = dy * koeffY
            }
            if !(-0.1...0.1 ~= dz) {
                 lerpZ = dz * koeff
            }
            
            cameraFollow.position.x += lerpX
            cameraFollow.position.y += lerpY
            cameraFollow.position.z += lerpZ
        }
    }
    
    
//    func rotateYawCamera(by angle: CGFloat, duration: TimeInterval){
//        let turnAction = SCNAction.rotateBy(x: 0, y: -angle, z: 0, duration: duration)
//        turnAction.timingMode = .easeInEaseOut
//        cameraFollow.runAction(turnAction)
//
//
//    }
    
    func rotateYawCamera(by angle: CGFloat, duration: TimeInterval){
        if cameraFollow.hasActions {
            cameraFollow.removeAllActions()
        }
        var a: CGFloat = 0
        switch hero.worldDirection {
        case .north:
            a = 0
        case .northEast:
            a = 45
        case .east:
            a = 90
        case .southEast:
            a = 135
        case .south:
            a = 180
        case .southWest:
            a = 225
        case .west:
            a = 270
        case .northWest:
            a = 315
        }
        let x = CGFloat(heroNode.rotation.x)
        let z = CGFloat(heroNode.rotation.z)
        let r = -1*convertToRadians(angle: a)
        let turnAction = SCNAction.rotateTo(x: x, y: r, z: z, duration: duration, usesShortestUnitArc: true)
        turnAction.timingMode = .easeInEaseOut
        cameraFollow.runAction(turnAction)
    }
    
    
    private func getSpeedKoeff(dx: Float, dz: Float ) -> Float {
        
        if dx > 7 || dz > 7 {
            return 0.14
        }
        else  if dx > 6 || dz > 6 {
            return 0.13
        }
        
        else if dx > 5 || dz > 5 {
            return 0.12
        }
        
        else if dx > 4 || dz > 4 {
            return 0.11
        }
        
        else if dx > 3 || dz > 3 {
            return 0.10
        }
        
        else if dx > 2 || dz > 2 {
            return 0.09
        }
        
        return 0.09
    }
    
    private func getSpeedKoeffY(dy: Float ) -> Float {
        
        if dy > 7{
            return 0.10
        }
        else  if dy > 6  {
            return 0.09
        }
        
        else if dy > 5  {
            return 0.08
        }
        
        else if dy > 4  {
            return 0.07
        }
        
        else if dy > 3  {
            return 0.06
        }
        
        else if dy > 2  {
            return 0.05
        }
        
        return 0.04
    }
}
