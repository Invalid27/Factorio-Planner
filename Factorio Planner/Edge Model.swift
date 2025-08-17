// Edge Model.swift
import Foundation

// MARK: - Edge Model
struct Edge: Identifiable, Codable, Hashable {
    let id: UUID  // Changed from var to let
    var fromNode: UUID
    var toNode: UUID
    var item: String
    
    init(id: UUID = UUID(), fromNode: UUID, toNode: UUID, item: String) {
        self.id = id
        self.fromNode = fromNode
        self.toNode = toNode
        self.item = item
    }
}
