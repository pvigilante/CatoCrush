//
//  Swap.swift
//  CatoCrush
//
//  Created by Peter on 2014-09-08.
//  Copyright (c) 2014 Digital AG Studios. All rights reserved.
//

import Foundation

class Swap: Printable, Hashable {
    var programA: Program
    var programB: Program
    var hashValue: Int {
        return programA.hashValue ^ programB.hashValue
    }
    
    init(programA: Program, programB: Program) {
        self.programA = programA
        self.programB = programB
    }
    
    var description: String {
        return "swap \(programA) with \(programB)"
    }
}
func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.programA == rhs.programA && lhs.programB == rhs.programB) ||
        (lhs.programB == rhs.programA && lhs.programA == rhs.programB)
}