//
//  Hero.swift
//  TestMechanic
//
//  Created by Igor Ivanov on 13.12.2020.
//

import Foundation


class Hero {
    enum State {
        case walk, run, jump, stop
    }
    var state: State = .stop
}
