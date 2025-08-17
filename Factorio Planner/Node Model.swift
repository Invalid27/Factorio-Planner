// Node Model.swift
import Foundation
import CoreGraphics

// MARK: - Node Model
struct Node: Identifiable, Codable, Hashable {
    let id: UUID  // Changed from var to let
    var recipeID: String
    var x: CGFloat
    var y: CGFloat
    var targetPerMin: Double?
    var speedMultiplier: Double
    var selectedMachineTierID: String?
    var modules: [Module?] = []
    
    init(id: UUID = UUID(), recipeID: String, x: CGFloat, y: CGFloat, targetPerMin: Double? = nil, speedMultiplier: Double? = nil) {
        self.id = id  // Now properly initialized
        self.recipeID = recipeID
        self.x = x
        self.y = y
        self.targetPerMin = targetPerMin
        
        if let recipe = RECIPES.first(where: { $0.id == recipeID }), recipe.category == "cryogenic" {
            self.speedMultiplier = speedMultiplier ?? 2.0
        } else {
            self.speedMultiplier = speedMultiplier ?? 1.0
        }
    }
    
    var totalSpeedBonus: Double {
        return modules.compactMap { $0?.speedBonus }.reduce(0, +)
    }
    
    var totalProductivityBonus: Double {
        return modules.compactMap { $0?.productivityBonus }.reduce(0, +)
    }
    
    var totalEfficiencyBonus: Double {
        return modules.compactMap { $0?.efficiencyBonus }.reduce(0, +)
    }
    
    var speed: Double {
        return getEffectiveSpeed(for: self)
    }
}
