// MARK: - FIXED Node Management

@discardableResult
func addNode(recipeID: String, at point: CGPoint) -> Node {
    var node = Node(recipeID: recipeID, x: point.x, y: point.y)
    
    if let recipe = RECIPES.first(where: { $0.id == recipeID }),
       let tiers = MACHINE_TIERS[recipe.category] {
        let preferences = MachinePreferences.load()
        if let defaultTierID = preferences.getDefaultTier(for: recipe.category),
           tiers.contains(where: { $0.id == defaultTierID }) {
            node.selectedMachineTierID = defaultTierID
        }
        
        if let selectedTier = getSelectedMachineTier(for: node) {
            node.modules = Array(repeating: nil, count: selectedTier.moduleSlots)
        }
    }
    
    // FIXED: Update nodes dictionary directly and trigger computation
    nodes[node.id] = node
    selectedNodeIDs = [node.id]
    
    // FIXED: Delay computation to prevent conflicts
    DispatchQueue.main.async {
        self.computeFlows()
    }
    
    return node
}

func updateNode(_ node: Node) {
    // FIXED: Use main thread and prevent recursive updates
    guard !isComputing else { return }
    
    nodes[node.id] = node
    
    DispatchQueue.main.async {
        self.computeFlows()
    }
}

func setTarget(for nodeID: UUID, to value: Double?) {
    guard var node = nodes[nodeID] else { return }
    
    let newValue = value.map { max(0, $0) }
    
    // FIXED: Only update if value actually changed
    if node.targetPerMin != newValue {
        node.targetPerMin = newValue
        nodes[nodeID] = node
        
        DispatchQueue.main.async {
            self.computeFlows()
        }
    }
}

func addEdge(from: UUID, to: UUID, item: String) {
    guard from != to else { return }
    
    let edgeExists = edges.contains { edge in
        edge.fromNode == from && edge.toNode == to && edge.item == item
    }
    
    if !edgeExists {
        edges.append(Edge(fromNode: from, toNode: to, item: item))
        
        DispatchQueue.main.async {
            self.computeFlows()
        }
    }
}

func removeEdge(_ edge: Edge) {
    edges.removeAll { $0.id == edge.id }
    
    DispatchQueue.main.async {
        self.computeFlows()
    }
}

func removeNode(_ nodeID: UUID) {
    nodes.removeValue(forKey: nodeID)
    edges.removeAll { $0.fromNode == nodeID || $0.toNode == nodeID }
    
    DispatchQueue.main.async {
        self.computeFlows()
    }
}
