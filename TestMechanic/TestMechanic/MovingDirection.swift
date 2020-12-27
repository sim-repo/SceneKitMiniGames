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

enum WorldDirectionEnum: Int { // clockwise
    case north = 0, northEast, east, southEast, south, southWest, west, northWest
}

enum LocalDirectionEnum: Int {
    case forward = 0, forwardRight = 1, right = 2, backRight = 3, back = 4, backLeft = -3, left = -2, forwardLeft = -1
}
// northEast + left = -1
// 8 - 2 = 6

// north + forwardLeft = -1
// error


// if sum < 0 : northWest + world - abs(local):
//  a)          8         + 1     - abs(2) = 7
//  b)          8         + 0     - abs(1) = 7
//  c)          8         + 0     - abs(3) = 5
//  d)          8         + 1     - abs(3) = 6


private func convertLocal2World(_ hero: Hero, _ localDirection: LocalDirectionEnum) ->  WorldDirectionEnum {
    if localDirection == .forward {
        return hero.worldDirection
    }
    
    let local = localDirection.rawValue
    let world = hero.worldDirection.rawValue
    let sum = local + world

    var directionRaw = sum
    if sum < 0 {
        directionRaw = 8 - abs(sum)
    } else if sum > 7 {
        directionRaw = sum - 8
    }

    if let worldDirection = WorldDirectionEnum.init(rawValue: directionRaw) {
      //  print("\(worldDirection.rawValue)   :      \(localDirection)")
        return worldDirection
    }
    fatalError()
}




private func getAngleInRadians(_ startPoint: CGPoint, _ nextPoint: CGPoint) -> Double {
    
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
    else if dy < 0 && dx < 0 {
        let radians = atan(Double(dy / dx)) + Double.pi
        angle =  radians*RadiansPerDegrees
    }
    else if dy < 0 && dx > 0 {
        let radians = atan(Double(dy / dx)) + 2*Double.pi
        angle =  radians*RadiansPerDegrees
    }
    return angle
}








func getVelocity(_ heroNode: SCNNode, _ hero: Hero
                , _ joyCenterPoint: CGPoint, _ joyCurrentPoint: CGPoint
                , _ didStartPan: inout Bool, _ translation: CGPoint, _ freezeReversePan: inout Bool // for preventing reversive pan
                ) -> CGPoint {
    
    switch hero.cameraMode {
        case .statically:
            return getVelocity_inStaticCameraMode(heroNode, hero, joyCenterPoint, joyCurrentPoint, &didStartPan, translation, &freezeReversePan)
        case .dynamically:
            return getVelocity_inDynamicCameraMode(heroNode, hero, joyCenterPoint, joyCurrentPoint, &didStartPan, translation, &freezeReversePan)
    }
}




//MARK:- static camera


private func getVelocity_inStaticCameraMode(_ heroNode: SCNNode, _ hero: Hero
                                            , _ joyCenterPoint: CGPoint, _ joyCurrentPoint: CGPoint
                                            , _ didStartPan: inout Bool, _ translation: CGPoint, _ freezeReversePan: inout Bool // for preventing reversive pan
                                            ) -> CGPoint {
    
    let angle = getAngleInRadians(joyCenterPoint, joyCurrentPoint)
    let joyMoveDirection = getJoyMoveDirection_inStaticCameraMode(by: angle)
    
    
    //REVERSE PREVENT:
    if didStartPan {
        didStartPan = false
        freezeReversePan = reversePanDetected(translation: translation, velocityEnum: joyMoveDirection)
    } else {
        if reversePanDetected(translation: translation, velocityEnum: joyMoveDirection) == false {
            freezeReversePan = false
        }
    }
    
    
    var acceleration: CGFloat = 0
    if freezeReversePan == false {
    
        turn_inStaticCameraMode(node: heroNode, hero: hero, worldDirection: joyMoveDirection)
        
        let dist = pow(joyCurrentPoint.x - joyCenterPoint.x, 2) + pow(joyCurrentPoint.y - joyCenterPoint.y, 2)
        acceleration = CGFloat(dist > 4000 ? 0.03 : 0)
        hero.acceleration = acceleration > 0
    }
    
    var dx: CGFloat = 0.092 + acceleration
    var dy: CGFloat = 0.092 + acceleration
    
    let vectorVelocity = calcVelocity_inStaticCameraMode(joyMoveDirection, &dx, &dy)
    return vectorVelocity
}


private func calcVelocity_inStaticCameraMode(_ joyMoveDirection: WorldDirectionEnum, _ dx: inout CGFloat, _ dy: inout CGFloat) -> CGPoint {
    switch joyMoveDirection {
        case .east:
            dy = 0
        case .west:
            dx = -dx
            dy = 0
        case .north:
            dx = 0
            dy = -dy
        case .south:
            dx = 0
        case .northEast:
            dx = 0.062
            dy = -0.062
        case .southEast:
            dx = 0.062
            dy = 0.062
        case .northWest:
            dx = -0.062
            dy = -0.062
        case .southWest:
            dx = -0.062
            dy = 0.062
    }
    return CGPoint(x: dx, y: dy)
}




func turn_inStaticCameraMode(node: SCNNode, hero: Hero, worldDirection: WorldDirectionEnum) {
    
    var turnAction: SCNAction?
    let duration = 0.2
    var angle: CGFloat = 0
    
    switch worldDirection {
        case .east:
            angle = 90
        case .west:
            angle = -90
        case .north:
            angle = 180
        case .south:
            angle = 0
        case .northEast:
            angle = 135
        case .southEast:
            angle = 45
        case .northWest:
            angle = -135
        case .southWest:
            angle = -45
    }
    
    if hero.worldDirection != worldDirection {
        hero.worldDirection = worldDirection
        turnAction = SCNAction.rotateTo(x: 0, y: convertToRadians(angle: angle), z: 0, duration: duration, usesShortestUnitArc: true)
    }
    
    if let action = turnAction {
        node.runAction(action)
    }
}


private func getJoyMoveDirection_inStaticCameraMode(by angle: Double) -> WorldDirectionEnum {
    if 0...30  ~= angle ||  330...360  ~= angle {
        return .east
    }

    if 30...60  ~= angle {
        return .southEast
    }

    if 60...120  ~= angle  {
        return .south
    }

    if 120...150  ~= angle  {
        return .southWest
    }

    if 150...210  ~= angle  {
        return .west
    }

    if 210...240  ~= angle  {
        return .northWest
    }

    if 240...300  ~= angle  {
        return .north
    }

    return .northEast //300...330
}




//MARK:- dynamic mode

func getVelocity_inDynamicCameraMode(_ heroNode: SCNNode, _ hero: Hero
                                    , _ joyCenterPoint: CGPoint, _ joyCurrentPoint: CGPoint
                                    , _ didStartPan: inout Bool, _ translation: CGPoint, _ freezeReversePan: inout Bool // for preventing reversive pan
                                    ) -> CGPoint {
    
    let angle = getAngleInRadians(joyCenterPoint, joyCurrentPoint)
    let joyMoveDirection = getJoyMoveDirection_inStaticCameraMode(by: angle)
    
    //REVERSE PREVENT:
    if didStartPan {
        didStartPan = false
        freezeReversePan = reversePanDetected(translation: translation, velocityEnum: joyMoveDirection)
    } else {
        if reversePanDetected(translation: translation, velocityEnum: joyMoveDirection) == false {
            freezeReversePan = false
        }
    }
    
    
    var acceleration: CGFloat = 0
    if freezeReversePan == false {
        
        let joyMoveLocal = getJoyMoveDirection_inDynamicCameraMode(by: angle)
       
        turn_inDynamicCameraMode(node: heroNode, hero: hero, joyMoveDirection: joyMoveLocal)
        
        let dist = pow(joyCurrentPoint.x - joyCenterPoint.x, 2) + pow(joyCurrentPoint.y - joyCenterPoint.y, 2)
        acceleration = CGFloat(dist > 4000 ? 0.03 : 0)
        hero.acceleration = acceleration > 0
    }
    
    var dx: CGFloat = 0.092 + acceleration
    var dy: CGFloat = 0.092 + acceleration
    
    let vectorVelocity = calcVelocity_inDynamicCameraMode(hero, &dx, &dy)

    return vectorVelocity
}



private func calcVelocity_inDynamicCameraMode(_ hero: Hero, _ dx: inout CGFloat, _ dy: inout CGFloat) -> CGPoint {
    switch hero.worldDirection {
        case .east:
            dy = 0
        case .west:
            dx = -dx
            dy = 0
        case .north:
            dx = 0
            dy = -dy
        case .south:
            dx = 0
        case .northEast:
            dy = -dy
        case .southEast:
            break
        case .northWest:
            dx = -dx
            dy = -dy
        case .southWest:
            dx = -dx
    }

    return CGPoint(x: dx, y: dy)
}


private func getJoyMoveDirection_inDynamicCameraMode(by angle: Double) -> LocalDirectionEnum {
    if 0...30  ~= angle ||  330...360  ~= angle {
        return .right
    }

    if 31...60  ~= angle {
        return .backRight
    }

    if 61...120  ~= angle  {
        return .back
    }

    if 121...150  ~= angle  {
        return .backLeft
    }

    if 151...209  ~= angle  {
        return .left
    }

    if 210...240  ~= angle  {
        return .forwardLeft
    }

    if 241...300  ~= angle  {
        return .forward
    }

    return .forwardRight //300...330
}







func reversePanDetected(translation: CGPoint, velocityEnum: WorldDirectionEnum) -> Bool {
    
    let dx = translation.x
    let dy = translation.y

    switch velocityEnum {
        case .east:
            return dx <= 0
        case .west:
            return dx >= 0
        case .north:
            return dy >= 0
        case .south:
            return dy <= 0
        case .northEast:
            return dy >= 0 && dx <= 0
        case .southEast:
            return dy <= 0 && dx <= 0
        case .northWest:
            return dy >= 0 && dx >= 0
        case .southWest:
            return dy <= 0 && dx >= 0
    }
}



func turn_inDynamicCameraMode(node: SCNNode, hero: Hero, joyMoveDirection: LocalDirectionEnum) {

    guard joyMoveDirection != .forward else { return } // движение вперед, направление не меняется
    guard node.hasActions == false else { return }
    let newWorldDirection = convertLocal2World(hero, joyMoveDirection)
    
    let duration: TimeInterval = 0.5
    let angle = CGFloat(45 * joyMoveDirection.rawValue)
    
    let turnAction = SCNAction.rotateBy(x: 0, y: convertToRadians(angle: angle), z: 0, duration: duration)
    node.runAction(turnAction)
//    {
//        hero.worldDirection = newWorldDirection
//        hero.hudDelegate?.rotateYawCamera(by: convertToRadians(angle: angle), duration: duration)
//    }
   
    hero.worldDirection = newWorldDirection
    hero.hudDelegate?.rotateYawCamera(by: convertToRadians(angle: angle), duration: 2)
}


func convertToRadians(angle:CGFloat) -> CGFloat {
    return CGFloat(CGFloat(angle) * CGFloat(DegreesPerRadians))
}
