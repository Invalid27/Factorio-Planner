// Import-Export.swift
import Foundation
import AppKit

extension GraphState {
    // MARK: - Import/Export
    
    func exportGraph() {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Factorio Plan"
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "FactorioPlan.json"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(self)
                    try data.write(to: url)
                    print("Exported graph to \(url.path)")
                } catch {
                    print("Failed to export: \(error)")
                    self.showError("Export Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    func importGraph() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Import Factorio Plan"
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let importedState = try decoder.decode(GraphState.self, from: data)
                    
                    // Replace current state with imported state
                    DispatchQueue.main.async {
                        self.nodes = importedState.nodes
                        self.edges = importedState.edges
                        self.selectedNodeIDs.removeAll()
                        self.computeFlows()
                        print("Imported graph from \(url.path)")
                    }
                } catch {
                    print("Failed to import: \(error)")
                    self.showError("Import Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    func exportSelectedNodes() {
        guard !selectedNodeIDs.isEmpty else {
            showError("Nothing to Export", message: "Please select some nodes to export.")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.title = "Export Selected Nodes"
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "FactorioPartialPlan.json"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    // Create a partial graph with only selected nodes and their edges
                    let selectedNodes = self.selectedNodeIDs.compactMap { self.nodes[$0] }
                    let selectedEdges = self.edges.filter { edge in
                        self.selectedNodeIDs.contains(edge.fromNode) &&
                        self.selectedNodeIDs.contains(edge.toNode)
                    }
                    
                    let partialGraph = PartialGraph(nodes: selectedNodes, edges: selectedEdges)
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(partialGraph)
                    try data.write(to: url)
                    print("Exported \(selectedNodes.count) nodes to \(url.path)")
                } catch {
                    print("Failed to export selected: \(error)")
                    self.showError("Export Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    func importAndMerge() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Import and Merge Factorio Plan"
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    
                    // Try to decode as full graph first, then as partial
                    if let importedState = try? decoder.decode(GraphState.self, from: data) {
                        self.mergeGraph(nodes: Array(importedState.nodes.values),
                                      edges: importedState.edges)
                    } else if let partialGraph = try? decoder.decode(PartialGraph.self, from: data) {
                        self.mergeGraph(nodes: partialGraph.nodes,
                                      edges: partialGraph.edges)
                    } else {
                        throw NSError(domain: "Import", code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Invalid file format"])
                    }
                } catch {
                    print("Failed to import and merge: \(error)")
                    self.showError("Import Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func mergeGraph(nodes: [Node], edges: [Edge]) {
        // Find a good position for the imported nodes
        let offsetX: CGFloat = 300
        let offsetY: CGFloat = 300
        
        var oldToNewIDMap: [UUID: UUID] = [:]
        var newNodeIDs: Set<UUID> = []
        
        // Add nodes with new IDs and offset position
        for var node in nodes {
            let oldID = node.id
            node.id = UUID()
            node.x += offsetX
            node.y += offsetY
            
            self.nodes[node.id] = node
            oldToNewIDMap[oldID] = node.id
            newNodeIDs.insert(node.id)
        }
        
        // Add edges with updated node IDs
        for edge in edges {
            if let newFromID = oldToNewIDMap[edge.fromNode],
               let newToID = oldToNewIDMap[edge.toNode] {
                let newEdge = Edge(fromNode: newFromID, toNode: newToID, item: edge.item)
                self.edges.append(newEdge)
            }
        }
        
        // Select the imported nodes
        selectedNodeIDs = newNodeIDs
        computeFlows()
        
        print("Merged \(nodes.count) nodes and \(edges.count) edges")
    }
    
    private func showError(_ title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

// Helper struct for partial graph export
struct PartialGraph: Codable {
    let nodes: [Node]
    let edges: [Edge]
}
