// MARK: - Helper Functions
func getSelectedMachineTier(for node: Node, preferences: MachinePreferences? = nil) -> MachineTier? {
    guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
          let tiers = MACHINE_TIERS[recipe.category] else {
        return nil
    }
    
    if let selectedTierID = node.selectedMachineTierID,
       let tier = tiers.first(where: { $0.id == selectedTierID }) {
        return tier
    }
    
    if let prefs = preferences,
       let defaultTierID = prefs.getDefaultTier(for: recipe.category),
       let tier = tiers.first(where: { $0.id == defaultTierID }) {
        return tier
    }
    
    return tiers.first
}

func canUseModule(_ module: Module, forRecipe recipe: Recipe) -> Bool {
    // Check if this is a productivity module
    if module.type == .productivity {
        // Check if the recipe produces any intermediate products
        let producesIntermediate = recipe.outputs.keys.contains { output in
            INTERMEDIATE_PRODUCTS.contains(output)
        }
        
        // Productivity modules can only be used on recipes that produce intermediates
        return producesIntermediate
    }
    
    // Quality modules have some restrictions too
    if module.type == .quality {
        // Quality modules can't be used on recipes that produce fluids
        // (Check if any output is a fluid - simplified check based on common fluids)
        let fluidOutputs: Set<String> = [
            "Water", "Steam", "Crude Oil", "Heavy Oil", "Light Oil", "Petroleum Gas",
            "Sulfuric Acid", "Lubricant", "Molten Iron", "Molten Copper", "Holmium Solution",
            "Ammonia", "Fluorine", "Nitrogen", "Hydrogen", "Oxygen", "Lava"
        ]
        
        let hasFluidOutput = recipe.outputs.keys.contains { output in
            fluidOutputs.contains(output)
        }
        
        // Can't use quality modules on fluid recipes
        if hasFluidOutput {
            return false
        }
    }
    
    // Speed and efficiency modules can be used on any recipe
    return true
}

func getEffectiveSpeed(for node: Node) -> Double {
    let baseSpeed = if let selectedTier = getSelectedMachineTier(for: node) {
        selectedTier.speed
    } else {
        1.0
    }
    
    let moduleSpeedBonus = node.totalSpeedBonus
    let effectiveSpeed = (baseSpeed * (1 + moduleSpeedBonus)) * node.speedMultiplier
    
    return max(Constants.minSpeed, effectiveSpeed)
}

func formatMachineCount(_ count: Double) -> String {
    if count == floor(count) {
        return String(format: "%.0f", count)
    } else {
        return String(format: "%.1f", count)
    }
}

func machineName(for category: String) -> String {
    switch category {
    case "assembling": return "Assembling Machine"
    case "smelting": return "Furnace"
    case "casting": return "Foundry"
    case "chemistry": return "Chemical Plant"
    case "cryogenic": return "Cryogenic Plant"
    case "biochamber": return "Biochamber"
    case "electromagnetic": return "Electromagnetic Plant"
    case "crushing": return "Crusher"
    case "recycling": return "Recycler"
    case "space-manufacturing": return "Space Platform"
    case "centrifuging": return "Centrifuge"
    case "rocket-building": return "Rocket Silo"
    case "mining": return "Mining Drill"
    case "quality": return "Quality Module"
    default: return category.capitalized
    }
}

func machineCount(for node: Node) -> Double {
    guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
        return 0
    }
    
    let outputAmount = recipe.outputs.values.first ?? 1
    let actualOutput = outputAmount * (1 + node.totalProductivityBonus)
    let craftsPerMin = (node.targetPerMin ?? 0) / actualOutput
    let machines = (craftsPerMin * recipe.time) / 60.0 / max(Constants.minSpeed, node.speed)
    
    return machines
}

func isPortConnected(nodeID: UUID, item: String, side: IOSide, edges: [Edge]) -> Bool {
    return edges.contains { edge in
        switch side {
        case .output:
            return edge.fromNode == nodeID && edge.item == item
        case .input:
            return edge.toNode == nodeID && edge.item == item
        }
    }
}

func isAlternativeRecipe(_ recipe: Recipe) -> Bool {
    return ALTERNATIVE_RECIPE_IDS.contains(recipe.id)
}
