class Chain: Hashable, Printable {
    var programs = [Program]()  // private
    var score: Int = 0
    
    enum ChainType: Printable {
        case Horizontal
        case Vertical
        
        var description: String {
            switch self {
            case .Horizontal: return "Horizontal"
            case .Vertical: return "Vertical"
                }
        }
    }
    
    var chainType: ChainType
    
    init(chainType: ChainType) {
        self.chainType = chainType
    }
    
    func addProgram(program: Program) {
        programs.append(program)
    }
    
    func firstProgram() -> Program {
        return programs[0]
    }
    
    func lastProgram() -> Program {
        return programs[programs.count - 1]
    }
    
    var length: Int {
        return programs.count
    }
    
    var description: String {
        return "type:\(chainType) programs:\(programs)"
    }
    
    var hashValue: Int {
        return reduce(programs, 0) { $0.hashValue ^ $1.hashValue }
    }
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
    return lhs.programs == rhs.programs
}