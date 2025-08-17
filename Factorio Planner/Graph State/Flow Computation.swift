// MARK: - FIXED Flow Computation

func computeFlows() {
    // FIXED: Ensure we're on main thread and prevent recursive calls
    guard Thread.isMainThread else {
        DispatchQueue.main.async {
            self.computeFlows()
        }
        return
    }
    
    guard !isComputing else {
        pendingCompute = true
        return
    }
    
    isComputing = true
    
    defer {
        isComputing = false
        if pendingCompute {
            pendingCompute = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.computeFlows()
            }
        }
    }
    
    var newTargets: [UUID: Double] = [:]
    
    // Initialize with current targets
    for (id, node) in nodes {
        newTargets[id] = node.targetPerMin ?? 0
    }
    
    var hasChanges = true
    var iterations = 0
    let maxIterations = 10
    
    while hasChanges && iterations < maxIterations {
        hasChanges = false
        iterations += 1
        
        var needBySupplier: [UUID: Double] = [:]
        
        for edge in edges {
            guard let consumer = nodes[edge.toNode],
                  let recipe = RECIPES.first(where: { $0.id == consumer.recipeID }) else {
                continue
            }
            
            let outputAmount = recipe.outputs.values.first ?? 1
            let actualOutput = outputAmount * (1 + consumer.totalProductivityBonus)
            let craftsPerMin = (newTargets[consumer.id] ?? 0) / actualOutput
            let inputAmount = recipe.inputs[edge.item] ?? 0
            let totalNeed = craftsPerMin * inputAmount
            
            switch aggregate {
            case .sum:
                needBySupplier[edge.fromNode, default: 0] += totalNeed
            case .max:
                needBySupplier[edge.fromNode] = max(needBySupplier[edge.fromNode] ?? 0, totalNeed)
            }
        }
        
        for (supplierID, need) in needBySupplier {
            let currentTarget = newTargets[supplierID] ?? 0
            if abs(currentTarget - need) > Constants.computationTolerance {
                newTargets[supplierID] = need
                hasChanges = true
            }
        }
    }
    
    // FIXED: Update nodes without triggering didSet recursively
    var updatedNodes = nodes
    var anyChanges = false
    
    for (id, targetValue) in newTargets {
        guard var node = updatedNodes[id] else { continue }
        let roundedTarget = abs(targetValue - round(targetValue)) < 0.01 ? round(targetValue) : round(targetValue * 10) / 10
        
        if abs((node.targetPerMin ?? 0) - roundedTarget) > Constants.computationTolerance {
            node.targetPerMin = roundedTarget
            updatedNodes[id] = node
            anyChanges = true
        }
    }
    
    // FIXED: Only update if there were actual changes
    if anyChanges {
        // Temporarily disable auto-save during bulk update
        let timer = saveTimer
        saveTimer?.invalidate()
        
        nodes = updatedNodes
        
        // Restore auto-save timer
        saveTimer = timer
    }
}
