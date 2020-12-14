//
//  TrigonimetryHelper.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import UIKit


func calculateDirection(_ pt1: CGPoint,_ pt2: CGPoint) -> CGFloat {
    let a = pt2.x - pt1.x
    let b = pt2.y - pt1.y
    
    let angle = a < 0 ? atan(Double(b / a)) : atan(Double(b / a)) - Double.pi
    
    return CGFloat(angle)
}


func getQuarter(_ dX: CGFloat, _ dY: CGFloat) -> Int {
    if dX > 0 && dY > 0 {
        return 4
    }
    if dX > 0 && dY < 0 {
        return 1
    }
    if dX < 0 && dY > 0 {
        return 3
    }
    if dX < 0 && dY < 0 {
        return 2
    }
    return 0
}


