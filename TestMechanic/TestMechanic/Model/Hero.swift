//
//  Hero.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import Foundation


class Hero {
    enum State {
        case walk, run, longJump, willStand, stand, highJump
    }
    var count = 0
    var state: State = .stand {
        didSet {
            if state == .longJump {
                count += 1
            }
        }
    }
}
