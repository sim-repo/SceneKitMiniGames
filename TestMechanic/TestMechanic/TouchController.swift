//
//  TouchControl.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import UIKit
import SceneKit

// for test only: >>
var speedKf: CGFloat = 0
var speedType: SpeedType = .zero
enum SpeedType: String {
    case zero,one,two
}

var jumpHighKf: CGFloat = 0
var jumpDurationKf: Double = 1
var jumpDistanceKf: CGFloat = 60
// for test only: <<



class TouchController {
    
    var startAnchorPoint: CGPoint = .zero 
    var currentAnchorPoint: CGPoint = .zero
    
    var lastHeroPosition: SCNVector3 = .init(0, 0, 0)
    
    //used for improve performance:
    let sensitivity: CGFloat = 100 //low value -> low performance but accurate hero control
    var prevTouch: CGPoint = .zero
    var oldVelocity: CGPoint = .zero
    
    var panRecognizer = UIPanGestureRecognizer() // передвижение героя
    var tapRecognizer = UITapGestureRecognizer() // прыжки героя
    var doubleTapRecognizer = UITapGestureRecognizer() // прыжки героя
    var longRecongnizer = UILongPressGestureRecognizer()
    var scnView: SCNView!
    
    var heroNode: SCNNode!
    var hero = Hero()
    
    //for test only:
    
    func setup(scnView: SCNView, heroNode: SCNNode){
        self.scnView = scnView
        self.heroNode = heroNode
        
        panRecognizer.addTarget(self, action: #selector(handlePanGesture))
        panRecognizer.maximumNumberOfTouches = 1
        tapRecognizer.addTarget(self, action: #selector(handleTapGesture))
        tapRecognizer.numberOfTapsRequired = 1
        doubleTapRecognizer.addTarget(self, action: #selector(handleTapGesture))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(panRecognizer)
        scnView.addGestureRecognizer(tapRecognizer)
        //scnView.addGestureRecognizer(doubleTapRecognizer)
        
//        longRecongnizer.addTarget(self, action: #selector(handleTapGesture))
//        longRecongnizer.minimumPressDuration = 0.1
//        scnView.addGestureRecognizer(longRecongnizer)
    }
    
    
    
    func runStopWorkItem() {
        // инерция движения 0.1 мс после снятия нажатия:
        DispatchQueue.global().asyncAfter(deadline: .now()+0.14) {
            self.startAnchorPoint = .zero
        }
        // лаг времени, выделенный для того, чтобы успеть за 0.3 мс нажать прыжок
        DispatchQueue.global().asyncAfter(deadline: .now()+0.4) {
            self.hero.state = .stop
        }
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
    

    
    func calcSpeedType(dx: CGFloat, dy: CGFloat) {
        let delta = max(abs(dx), abs(dy))
        if delta == 0 {
            speedType = .zero
        }
        if delta == (0.1 + speedKf) {
            speedType = .one
        }
        if delta == (0.2 + speedKf) {
            speedType = .two
        }
    }
    
    
    func calcVelocity(_ pt1: CGPoint,_ pt2: CGPoint) -> CGPoint {
        var dx = pt2.x - pt1.x
        var dy = pt2.y - pt1.y
        dx *=  (0.001 + speedKf)
        dy *=  (0.001 + speedKf)
        
        dx = getAcceptableVelocity(dx)
        dy = getAcceptableVelocity(dy)
        calcSpeedType(dx: dx, dy: dy)
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
        
        if abs(delta) <= (0.1 + speedKf) {
            return sign*(0.1 + speedKf)
        }
        
        return sign*(0.2 + speedKf)
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
    
    @objc func handleTapGesture() {
        if hero.state == .run || hero.state == .stop {
            jump()
        }
    }
}



//MARK:- Movement
extension TouchController {
    
    @objc func handlePanGesture() {
        switch panRecognizer.state {
        case .began:
            startAnchorPoint = panRecognizer.translation(in: scnView)
            hero.state = .run
        case .changed:
            if startAnchorPoint == .zero {
                startAnchorPoint = panRecognizer.translation(in: scnView)
                hero.state = .run
            }
        case .ended, .failed:
            runStopWorkItem()

        default: break
        }
    }
    
    
    
    func move(){
        guard startAnchorPoint != .zero else { return }

        currentAnchorPoint = panRecognizer.translation(in: scnView)
        
        if currentAnchorPoint.x != 0 || currentAnchorPoint.y != 0 &&
            (abs(prevTouch.x - currentAnchorPoint.x) > sensitivity ||
            abs(prevTouch.y - currentAnchorPoint.y) > sensitivity) {
            let velocity = getVelocity(startPoint: startAnchorPoint, nextPoint: currentAnchorPoint)
            oldVelocity = velocity
            prevTouch = currentAnchorPoint
        }
        
        let newX = CGFloat(lastHeroPosition.x) + oldVelocity.x
        let newZ = CGFloat(lastHeroPosition.z) + oldVelocity.y
       
        let moveTo = SCNVector3(newX, CGFloat(heroNode.presentation.worldPosition.y), newZ)
        lastHeroPosition = moveTo
        startAnchorPoint = offsetCenterPoint(centerPoint: startAnchorPoint, currentPoint: currentAnchorPoint)
        heroNode.position = moveTo
    }
}



//MARK:- Jumping
extension TouchController {
    func jump() {
        print(hero.state)
        guard hero.state != .jump else { return }
        hero.state = .jump
        let duration = jumpDurationKf
        
        // Bounce:
        let bounceUpAction = SCNAction.moveBy(x: 0, y: calcJumpHigh(), z: 0, duration: duration * 0.5)
        let bounceDownAction = SCNAction.moveBy(x: 0, y: -1*calcJumpHigh(), z: 0, duration: duration * 0.5)
        bounceUpAction.timingMode = .easeOut
        bounceDownAction.timingMode = .easeIn
        let bounceAction = SCNAction.sequence([bounceUpAction, bounceDownAction])
        
        // Moving:
        let moveAction = SCNAction.moveBy(x: CGFloat(jumpDistanceKf*oldVelocity.x), y: 0, z: CGFloat(jumpDistanceKf*oldVelocity.y), duration: duration*0.7)
        let customAction = SCNAction.customAction(duration: duration) {_,_ in
            self.lastHeroPosition = self.heroNode.position
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now()+duration) {
            self.lastHeroPosition = self.heroNode.position
            self.hero.state = .stop
        }
        
        let jump = SCNAction.group([bounceAction, moveAction])
        let seq = SCNAction.sequence([jump, customAction])
        heroNode.runAction(seq)
    }
    
    
    func calcJumpHigh() -> CGFloat {
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
