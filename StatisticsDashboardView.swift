// Statistics Dashboard View

import SwiftUI

struct StatisticsDashboard: View {
    @EnvironmentObject var graph: GraphState
    @State private var showOptimizer = false
    
    private var statistics: ProductionStatistics {
        graph.calculateStatistics()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Production Statistics")
                    .font(.headline)
                
                Spacer()
                
                Button("Optimize") {
                    showOptimizer = true
                }
                .buttonStyle(.borderedProminent)
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Total Inputs Section
                    ResourceSection(
                        title: "Total Inputs Required",
                        items: statistics.totalInputs,
                        color: .blue
                    )
                    
                    // Total Outputs Section
                    ResourceSection(
                        title: "Total Production",
                        items: statistics.totalOutputs,
                        color: .green
                    )
                    
                    // Machine Count Section
                    MachineSection(machines: statistics.machinesNeeded)
                    
                    // Power Consumption
                    PowerSection(totalPower: statistics.totalPowerMW)
                    
                    // Bottlenecks
                    if !statistics.bottlenecks.isEmpty {
                        BottleneckSection(bottlenecks: statistics.bottlenecks)
                    }
                }
                .padding()
            }
        }
        .frame(width: 350, height: 600)
        .padding()
        .sheet(isPresented: $showOptimizer) {
            OptimizerView()
        }
    }
}

struct ResourceSection: View {
    let title: String
    let items: [String: Double]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            
            ForEach(items.sorted(by: { $0.value > $1.value }), id: \.key) { item, amount in
                HStack {
                    IconOrMonogram(item: item, size: 20)
                    
                    Text(item)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(formatAmount(amount))
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    
                    Text("/min")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1000 {
            return String(format: "%.1fk", amount / 1000)
        } else if amount == floor(amount) {
            return String(format: "%.0f", amount)
        } else {
            return String(format: "%.1f", amount)
        }
    }
}

struct MachineSection: View {
    let machines: [String: Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Machines Required")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.orange)
            
            ForEach(machines.sorted(by: { $0.value > $1.value }), id: \.key) { machine, count in
                HStack {
                    if let iconAsset = ICON_ASSETS[machine] {
                        Image(iconAsset)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    
                    Text(machine)
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PowerSection: View {
    let totalPower: Double
    
    var body: some View {
        HStack {
            Image(systemName: "bolt.fill")
                .foregroundStyle(.yellow)
            
            Text("Total Power Consumption")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text(String(format: "%.1f MW", totalPower))
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

struct BottleneckSection: View {
    let bottlenecks: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                
                Text("Bottlenecks Detected")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
            }
            
            ForEach(bottlenecks, id: \.self) { bottleneck in
                Text("• \(bottleneck)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// Statistics calculation extension
extension GraphState {
    struct ProductionStatistics {
        let totalInputs: [String: Double]
        let totalOutputs: [String: Double]
        let machinesNeeded: [String: Int]
        let totalPowerMW: Double
        let bottlenecks: [String]
    }
    
    func calculateStatistics() -> ProductionStatistics {
        var totalInputs: [String: Double] = [:]
        var totalOutputs: [String: Double] = [:]
        var machinesNeeded: [String: Int] = [:]
        var totalPower: Double = 0
        var bottlenecks: [String] = []
        
        // Calculate for each node
        for (nodeID, node) in nodes {
            guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
                  let targetPerMin = node.targetPerMin,
                  targetPerMin > 0 else {
                continue
            }
            
            // Calculate machines needed
            let machineSpeed = node.speed
            let outputAmount = recipe.outputs.values.first ?? 1
            let actualOutput = outputAmount * (1 + node.totalProductivityBonus)
            let cycleTime = recipe.time / machineSpeed
            let productionPerMachine = (60.0 / cycleTime) * actualOutput
            let machines = Int(ceil(targetPerMin / productionPerMachine))
            
            // Get machine name
            if let tier = getSelectedMachineTier(for: node) {
                machinesNeeded[tier.name, default: 0] += machines
                
                // Estimate power consumption (simplified)
                let basePower = getBasePowerConsumption(for: recipe.category)
                let efficiencyFactor = 1.0 + node.totalEfficiencyBonus
                totalPower += basePower * Double(machines) * max(0.2, efficiencyFactor)
            }
            
            // Calculate actual crafts per minute
            let craftsPerMin = targetPerMin / actualOutput
            
            // Add inputs
            for (item, amount) in recipe.inputs {
                // Check if this input has a supplier
                let hasSupplier = edges.contains { $0.toNode == nodeID && $0.item == item }
                if !hasSupplier {
                    totalInputs[item, default: 0] += craftsPerMin * amount
                }
            }
            
            // Add outputs (only if not consumed by another node)
            for (item, amount) in recipe.outputs {
                let hasConsumer = edges.contains { $0.fromNode == nodeID && $0.item == item }
                if !hasConsumer {
                    totalOutputs[item, default: 0] += targetPerMin * (item == recipe.outputs.keys.first ? 1 : amount / (recipe.outputs.values.first ?? 1))
                }
            }
            
            // Check for bottlenecks
            let optimizationResults = optimizeProductionChain()
            for result in optimizationResults where result.bottleneck {
                bottlenecks.append(result.recipeName)
            }
        }
        
        return ProductionStatistics(
            totalInputs: totalInputs,
            totalOutputs: totalOutputs,
            machinesNeeded: machinesNeeded,
            totalPowerMW: totalPower,
            bottlenecks: bottlenecks
        )
    }
    
    private func getBasePowerConsumption(for category: String) -> Double {
        // Base power consumption in MW for each machine type
        switch category {
        case "assembling": return 0.375  // Assembling Machine 3
        case "smelting": return 0.18     // Electric Furnace
        case "chemistry": return 0.21    // Chemical Plant
        case "casting": return 0.5       // Foundry
        case "electromagnetic": return 2.0 // Electromagnetic Plant
        case "cryogenic": return 10.0    // Cryogenic Plant
        case "centrifuging": return 0.35 // Centrifuge
        default: return 0.2
        }
    }
}
