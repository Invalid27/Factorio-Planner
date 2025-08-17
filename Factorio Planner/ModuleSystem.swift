// MARK: - Module System
enum ModuleType: String, Codable, CaseIterable {
    case speed = "Speed"
    case productivity = "Productivity"
    case efficiency = "Efficiency"
    case quality = "Quality"
    
    var color: Color {
        switch self {
        case .speed: return .blue
        case .productivity: return .red
        case .efficiency: return .green
        case .quality: return .yellow
        }
    }
}

enum Quality: String, Codable, CaseIterable {
    case normal = "Normal"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .normal: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var multiplier: Double {
        switch self {
        case .normal: return 1.0
        case .uncommon: return 1.3
        case .rare: return 1.6
        case .epic: return 1.9
        case .legendary: return 2.5
        }
    }
}

struct Module: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: ModuleType
    let level: Int
    let quality: Quality
    let speedBonus: Double
    let productivityBonus: Double
    let efficiencyBonus: Double
    let iconAsset: String?
    
    var displayName: String {
        "\(name) (\(quality.rawValue))"
    }
}
