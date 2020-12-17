//
//  MovingDirection.swift
//  8AxisGameControl
//
//  Created by Igor Ivanov on 14.12.2020.
//

import UIKit
import SceneKit


let RadiansPerDegrees = Double(180/Double.pi)
let DegreesPerRadians = Double(Double.pi/180)


//struct LockMoveInDirection {
//    var directions: [VelocityEnum]?
//}

enum VelocityEnum {
    case right, left, top, down, topRight, downRight, topLeft, downLeft
}


private func getAngle(startPoint: CGPoint, nextPoint: CGPoint) -> Double {
    
    let dx = nextPoint.x - startPoint.x
    let dy = nextPoint.y - startPoint.y
    
    var angle: Double = 0
    
    if dy > 0 {
        if dx > 0 {
            let radians = atan(Double(dy / dx))
            angle =  radians*RadiansPerDegrees
        } else {
            let radians = atan(Double(dy / dx)) + Double.pi
            angle =  radians*RadiansPerDegrees
        }
    }
    
    if dy < 0 && dx < 0 {
        let radians = atan(Double(dy / dx)) + Double.pi
        angle =  radians*RadiansPerDegrees
    }
    
    if dy < 0 && dx > 0 {
        let radians = atan(Double(dy / dx)) + 2*Double.pi
        angle =  radians*RadiansPerDegrees
    }
    return angle
}


private func getVelocityEnum(by angle: Double) -> VelocityEnum {
    if 0...30  ~= angle ||  330...360  ~= angle {
        return .right
    }

    if 30...60  ~= angle {
        return .downRight
    }

    if 60...120  ~= angle  {
        return .down
    }

    if 120...150  ~= angle  {
        return .downLeft
    }

    if 150...210  ~= angle  {
        return .left
    }


    if 210...240  ~= angle  {
        return .topLeft
    }


    if 240...300  ~= angle  {
        return .top
    }

    return .topRight //300...330
}


func getVelocity(node: SCNNode, hero: Hero
                , startPoint: CGPoint, nextPoint: CGPoint
                , didStartPan: inout Bool, translation: CGPoint, freezeReversePan: inout Bool // for preventing reversive pan
                ) -> CGPoint {
    
    let angle = getAngle(startPoint: startPoint, nextPoint: nextPoint)
    let velocityEnum = getVelocityEnum(by: angle)
    
    if didStartPan {
        didStartPan = false
        freezeReversePan = reversePanDetected(translation: translation, velocityEnum: velocityEnum)
        
    } else {
        if reversePanDetected(translation: translation, velocityEnum: velocityEnum) == false {
            freezeReversePan = false
        }
    }
    
    if freezeReversePan == false {
        turn(node: node, hero: hero, velocityEnum: velocityEnum)
    }
    
    var dx: CGFloat = 0
    var dy: CGFloat = 0

    switch velocityEnum {
        case .right:
            dx = 1
            dy = 0
        case .left:
            dx = -1
            dy = 0
        case .top:
            dx = 0
            dy = -1
        case .down:
            dx = 0
            dy = 1
        case .topRight:
            dx = 1
            dy = -1
        case .downRight:
            dx = 1
            dy = 1
        case .topLeft:
            dx = -1
            dy = -1
        case .downLeft:
            dx = -1
            dy = 1
    }
    
    let koef: CGFloat = 0.1
    return CGPoint(x: dx * koef, y: dy * koef)
}


func reversePanDetected(translation: CGPoint, velocityEnum: VelocityEnum) -> Bool {
    
    let dx = translation.x
    let dy = translation.y

    switch velocityEnum {
        case .right:
            return dx <= 0
        case .left:
            return dx >= 0
        case .top:
            return dy >= 0
        case .down:
            return dy <= 0
        case .topRight:
            return dy >= 0 && dx <= 0
        case .downRight:
            return dy <= 0 && dx <= 0
        case .topLeft:
            return dy >= 0 && dx >= 0
        case .downLeft:
            return dy <= 0 && dx >= 0
    }
}



func turn(node: SCNNode, hero: Hero, velocityEnum: VelocityEnum) {
    
    var turnAction: SCNAction?
    let duration = 0.2
    var angle: CGFloat = 0
    
    switch velocityEnum {
        case .right:
            angle = 90
        case .left:
            angle = -90
        case .top:
            angle = 180
        case .down:
            angle = 0
        case .topRight:
            angle = 135
        case .downRight:
            angle = 45
        case .topLeft:
            angle = -135
        case .downLeft:
            angle = -45
    }
    
    if hero.direction != velocityEnum {
        hero.direction = velocityEnum
        turnAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: angle), z: 0, duration: duration, usesShortestUnitArc: true)
    }
    
    if let action = turnAction {
        node.runAction(action)
    }
}

func convertToRadians(angle:CGFloat) -> CGFloat {
    return CGFloat(CGFloat(angle) * CGFloat(DegreesPerRadians))
}
