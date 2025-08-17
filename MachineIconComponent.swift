// MARK: - Fixed Machine Icon Component

struct MachineIcon: View {
    var node: Node
    @EnvironmentObject var graph: GraphState
    
    var body: some View {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return AnyView(EmptyView())
        }
        
        let selectedTier = getSelectedMachineTier(for: node)
        let iconColor = machineIconColor(for: recipe.category)
        
        return AnyView(
            Group {
                if let tier = selectedTier, let assetName = tier.iconAsset {
                    Image(assetName)
                        .renderingMode(.original)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                } else if let assetName = ICON_ASSETS[recipe.category] {
                    Image(assetName)
                        .renderingMode(.original)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                } else {
                    Image(systemName: machineIconName(for: recipe.category))
                        .font(.title2)
                        .foregroundStyle(iconColor)
                }
            }
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(iconColor.opacity(0.3), lineWidth: 1)
                )
                .onTapGesture {
                    cycleMachineTier(for: node)
                }
                .hoverTooltip(selectedTier?.name ?? machineName(for: recipe.category))
        )
    }
    
    private func cycleMachineTier(for node: Node) {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
              let tiers = MACHINE_TIERS[recipe.category],
              tiers.count > 1 else {
            return
        }
        
        var updatedNode = node
        
        let currentIndex: Int
        if let selectedTierID = node.selectedMachineTierID,
           let index = tiers.firstIndex(where: { $0.id == selectedTierID }) {
            currentIndex = index
        } else {
            currentIndex = 0
        }
        
        let nextIndex = (currentIndex + 1) % tiers.count
        let nextTier = tiers[nextIndex]
        
        updatedNode.selectedMachineTierID = nextTier.id
        
        // Update module slots when tier changes
        updatedNode.modules = Array(repeating: nil, count: nextTier.moduleSlots)
        
        // FIXED: Use the graph's updateNode method
        graph.updateNode(updatedNode)
    }
    
    private func machineIconName(for category: String) -> String {
        switch category {
        case "assembling": return "gearshape.2"
        case "smelting", "casting": return "flame"
        case "chemistry", "cryogenic": return "flask"
        case "biochamber": return "leaf"
        case "electromagnetic": return "bolt"
        case "crushing", "recycling": return "hammer"
        case "space-manufacturing": return "sparkles"
        case "centrifuging": return "tornado"
        case "rocket-building": return "airplane"
        case "mining": return "cube"
        case "quality": return "star"
        default: return "gearshape"
        }
    }
    
    private func machineIconColor(for category: String) -> Color {
        switch category {
        case "assembling": return .blue
        case "smelting", "casting": return .orange
        case "chemistry", "cryogenic": return .green
        case "biochamber": return Color.green
        case "electromagnetic": return .purple
        case "crushing", "recycling": return .gray
        case "space-manufacturing": return .cyan
        case "centrifuging": return .yellow
        case "rocket-building": return .red
        case "mining": return .brown
        case "quality": return .yellow
        default: return .secondary
        }
    }
}

