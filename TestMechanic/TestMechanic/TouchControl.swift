//
//  TouchControl.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import UIKit
import SceneKit


class TouchController {
    
    
    var touchCenter: CGPoint = .zero
    var touchCurrent: CGPoint = .zero
    
    var moveVector: CGPoint = .zero
    var moveAction: SCNAction!
    var lastHeroPosition: SCNVector3 = .init(0, 0, 0)
    
    //used for improve performance:
    let sensitivity: CGFloat = 1 //low value -> low performance but accurate hero control
    var prevTouch: CGPoint = .zero
    var oldVelocity: CGPoint = .zero
    
    
    var panRecognizer: UIPanGestureRecognizer?
    var scnView: SCNView?
    
    
    func setup(panRecognizer: UIPanGestureRecognizer, scnView: SCNView){
        self.panRecognizer = panRecognizer
        self.scnView = scnView
    }
    
    /*
     Используется при тестировании
     нужно для получения max и min
     значений оффсетов передвижения героя.
     На основе этих значения затем настраивается
     метод getAcceptableVelocity
     */
    var testVelocityMinMax = false
    var highX: CGFloat = 0
    var lowX: CGFloat = 1000
    var highZ: CGFloat = 0
    var lowZ: CGFloat = 1000
    
    
    func calcVelocity(_ pt1: CGPoint,_ pt2: CGPoint) -> CGPoint {
        var dx = pt2.x - pt1.x
        var dy = pt2.y - pt1.y
        dx *=  0.001
        dy *=  0.001
        
        if testVelocityMinMax {
            if abs(highX) < abs(dx) { highX = abs(dx) }
            if abs(highZ) < abs(dy) { highZ = abs(dy) }
            if abs(lowX) > abs(dx) { lowX = abs(dx) }
            if abs(lowZ) > abs(dy) { lowZ = abs(dy) }
            print("\(highX) : \(highZ) -----  \(lowX) : \(lowZ)  ")
        }
        
        dx = getAcceptableVelocity(dx)
        dy = getAcceptableVelocity(dy)
        return CGPoint(x: dx, y: dy)
    }
    
    
    
    /*
     Позволяет задать дискретный диапазон скорости передвижения героя.
     */
    func getAcceptableVelocity(_ delta: CGFloat) -> CGFloat {
        if abs(delta) < 0.01 {
            return 0
        }
        
        let sign: CGFloat = delta > 0 ? 1 : -1
        
        if abs(delta) < 0.05 {
            return sign*0.05
        }
        
        if abs(delta) < 0.06 {
            return sign*0.06
        }
        
        if abs(delta) < 0.07 {
            return sign*0.07
        }
        
        if abs(delta) < 0.1 {
            return sign*0.1
        }
        return sign*0.15
    }
    
    
    /*
     Когда начальная точка находится далеко от текущего положения пальца
     то чтобы сменить знак движения героя на противоположный
     требуется проделать длинное обратное движение пальцем, проходя
     начальную точку как нулевую отметку.
     Чтобы это устранить периодически нужно "подтягивать" начальную точку
     к текущей, чтобы минимизировать расстояние между ними каждый раз
     до приемлимого уровня.
     */
    
    let maxDistanceBetweenCenterAndCurrent: CGFloat = 100
    let percentBetweenCenterAndCurrent: CGFloat = 0.5
    
    func offsetCenterPoint(centerPoint: CGPoint, currentPoint: CGPoint) -> CGPoint {
        let dx = currentPoint.x - centerPoint.x
        let dy = currentPoint.y - centerPoint.y
        if abs(dx) > maxDistanceBetweenCenterAndCurrent || abs(dy) > maxDistanceBetweenCenterAndCurrent {
            return CGPoint(x: centerPoint.x + dx*percentBetweenCenterAndCurrent, y: centerPoint.y + dy*percentBetweenCenterAndCurrent)
        }
        return centerPoint
    }
    
}



extension TouchController {
    
    func handleGesture() {
        guard let panRecognizer = panRecognizer else { return }
        
        switch panRecognizer.state {
        case .began:
            touchCenter = panRecognizer.translation(in: scnView)
            
        case .changed:
            if touchCenter == .zero {
                touchCenter = panRecognizer.translation(in: scnView)
            }
        case .ended, .failed:
            touchCenter = .zero
        default: break
        }
    }
    
    
    
    func move() -> SCNVector3? {
        guard touchCenter != .zero else { return nil }
        guard let panRecognizer = panRecognizer else { return nil }
        guard let scnView = scnView else { return nil }
        
        
        touchCurrent = panRecognizer.translation(in: scnView)
        
        if abs(prevTouch.x - touchCurrent.x) > sensitivity ||
            abs(prevTouch.y - touchCurrent.y) > sensitivity {
            let velocity = calcVelocity(touchCenter, touchCurrent)
            oldVelocity = velocity
            prevTouch = touchCurrent
        }
        
        let dx: CGFloat = CGFloat(lastHeroPosition.x) + oldVelocity.x
        let dz: CGFloat = CGFloat(lastHeroPosition.z) + oldVelocity.y
        
        let position = SCNVector3(dx, -1.5, dz)
        lastHeroPosition = position
        touchCenter = offsetCenterPoint(centerPoint: touchCenter, currentPoint: touchCurrent)
        return position
    }
}
