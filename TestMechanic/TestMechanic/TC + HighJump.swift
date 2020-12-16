//
//  TC + HighJump.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 15.12.2020.
//


import UIKit
import SceneKit


//MARK:- High Jump
extension TouchController {
    
    func highJump() {
        guard hero.state != .longJump && hero.state != .run else { return }
        
        hero.state = .highJump
        let duration = 0.6
        
        // Bounce:
        let bounceUpAction = SCNAction.moveBy(x: 0, y: calcHighJumpHeight(), z: 0, duration: duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1*calcHighJumpHeight(), z: 0, duration: duration * 0.5)
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        DispatchQueue.global().asyncAfter(deadline: .now()+duration) {
            self.hero.state = .stand
        }
        heroNode.runAction(bounceAction)
    }
}

func calcHighJumpHeight() -> CGFloat {
    switch speedType {
    case .zero:
        return 8 + jumpHighKf
    case .one:
        return 4 + jumpHighKf
    case .two:
        return 5 + jumpHighKf
    }
}
