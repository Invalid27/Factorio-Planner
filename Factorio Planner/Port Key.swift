// MARK: - Port Key
struct PortKey: Hashable, Codable {
    var nodeID: UUID
    var item: String
    var side: IOSide
}

enum IOSide: String, Codable, CaseIterable {
    case input = "input"
    case output = "output"
    
    var opposite: IOSide {
        switch self {
        case .input: return .output
        case .output: return .input
        }
    }
}
