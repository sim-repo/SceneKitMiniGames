//
//  Hero.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import UIKit
import SceneKit

class Hero {
    enum State {
        case walk, run, longJump, willStand, stand, highJump
    }
    var state: State = .stand
    var direction: VelocityEnum = .down
    var size: CGSize! {
        didSet {
            halfSize = CGSize(width: size.width / 2, height: size.height / 2)
        }
    }
    var halfSize: CGSize!
    
    
    
    func getHeroTop(_ node: SCNNode) -> CGFloat {
        return CGFloat(node.position.y) + halfSize.height
    }
}
