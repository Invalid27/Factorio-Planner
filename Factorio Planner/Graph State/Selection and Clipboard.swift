// MARK: - Selection and Clipboard Methods (FIXED)

func selectNode(_ nodeID: UUID?) {
    if let id = nodeID {
        selectedNodeIDs = [id]
    } else {
        selectedNodeIDs.removeAll()
    }
}

func toggleNodeSelection(_ nodeID: UUID) {
    if selectedNodeIDs.contains(nodeID) {
        selectedNodeIDs.remove(nodeID)
    } else {
        selectedNodeIDs.insert(nodeID)
    }
}

func selectNodes(in rect: CGRect) {
    selectedNodeIDs.removeAll()
    for (id, node) in nodes {
        let nodeRect = CGRect(x: node.x - 100, y: node.y - 50, width: 200, height: 100)
        if rect.intersects(nodeRect) {
            selectedNodeIDs.insert(id)
        }
    }
}

func copyNodes() {
    clipboard = selectedNodeIDs.compactMap { nodes[$0] }
    clipboardWasCut = false
}

func cutNodes() {
    clipboard = selectedNodeIDs.compactMap { nodes[$0] }
    clipboardWasCut = true
    for id in selectedNodeIDs {
        removeNode(id)
    }
    selectedNodeIDs.removeAll()
}

func pasteNodes() {
    guard !clipboard.isEmpty else { return }
    
    let offset = CGFloat(20)
    var newSelectedIDs: Set<UUID> = []
    
    for nodeToPaste in clipboard {
        var newNode = Node(
            recipeID: nodeToPaste.recipeID,
            x: lastMousePosition.x + offset,
            y: lastMousePosition.y + offset,
            targetPerMin: nodeToPaste.targetPerMin,
            speedMultiplier: nodeToPaste.speedMultiplier
        )
        newNode.selectedMachineTierID = nodeToPaste.selectedMachineTierID
        newNode.modules = nodeToPaste.modules
        
        nodes[newNode.id] = newNode
        newSelectedIDs.insert(newNode.id)
    }
    
    selectedNodeIDs = newSelectedIDs
    
    DispatchQueue.main.async {
        self.computeFlows()
    }
    
    if clipboardWasCut {
        clipboard.removeAll()
        clipboardWasCut = false
    }
}

func deleteSelectedNodes() {
    for id in selectedNodeIDs {
        removeNode(id)
    }
    selectedNodeIDs.removeAll()
}
