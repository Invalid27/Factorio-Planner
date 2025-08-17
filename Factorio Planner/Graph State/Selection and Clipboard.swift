// Selection and Clipboard.swift
import Foundation
import CoreGraphics

extension GraphState {
    // MARK: - Selection Management
    
    func selectNode(_ nodeID: UUID, addToSelection: Bool = false) {
        if addToSelection {
            selectedNodeIDs.insert(nodeID)
        } else {
            selectedNodeIDs = [nodeID]
        }
    }
    
    func deselectNode(_ nodeID: UUID) {
        selectedNodeIDs.remove(nodeID)
    }
    
    func selectAll() {
        selectedNodeIDs = Set(nodes.keys)
    }
    
    func deselectAll() {
        selectedNodeIDs.removeAll()
    }
    
    func selectNodes(in rect: CGRect) {
        selectedNodeIDs = Set(nodes.compactMap { (id, node) in
            let nodeRect = CGRect(x: node.x - 50, y: node.y - 50, width: 100, height: 100)
            return rect.intersects(nodeRect) ? id : nil
        })
    }
    
    // MARK: - Clipboard Operations
    
    func copySelectedNodes() {
        clipboard = selectedNodeIDs.compactMap { nodes[$0] }
        clipboardWasCut = false
    }
    
    func cutSelectedNodes() {
        clipboard = selectedNodeIDs.compactMap { nodes[$0] }
        clipboardWasCut = true
        
        // Visual feedback: reduce opacity of cut nodes
        // This would need to be handled in the UI layer
    }
    
    func pasteNodes(at position: CGPoint) {
        guard !clipboard.isEmpty else { return }
        
        // Calculate center of clipboard nodes
        let centerX = clipboard.map { $0.x }.reduce(0, +) / CGFloat(clipboard.count)
        let centerY = clipboard.map { $0.y }.reduce(0, +) / CGFloat(clipboard.count)
        
        // Calculate offset from center to paste position
        let offsetX = position.x - centerX
        let offsetY = position.y - centerY
        
        // If this was a cut operation, remove the original nodes
        if clipboardWasCut {
            for node in clipboard {
                nodes.removeValue(forKey: node.id)
                edges.removeAll { $0.fromNode == node.id || $0.toNode == node.id }
            }
            clipboardWasCut = false
        }
        
        // Create new nodes at paste position
        var newNodeIDs: Set<UUID> = []
        var oldToNewIDMap: [UUID: UUID] = [:]
        
        for var node in clipboard {
            let oldID = node.id
            node.id = UUID()
            node.x += offsetX
            node.y += offsetY
            
            nodes[node.id] = node
            newNodeIDs.insert(node.id)
            oldToNewIDMap[oldID] = node.id
        }
        
        // Copy edges between pasted nodes
        if !clipboardWasCut {
            let clipboardNodeIDs = Set(clipboard.map { $0.id })
            for edge in edges {
                // Check if both nodes of the edge are in clipboard
                if clipboardNodeIDs.contains(edge.fromNode) &&
                   clipboardNodeIDs.contains(edge.toNode) {
                    if let newFromID = oldToNewIDMap[edge.fromNode],
                       let newToID = oldToNewIDMap[edge.toNode] {
                        let newEdge = Edge(fromNode: newFromID, toNode: newToID, item: edge.item)
                        edges.append(newEdge)
                    }
                }
            }
        }
        
        // Select the newly pasted nodes
        selectedNodeIDs = newNodeIDs
        
        // Clear clipboard if it was a cut operation
        if clipboardWasCut {
            clipboard.removeAll()
        }
        
        computeFlows()
    }
    
    func canPaste() -> Bool {
        return !clipboard.isEmpty
    }
}
