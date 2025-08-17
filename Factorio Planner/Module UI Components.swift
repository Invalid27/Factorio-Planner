// MARK: - Module UI Components
struct ModuleSlotsView: View {
    @EnvironmentObject var graph: GraphState
    var node: Node
    var slotCount: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Modules")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 2) {
                ForEach(0..<slotCount, id: \.self) { index in
                    ModuleSlot(node: node, slotIndex: index)
                }
            }
        }
    }
}

struct ModuleSlot: View {
    @EnvironmentObject var graph: GraphState
    var node: Node
    var slotIndex: Int
    @State private var showModulePicker = false
    
    private var hasRestrictions: Bool {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return false
        }
        
        // Check if productivity modules are restricted
        let testProductivityModule = Module(
            id: "test", name: "Test", type: .productivity, level: 1,
            quality: .normal, speedBonus: 0, productivityBonus: 0.1,
            efficiencyBonus: 0, iconAsset: nil
        )
        
        return !canUseModule(testProductivityModule, forRecipe: recipe)
    }
    
    var body: some View {
        Button(action: {
            showModulePicker = true
        }) {
            Group {
                if slotIndex < node.modules.count, let module = node.modules[slotIndex] {
                    ModuleIcon(module: module, size: 12)
                } else {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: hasRestrictions ? "plus.circle" : "plus")
                                .font(.system(size: 6))
                                .foregroundStyle(hasRestrictions ? .orange : .secondary)
                        )
                        .frame(width: 12, height: 12)
                }
            }
        }
        .buttonStyle(.plain)
        .help(hasRestrictions ? "This recipe has module restrictions" : "Add module")
        .sheet(isPresented: $showModulePicker) {
            ModulePicker(node: node, slotIndex: slotIndex)
        }
    }
}

struct ModuleIcon: View {
    var module: Module
    var size: CGFloat = 18
    
    var body: some View {
        Group {
            if let assetName = module.iconAsset {
                Image(assetName)
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(module.type.color.opacity(0.8))
                    .overlay(
                        Text(String(module.type.rawValue.first ?? "M"))
                            .font(.system(size: size * 0.5, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(module.quality.color, lineWidth: 1)
        )
        .hoverTooltip(module.displayName)
    }
}

struct ModuleStatsView: View {
    var node: Node
    
    var body: some View {
        VStack(spacing: 1) {
            if node.totalSpeedBonus != 0 {
                HStack(spacing: 2) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 8))
                    Text(formatBonus(node.totalSpeedBonus))
                        .font(.system(size: 8))
                        .monospacedDigit()
                }
                .foregroundStyle(node.totalSpeedBonus > 0 ? .green : .red)
            }
            
            if node.totalProductivityBonus != 0 {
                HStack(spacing: 2) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 8))
                    Text(formatBonus(node.totalProductivityBonus))
                        .font(.system(size: 8))
                        .monospacedDigit()
                }
                .foregroundStyle(.orange)
            }
            
            if node.totalEfficiencyBonus != 0 {
                HStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 8))
                    Text(formatBonus(node.totalEfficiencyBonus))
                        .font(.system(size: 8))
                        .monospacedDigit()
                }
                .foregroundStyle(node.totalEfficiencyBonus > 0 ? .green : .red)
            }
        }
    }
    
    private func formatBonus(_ value: Double) -> String {
        let percentage = value * 100
        let sign = percentage >= 0 ? "+" : ""
        return "\(sign)\(Int(percentage))%"
    }
}
