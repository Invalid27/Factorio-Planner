// MARK: - Manual Save/Load/Clear (FIXED)

func clearGraph() {
    // Temporarily disable auto-save
    saveTimer?.invalidate()
    
    nodes.removeAll()
    edges.removeAll()
    selectedNodeIDs.removeAll()
    
    // Re-enable auto-save and compute
    DispatchQueue.main.async {
        self.computeFlows()
    }
}

func hasAutoSave() -> Bool {
    return UserDefaults.standard.data(forKey: "FactorioPlannerAutoSave") != nil
}
