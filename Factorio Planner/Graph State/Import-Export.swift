// MARK: - Import/Export (FIXED)

func exportJSON(from window: NSWindow?) {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [.json]
    savePanel.nameFieldStringValue = "factorio_cards_plan.json"
    
    let targetWindow = window ?? NSApp.keyWindow
    
    savePanel.beginSheetModal(for: targetWindow!) { [weak self] response in
        guard response == .OK, let url = savePanel.url, let self = self else { return }
        
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: url)
        } catch {
            DispatchQueue.main.async {
                NSAlert(error: error).runModal()
            }
        }
    }
}

func importJSON(from window: NSWindow?) {
    let openPanel = NSOpenPanel()
    openPanel.allowedContentTypes = [.json]
    
    let targetWindow = window ?? NSApp.keyWindow
    
    openPanel.beginSheetModal(for: targetWindow!) { [weak self] response in
        guard response == .OK, let url = openPanel.url, let self = self else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let graphState = try JSONDecoder().decode(GraphState.self, from: data)
            
            DispatchQueue.main.async {
                // Temporarily disable auto-save during import
                self.saveTimer?.invalidate()
                
                self.nodes = graphState.nodes
                self.edges = graphState.edges
                self.selectedNodeIDs.removeAll()
                
                // Re-enable auto-save and compute flows
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.computeFlows()
                }
            }
        } catch {
            DispatchQueue.main.async {
                NSAlert(error: error).runModal()
            }
        }
    }
}
}
