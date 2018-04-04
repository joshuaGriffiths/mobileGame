//
//  Score.swift
//  cubeChuck
//
//  Created by Joshua Griffiths on 4/4/18.
//  Copyright © 2018 Joshua Griffiths. All rights reserved.
//

import Foundation

final class Score {
    
    static let sharedInstance = Score()
    private init() { }
    
    var value = 0
}
