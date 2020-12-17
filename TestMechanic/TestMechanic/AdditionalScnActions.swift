//
//  AdditionalScnActions.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 17.12.2020.
//

import Foundation
import SceneKit

func moveBySquare(node: SCNNode) {
    
    let duration:Double = 0.6
    
    let bounceUpAction = SCNAction.moveBy(x: 0, y: 1.0, z: 0, duration: duration * 0.5)
    let bounceDownAction = SCNAction.moveBy(x: 0, y: -1.0, z: 0, duration: duration * 0.5)
    bounceUpAction.timingMode = .easeOut
    bounceDownAction.timingMode = .easeIn
    let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
    
    let moveLeftAction = SCNAction.moveBy(x: -1.0, y: 0, z: 0, duration: duration)
    let moveRightAction = SCNAction.moveBy(x: 1.0, y: 0, z: 0, duration: duration)
    let moveForwardAction = SCNAction.moveBy(x: 0, y: 0, z: -1.0, duration: duration)
    let moveBackwardAction = SCNAction.moveBy(x: 0, y: 0, z: 1.0, duration: duration)
    
    
    let turnLeftAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: -90), z: 0, duration: duration, usesShortestUnitArc: true)
    let turnRightAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 90), z: 0, duration: duration, usesShortestUnitArc: true)
    let turnForwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 180),z: 0, duration: duration, usesShortestUnitArc: true)
    let turnBackwardAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: 0), z: 0, duration: duration, usesShortestUnitArc: true)
    
    var leftArray: [SCNAction] = []
    var rightArray: [SCNAction] = []
    var forwardArray: [SCNAction] = []
    var backwardArray: [SCNAction] = []
    
    for _ in 0...10 {
        let jumpLeft = SCNAction.group([turnLeftAction, bounceAction, moveLeftAction])
        leftArray.append(jumpLeft)
        let jumpRight = SCNAction.group([turnRightAction, bounceAction, moveRightAction])
        rightArray.append(jumpRight)
        let jumpForward = SCNAction.group([turnForwardAction, bounceAction, moveForwardAction])
        forwardArray.append(jumpForward)
        let jumpBackward = SCNAction.group([turnBackwardAction, bounceAction, moveBackwardAction])
        backwardArray.append(jumpBackward)
    }
    
    let loop = SCNAction.sequence(leftArray+backwardArray+rightArray+forwardArray)
    
    let action = SCNAction.repeat(loop, count: 10)
    node.runAction(action)
}
