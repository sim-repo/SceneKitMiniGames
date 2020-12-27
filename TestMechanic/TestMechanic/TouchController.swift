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
    
    var joyCenterPoint: CGPoint = .zero 
    var joyCurrentPoint: CGPoint = .zero
    
    var lastHeroPosition: SCNVector3 = .init(0, 0, 0)
    
    var velocity: CGPoint = .zero

    /*
     didStartPan/freezeReversePan - нужны для предовращения нежелательного эффекта реверсивного движения героя,
     когда первое касание и движение пальца начинается в обратную сторону предполагаемого направления в заданном секторе.
     */
    var didStartPan = true
    var freezeReversePan = false
    
    var panRecognizer = UIPanGestureRecognizer() // передвижение героя
    var tapRecognizer = UITapGestureRecognizer() // прыжки героя
    var doubleTapRecognizer = UITapGestureRecognizer() // прыжки героя
    var longRecongnizer = UILongPressGestureRecognizer()
    
    
    var panView: UIView!
    var heroNode: SCNNode!
    var hero: Hero!
    
    /*
        Проверка, что правый палец находится на экране. Как только палец поднимается от экрана, то
        при long jump герой не переходит в состояние run, после приземления.
     */
    var isPanningNow = false
    
    
    var game = GameHelper.shared
    
    

    func setup(panView: UIView, tapView: UIView, heroNode: SCNNode, heroModel: Hero){
        self.panView = panView
        self.heroNode = heroNode
        self.hero = heroModel
        
        panRecognizer.addTarget(self, action: #selector(handlePanGesture))
        panRecognizer.maximumNumberOfTouches = 1
        tapRecognizer.addTarget(self, action: #selector(handleTapGesture))
        tapRecognizer.numberOfTapsRequired = 1
        panView.addGestureRecognizer(panRecognizer)
        tapView.addGestureRecognizer(tapRecognizer)
    }


    func setCenterPoint() {
        DispatchQueue.main.sync {
            joyCenterPoint = CGPoint(x: panView.frame.size.width/2, y: panView.frame.size.height/2)
        }
    }
    
    
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
    
    let maxDistanceBetweenCenterAndCurrent: CGFloat = 50
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


//MARK:- Init Jump
extension TouchController {
    @objc func handleTapGesture() {
        if hero.state == .run {
            game.playSound(heroNode, name: "Jump")
            longJump()
        } else
        if hero.state == .stand {
            game.playSound(heroNode, name: "Jump")
            highJump()
        }
    }
}



//MARK:- Init Move or Fly
extension TouchController {
    
    @objc func handlePanGesture() {
        if hero.state == .run ||  hero.state == .stand {
            handleMove()
        } else if hero.state ==  .longJump ||  hero.state ==  .highJump {
            handleFly()
        }
    }
    
    
    func handleMove() {
    
        switch panRecognizer.state {
            case .began:
                didStartPan = true // предотвращяем реверс
                
                joyCurrentPoint = panRecognizer.location(in: panView)
                hero.state = .run
                
            case .changed:
                if joyCurrentPoint == .zero {
                    didStartPan = true // предотвращяем реверс
                    joyCurrentPoint = panRecognizer.location(in: panView)
                }
                hero.state = .run
                
                
            case .ended, .failed:
                didStartPan = false // предотвращяем реверс
                isPanningNow = false // нужно для перехода в stand после long jump
                joyCurrentPoint = .zero
                hero.state = .stand
            default: break
        }
    }
    
    
    func handleFly() {
        switch panRecognizer.state {
            case .began:
                joyCurrentPoint = panRecognizer.translation(in: panView)
                isPanningNow = true // нужно для перехода в run после long jump
            case .changed:
                if joyCurrentPoint == .zero {
                    joyCurrentPoint = panRecognizer.translation(in: panView)
                }
                isPanningNow = true // нужно для перехода в run после long jump
                
            case .ended, .failed:
                joyCurrentPoint = .zero
                isPanningNow = false // нужно для перехода в stand после long jump
            default:
                break
        }
    }
}



//MARK:- Movement
extension TouchController {
    
    func tryMove() {
        guard hero.state != .stand && hero.state != .fallDown  else { return }
        guard joyCurrentPoint != .zero else { return }
        
        if joyCenterPoint == .zero {
            setCenterPoint()
        }
            
        joyCurrentPoint = panRecognizer.location(in: panView)
        let translatePoint = panRecognizer.translation(in: panView)
        
        velocity = getVelocity(heroNode, hero, joyCenterPoint, joyCurrentPoint, &didStartPan, translatePoint, &freezeReversePan)

        if freezeReversePan == false  {
            let newX = CGFloat(heroNode.presentation.worldPosition.x) + velocity.x
            let newZ = CGFloat(heroNode.presentation.worldPosition.z) + velocity.y
            
            let moveTo = SCNVector3(newX, CGFloat(heroNode.presentation.worldPosition.y), newZ)
            lastHeroPosition = moveTo
            heroNode.position = moveTo
        }
    }
}
