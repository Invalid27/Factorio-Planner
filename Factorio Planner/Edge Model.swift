// MARK: - Edge Model
struct Edge: Identifiable, Codable, Hashable {
    var id = UUID()
    var fromNode: UUID
    var toNode: UUID
    var item: String
}
