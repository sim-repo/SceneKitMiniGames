//
//  RecognizerDirection.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import UIKit

public enum Direction: Int {
    case up
    case down
    case left
    case right

    public var isX: Bool { return self == .left || self == .right }
    public var isY: Bool { return !isX }
}


public extension UIPanGestureRecognizer {
     var direction: Direction? {
        let vel = velocity(in: view)
        
        let isVertical = abs(vel.y) > abs(vel.x)
        switch (isVertical, vel.x, vel.y) {
            case (true, _, let y) where y < 0: return .up
            case (true, _, let y) where y > 0: return .down
            case (false, let x, _) where x > 0: return .right
            case (false, let x, _) where x < 0: return .left
            default: return nil
        }
    }
}
