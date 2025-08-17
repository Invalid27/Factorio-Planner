// MARK: - Machine Tier System
struct MachineTier: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: String
    let speed: Double
    let iconAsset: String?
    let moduleSlots: Int
}
