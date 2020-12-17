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
    var state: State = .stand
    var direction: VelocityEnum = .down
}
