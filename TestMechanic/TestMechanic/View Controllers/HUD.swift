//
//  HUD.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 25.12.2020.
//

import UIKit



protocol HudDelegateProtocol {
    func updateHUD()
    func updateJoy(isAcceleration: Bool)
    func traceStates()
    func rotateYawCamera(by angle: CGFloat, duration: TimeInterval)
}

//MARK:- Collision
extension ViewController: HudDelegateProtocol  {
    
    
    func setupHUD(){
        hud.backgroundColor = .clear
        view.addSubview(hud)
        
        hud.translatesAutoresizingMaskIntoConstraints = false
        let hudLead = hud.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let hudBottom = hud.topAnchor.constraint(equalTo: view.topAnchor)
        let hudTrail = hud.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let hudHeight = hud.heightAnchor.constraint(equalToConstant: 48)
        view.addConstraints([hudLead, hudBottom, hudTrail, hudHeight])
        
        addHeroState()
    }
    
    
    func addHeroState(){
        heroStateLabel.numberOfLines = 0
        heroStateLabel.text = hero.state.rawValue
        hud.addSubview(heroStateLabel)
        
        heroStateLabel.translatesAutoresizingMaskIntoConstraints = false
        heroStateLabel.textColor = .white
        heroStateLabel.textAlignment = .center
        let stateLead = heroStateLabel.leadingAnchor.constraint(equalTo: hud.leadingAnchor)
        let stateTop = heroStateLabel.bottomAnchor.constraint(equalTo: hud.bottomAnchor)
        let stateTrail = heroStateLabel.trailingAnchor.constraint(equalTo: hud.trailingAnchor)
        view.addConstraints([stateLead, stateTop, stateTrail])
    }
    
    func updateHUD() {
//        if hero.state == Hero.State.fallDown {
//            DispatchQueue.main.async {
//                self.heroStateLabel.text = text
//            }
//        }
    }
    
    /*
        Нужно для удобства тестирования. Выводит на экран текущее состояние героя.
     */
    func traceStates(){
        
        if let last = heroStatesSeq.last {
            if last == hero.state.rawValue || last == Hero.State.fallDown.rawValue {
                return
            }
        }
        if heroStatesSeq.count > 4 {
            heroStatesSeq.removeFirst()
        }
        heroStatesSeq.append(hero.state.rawValue)
        var text = ""
        var prev = ""
        for t in heroStatesSeq {
            if prev != t {
                prev = t
                text += t + " -> "
            }
        }
        
        DispatchQueue.main.async {
            self.heroStateLabel.text = text
        }
    }
    
    
    func updateJoy(isAcceleration: Bool){
        DispatchQueue.main.async {
            if isAcceleration {
                UIView.animate(withDuration: 0.2) {
                    self.joyPanCircleLayer.fillColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).cgColor
                    impactFeedback()
                }
            } else  {
                UIView.animate(withDuration: 0.2) {
                    self.joyPanCircleLayer.fillColor = UIColor.clear.cgColor
                }
            }
        }
    }
}
