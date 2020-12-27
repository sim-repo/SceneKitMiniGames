//
//  TC + LongJump.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 15.12.2020.
//

import UIKit
import SceneKit



//MARK:- Long Jump
extension TouchController {
    
    func longJump() {
        hero.state = .longJump
        if hero.lastPosY == nil { 
            hero.lastPosY = heroNode.presentation.worldPosition.y
        }
        
        let duration = jumpDurationKf
        
        // Bounce:
        let bounceUpAction = SCNAction.moveBy(x: 0, y: calcLongJumpHeight(), z: 0, duration: duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1*calcLongJumpHeight(), z: 0, duration: duration * 0.3)
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        
        // Moving:
        let moveAction = SCNAction.moveBy(x: CGFloat(jumpDistanceKf*velocity.x), y: 0, z: CGFloat(jumpDistanceKf*velocity.y), duration: duration*0.7)
        
        
        let customAction = SCNAction.customAction(duration: duration) {_,_ in
            self.lastHeroPosition = self.heroNode.presentation.worldPosition
        }
        
        
        let jump = SCNAction.group([bounceAction, moveAction])//, customAction])
        let seq = SCNAction.sequence([jump])
        
        heroNode.runAction(seq)
        
        impactFeedback()
        
        DispatchQueue.global().asyncAfter(deadline: .now()+duration-0.3) {
            if self.hero.state != .stand {
                self.hero.state = self.isPanningNow ? .run : .stand
            }
        }
    }
    
    
    
    func calcLongJumpHeight() -> CGFloat {
        switch speedType {
        case .zero:
            return 8 + jumpHighKf
        case .one:
            return 4 + jumpHighKf
        case .two:
            return 5 + jumpHighKf
        }
    }
}
