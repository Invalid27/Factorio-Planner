// MARK: - Recipe Model
struct Recipe: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var category: String
    var time: Double
    var inputs: [String: Double]
    var outputs: [String: Double]
}
