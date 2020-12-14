//
//  MovingDirection.swift
//  8AxisGameControl
//
//  Created by Igor Ivanov on 14.12.2020.
//

import UIKit

private enum VelocityEnum {
    case right, left, top, down, topRight, downRight, topLeft, downLeft
}


private func getAngle(startPoint: CGPoint, nextPoint: CGPoint) -> Double {
    
    let dx = nextPoint.x - startPoint.x
    let dy = nextPoint.y - startPoint.y
    
    var angle: Double = 0
    
    if dy > 0 {
        if dx > 0 {
            let radians = atan(Double(dy / dx))
            angle =  radians*180/Double.pi
        } else {
            let radians = atan(Double(dy / dx)) + Double.pi
            angle =  radians*180/Double.pi
        }
    }
    
    if dy < 0 && dx < 0 {
        let radians = atan(Double(dy / dx)) + Double.pi
        angle =  radians*180/Double.pi
    }
    
    if dy < 0 && dx > 0 {
        let radians = atan(Double(dy / dx)) + 2*Double.pi
        angle =  radians*180/Double.pi
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


func getVelocity(startPoint: CGPoint, nextPoint: CGPoint) -> CGPoint {
    
    let angle = getAngle(startPoint: startPoint, nextPoint: nextPoint)
    let velocityEnum = getVelocityEnum(by: angle)
    
    var dx: CGFloat = 0
    var dy: CGFloat = 0
    
    let koef: CGFloat = 0.1
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
            dx = 0.5
            dy = -0.5
        case .downRight:
            dx = 0.5
            dy = 0.5
        case .topLeft:
            dx = -0.5
            dy = -0.5
        case .downLeft:
            dx = -0.5
            dy = 0.5
    }
    return CGPoint(x: dx * koef, y: dy * koef)
}
