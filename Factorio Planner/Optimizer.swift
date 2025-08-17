// Add this to Graph State folder as Optimizer.swift

import Foundation

extension GraphState {
    
    struct OptimizationResult {
        let nodeID: UUID
        let recipeName: String
        let currentMachines: Double
        let optimalMachines: Double
        let efficiency: Double
        let bottleneck: Bool
    }
    
    func optimizeProductionChain() -> [OptimizationResult] {
        var results: [OptimizationResult] = []
        
        for (nodeID, node) in nodes {
            guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
                  let targetPerMin = node.targetPerMin,
                  targetPerMin > 0 else {
                continue
            }
            
            // Calculate actual production capacity
            let machineSpeed = node.speed
            let outputAmount = recipe.outputs.values.first ?? 1
            let actualOutput = outputAmount * (1 + node.totalProductivityBonus)
            let craftsPerCycle = actualOutput
            let cycleTime = recipe.time / machineSpeed
            let productionPerMachine = (60.0 / cycleTime) * craftsPerCycle
            
            // Calculate machines needed
            let optimalMachines = targetPerMin / productionPerMachine
            let currentMachines = ceil(optimalMachines) // Assume rounded up for now
            let efficiency = optimalMachines / currentMachines
            
            // Check if this is a bottleneck
            let isBottleneck = checkIfBottleneck(nodeID: nodeID, targetPerMin: targetPerMin)
            
            results.append(OptimizationResult(
                nodeID: nodeID,
                recipeName: recipe.name,
                currentMachines: currentMachines,
                optimalMachines: optimalMachines,
                efficiency: efficiency,
                bottleneck: isBottleneck
            ))
        }
        
        return results.sorted { $0.efficiency < $1.efficiency }
    }
    
    private func checkIfBottleneck(nodeID: UUID, targetPerMin: Double) -> Bool {
        // Check if this node can't meet demand from consumers
        var totalDemand: Double = 0
        
        for edge in edges where edge.fromNode == nodeID {
            guard let consumer = nodes[edge.toNode],
                  let consumerRecipe = RECIPES.first(where: { $0.id == consumer.recipeID }),
                  let consumerTarget = consumer.targetPerMin else {
                continue
            }
            
            let outputAmount = consumerRecipe.outputs.values.first ?? 1
            let actualOutput = outputAmount * (1 + consumer.totalProductivityBonus)
            let craftsPerMin = consumerTarget / actualOutput
            let inputAmount = consumerRecipe.inputs[edge.item] ?? 0
            totalDemand += craftsPerMin * inputAmount
        }
        
        return totalDemand > targetPerMin && totalDemand > 0
    }
    
    // Auto-balance a production chain to eliminate bottlenecks
    func autoBalance(startingNodeID: UUID? = nil) {
        guard let startNode = startingNodeID ?? nodes.keys.first else { return }
        
        // Start from the end products and work backwards
        var visited = Set<UUID>()
        var queue = [startNode]
        
        if startingNodeID == nil {
            // Find end nodes (nodes with no outgoing edges)
            let endNodes = nodes.keys.filter { nodeID in
                !edges.contains { $0.fromNode == nodeID }
            }
            queue = Array(endNodes)
        }
        
        while !queue.isEmpty {
            let currentID = queue.removeFirst()
            guard !visited.contains(currentID),
                  let node = nodes[currentID] else {
                continue
            }
            
            visited.insert(currentID)
            
            // Set a default target if not set
            if node.targetPerMin == nil {
                var updatedNode = node
                updatedNode.targetPerMin = 60.0 // Default to 1 per second
                nodes[currentID] = updatedNode
            }
            
            // Add upstream nodes to queue
            for edge in edges where edge.toNode == currentID {
                if !visited.contains(edge.fromNode) {
                    queue.append(edge.fromNode)
                }
            }
        }
        
        // Trigger flow computation to propagate changes
        computeFlows()
    }
}
