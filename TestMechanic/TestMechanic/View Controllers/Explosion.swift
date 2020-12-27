//
//  Explosion.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 25.12.2020.
//


import UIKit
import SceneKit


extension ViewController {
    
    func createExplosion(color: UIColor, geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
            game.forcePlaySound(heroNode, name: "Crash")
            let particleSystem = SCNParticleSystem()
            particleSystem.birthRate = 10
            particleSystem.birthRateVariation = 0
            particleSystem.particleLifeSpan = 4
            particleSystem.warmupDuration = 0
            particleSystem.loops = false
            particleSystem.birthLocation = .volume
            particleSystem.birthDirection = .surfaceNormal
            particleSystem.particleColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            particleSystem.speedFactor = 6
            particleSystem.particleSize = 0.1
            particleSystem.particleVelocity = 2.5
            particleSystem.particleMass = 10
            particleSystem.particleBounce = 0.7
            particleSystem.particleFriction = 1
            particleSystem.emissionDuration = 0.01
            particleSystem.emitterShape = geometry
        
            let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x,rotation.y, rotation.z)
            
            let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y,position.z)
            
            let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
            gameScene.addParticleSystem(particleSystem, transform: transformMatrix)
        }
    
}
