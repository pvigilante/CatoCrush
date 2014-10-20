//
//  Level.swift
//  CatoCrush
//
//  Created by Peter on 2014-09-08.
//  Copyright (c) 2014 Digital AG Studios. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9
let programs = Array2D<Program>(columns: NumColumns, rows: NumRows)  // private
let tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)  // private

class Level {
    
    var possibleSwaps = Set<Swap>()  // private
    let targetScore: Int!
    let maximumMoves: Int!
    var comboMultiplier: Int = 0  // private
    
    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    func programAtColumn(column: Int, row: Int) -> Program? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return programs[column, row]
    }
    
    
    func shuffle() -> Set<Program> {
        var set: Set<Program>
        do {
            set = createInitialPrograms()
            detectPossibleSwaps()
            println("possible swaps: \(possibleSwaps)")
        }
            while possibleSwaps.count == 0
        
        return set
    }
    
    func createInitialPrograms() -> Set<Program> {
        var set = Set<Program>()
        
        // 1
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                
                // 2
                if tiles[column, row] != nil {
                
                    var programType: ProgramType
                    do {
                        programType = ProgramType.random()
                    }
                        while (column >= 2 &&
                            programs[column - 1, row]?.programType == programType &&
                            programs[column - 2, row]?.programType == programType)
                            || (row >= 2 &&
                                programs[column, row - 1]?.programType == programType &&
                                programs[column, row - 2]?.programType == programType)
                
                    // 3
                    let program = Program(column: column, row: row, programType: programType)
                    programs[column, row] = program
                
                    // 4
                    set.addElement(program)
                }
            }
        }
        return set
    }
    
    init(filename: String) {
        // 1
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {
            // 2
            if let tilesArray: AnyObject = dictionary["tiles"] {
                // 3
                for (row, rowArray) in enumerate(tilesArray as [[Int]]) {
                    // 4
                    let tileRow = NumRows - row - 1
                    // 5
                    for (column, value) in enumerate(rowArray) {
                        if value == 1 {
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
                targetScore = (dictionary["targetScore"] as NSNumber).integerValue
                maximumMoves = (dictionary["moves"] as NSNumber).integerValue
            }
            
        }
    }
    
    func performSwap(swap: Swap) {
        let columnA = swap.programA.column
        let rowA = swap.programA.row
        let columnB = swap.programB.column
        let rowB = swap.programB.row
        
        programs[columnA, rowA] = swap.programB
        swap.programB.column = columnA
        swap.programB.row = rowA
        
        programs[columnB, rowB] = swap.programA
        swap.programA.column = columnB
        swap.programA.row = rowB
    }
    
    func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let programType = programs[column, row]!.programType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && programs[i, row]?.programType == programType;
            --i, ++horzLength { }
        for var i = column + 1; i < NumColumns && programs[i, row]?.programType == programType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && programs[column, i]?.programType == programType;
            --i, ++vertLength { }
        for var i = row + 1; i < NumRows && programs[column, i]?.programType == programType;
            ++i, ++vertLength { }
        return vertLength >= 3
    }
    
    func detectPossibleSwaps() {
        var set = Set<Swap>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let program = programs[column, row] {
                    
                    // TODO: detection logic goes here
                    // Is it possible to swap this cookie with the one on the right?
                    if column < NumColumns - 1 {
                        // Have a cookie in this spot? If there is no tile, there is no cookie.
                        if let other = programs[column + 1, row] {
                            // Swap them
                            programs[column, row] = other
                            programs[column + 1, row] = program
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column + 1, row: row) ||
                                hasChainAtColumn(column, row: row) {
                                    set.addElement(Swap(programA: program, programB: other))
                            }
                            
                            // Swap them back
                            programs[column, row] = program
                            programs[column + 1, row] = other
                        }
                    }
                    
                    if row < NumRows - 1 {
                        if let other = programs[column, row + 1] {
                            programs[column, row] = other
                            programs[column, row + 1] = program
                            
                            // Is either cookie now part of a chain?
                            if hasChainAtColumn(column, row: row + 1) ||
                                hasChainAtColumn(column, row: row) {
                                    set.addElement(Swap(programA: program, programB: other))
                            }
                            
                            // Swap them back
                            programs[column, row] = program
                            programs[column, row + 1] = other
                        }
                    }
                    
                }
            }
        }
        
        possibleSwaps = set
    }
    
    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.containsElement(swap)
    }
    
    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMatches()
        let verticalChains = detectVerticalMatches()
        
        removePrograms(horizontalChains)
        removePrograms(verticalChains)
        
        calculateScores(horizontalChains)
        calculateScores(verticalChains)
        
        return horizontalChains.unionSet(verticalChains)
    }
    
    func removePrograms(chains: Set<Chain>) {
        for chain in chains {
            for program in chain.programs {
                programs[program.column, program.row] = nil
            }
        }
    }
    
    func detectHorizontalMatches() -> Set<Chain> {
        // 1
        let set = Set<Chain>()
        // 2
        for row in 0..<NumRows {
            for var column = 0; column < NumColumns - 2 ; {
                // 3
                if let program = programs[column, row] {
                    let matchType = program.programType
                    // 4
                    if programs[column + 1, row]?.programType == matchType &&
                        programs[column + 2, row]?.programType == matchType {
                            // 5
                            let chain = Chain(chainType: .Horizontal)
                            do {
                                chain.addProgram(programs[column, row]!)
                                ++column
                            }
                                while column < NumColumns && programs[column, row]?.programType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                // 6
                ++column
            }
        }
        return set
    }
    
    func detectVerticalMatches() -> Set<Chain> {
        let set = Set<Chain>()
        
        for column in 0..<NumColumns {
            for var row = 0; row < NumRows - 2; {
                if let program = programs[column, row] {
                    let matchType = program.programType
                    
                    if programs[column, row + 1]?.programType == matchType &&
                        programs[column, row + 2]?.programType == matchType {
                            
                            let chain = Chain(chainType: .Vertical)
                            do {
                                chain.addProgram(programs[column, row]!)
                                ++row
                            }
                                while row < NumRows && programs[column, row]?.programType == matchType
                            
                            set.addElement(chain)
                            continue
                    }
                }
                ++row
            }
        }
        return set
    }
    
    func fillHoles() -> [[Program]] {
        var columns = [[Program]]()
        // 1
        for column in 0..<NumColumns {
            var array = [Program]()
            for row in 0..<NumRows {
                // 2
                if tiles[column, row] != nil && programs[column, row] == nil {
                    // 3
                    for lookup in (row + 1)..<NumRows {
                        if let program = programs[column, lookup] {
                            // 4
                            programs[column, lookup] = nil
                            programs[column, row] = program
                            program.row = row
                            // 5
                            array.append(program)
                            // 6
                            break
                        }
                    }
                }
            }
            // 7
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func topUpPrograms() -> [[Program]] {
        var columns = [[Program]]()
        var programType: ProgramType = .Unknown
        
        for column in 0..<NumColumns {
            var array = [Program]()
            // 1
            for var row = NumRows - 1; row >= 0 && programs[column, row] == nil; --row {
                // 2
                if tiles[column, row] != nil {
                    // 3
                    var newProgramType: ProgramType
                    do {
                        newProgramType = ProgramType.random()
                    } while newProgramType == programType
                    programType = newProgramType
                    // 4
                    let program = Program(column: column, row: row, programType: programType)
                    programs[column, row] = program
                    array.append(program)
                }
            }
            // 5
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
    
    func calculateScores(chains: Set<Chain>) {
        // 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
        for chain in chains {
            chain.score = 60 * (chain.length - 2) * comboMultiplier
            ++comboMultiplier
        }
    }
    func resetComboMultiplier() {
        comboMultiplier = 1
    }
    
}


