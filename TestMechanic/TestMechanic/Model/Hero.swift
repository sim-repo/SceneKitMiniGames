//
//  Hero.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import UIKit
import SceneKit

class Hero {
    
    enum State: String {
        case run="бегу", longJump="прыжок", stand="стою", highJump="вверх", fallDown="падаю"
    }
    
    enum Affection {
        case gravity
    }
    
    
    enum CameraMode {
        case statically, dynamically
    }
    
    
    var state: State = .stand {
        willSet {
            if newValue == .stand {
                acceleration = false
            }
        }
        didSet {
            hudDelegate?.updateHUD()
        }
    }
    
    var worldDirection: WorldDirectionEnum = .north
    
    
    var size: CGSize! {
        didSet {
            halfSize = CGSize(width: size.width / 2, height: size.height / 2)
        }
    }
    var halfSize: CGSize!
    
    /*
     Среда, которая воздействует на героя.
     Влияет на переход в следующее состояние героя (state).
     Например, при воздействии антигравитационного поля герой может, летая, менять направление (run), но не может войти в состояние свободного падения (fallDown).
     
     */
    var affectedBy: Affection?
    
    /*
     Присваивается значение позиции Y перед прыжком.
     Нужно для определения находится ли player в состоянии падения или в состоянии прыжка.
     */
    var lastPosY: Float?
    
    var acceleration = false { // ускорение геро
        willSet {
            if newValue != acceleration {
                hudDelegate?.updateJoy(isAcceleration: newValue)
            }
        }
    }
    
    var hudDelegate: HudDelegateProtocol?
    
    
    var cameraMode: CameraMode = .statically
    
    init(hudDelegate: HudDelegateProtocol){
        self.hudDelegate = hudDelegate
    }
    
    
    func getHeroTop(_ node: SCNNode) -> CGFloat {
        return CGFloat(node.position.y) + halfSize.height
    }
}
