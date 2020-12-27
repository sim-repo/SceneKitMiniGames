//
//  StateDetectors.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 24.12.2020.
//

import Foundation


//MARK:- Detect State
extension ViewController  {
    
    func detectStandState(time: TimeInterval){
        if hero.state != .stand {
            if heroNode.physicsBody!.isResting  {
                startWaitingBeforeFallDown = nil
                hero.state = .stand
                hero.lastPosY = nil
               
            }
        }
    }
    
    
    func detectFallDownState(time: TimeInterval){
       // guard hero.affectedBy != .gravity else { return }
        guard hero.state != .stand else { return }
        guard hero.state != .fallDown else { return }
        
        let deviation: Float = 0.5
        let beforeJumpPosY = hero.lastPosY
        if beforeJumpPosY != nil {
            if heroNode.presentation.worldPosition.y + deviation > beforeJumpPosY! {
                return
            }
        }
        
        let duration: TimeInterval = 0.1
        
        let x = heroNode.physicsBody!.velocity.x
        let y = heroNode.physicsBody!.velocity.y
        let z = heroNode.physicsBody!.velocity.z
        
        if -0.01...0.01 ~= x &&  -0.01...0.01 ~= z && y < -1  {
            if startWaitingBeforeFallDown == nil {
                startWaitingBeforeFallDown = time + duration
            }
            
            print("time rem: \(startWaitingBeforeFallDown! - time)   ---    pos before: \(beforeJumpPosY)  --   now \(heroNode.presentation.worldPosition.y)")
            if time > startWaitingBeforeFallDown! {
                startWaitingBeforeFallDown = nil
                hero.state = .fallDown
                print("FALL DOWN")
            }
        }
    }
}
