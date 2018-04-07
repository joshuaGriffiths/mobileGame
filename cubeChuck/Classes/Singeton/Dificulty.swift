//
//  Dificulty.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 4/6/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import Foundation

import Foundation

final class Dificulty {
    
    static let sharedInstance = Dificulty()
    private init() { }
    
    var numLifes = 3
    var numTowers = 4
}
