//
//  Program.swift
//  CatoCrush
//
//  Created by Peter on 2014-09-08.
//  Copyright (c) 2014 Digital AG Studios. All rights reserved.
//

import SpriteKit

enum ProgramType: Int, Printable {
    case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie
    
    var spriteName: String {
        let spriteNames = [
            "2d_animation",
            "audio_engineering",
            "digital_filmmaking",
            "digital_photography",
            "graphic_digital_design",
            "fashion_design"]
            
            return spriteNames[toRaw() - 1]
    }
    
    var highlightedSpriteName: String {
        let highlightedSpriteNames = [
            "2d_animation-Highlighted",
            "audio_engineering-Highlighted",
            "digital_filmmaking-Highlighted",
            "digital_photography-Highlighted",
            "graphic_digital_design-Highlighted",
            "fashion_design-Highlighted"]
            
            return highlightedSpriteNames[toRaw() - 1]
    }
    
    static func random() -> ProgramType {
        return ProgramType.fromRaw(Int(arc4random_uniform(6)) + 1)!
    }
    
    var description: String {
        return spriteName
    }
}

class Program: Printable, Hashable {
    var column: Int
    var row: Int
    let programType: ProgramType
    var sprite: SKSpriteNode?
    
    var description: String {
        return "type:\(programType) square:(\(column),\(row))"
    }
    
    init(column: Int, row: Int, programType: ProgramType) {
        self.column = column
        self.row = row
        self.programType = programType
    }
    
    var hashValue: Int {
        return row*10 + column
    }

}

func ==(lhs: Program, rhs: Program) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}