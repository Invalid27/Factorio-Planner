// Node Management.swift
import Foundation
import CoreGraphics

extension GraphState {
    // MARK: - Node Management
    
    @discardableResult
    func addNode(recipeID: String, at position: CGPoint) -> Node {
        let node = Node(recipeID: recipeID, x: position.x, y: position.y)
        nodes[node.id] = node
        computeFlows()
        return node
    }
    
    func deleteNode(_ nodeID: UUID) {
        nodes.removeValue(forKey: nodeID)
        edges.removeAll { $0.fromNode == nodeID || $0.toNode == nodeID }
        selectedNodeIDs.remove(nodeID)
        computeFlows()
    }
    
    func deleteSelectedNodes() {
        for nodeID in selectedNodeIDs {
            nodes.removeValue(forKey: nodeID)
            edges.removeAll { $0.fromNode == nodeID || $0.toNode == nodeID }
        }
        selectedNodeIDs.removeAll()
        computeFlows()
    }
    
    func duplicateSelectedNodes() {
        var newNodes: [Node] = []
        let offset: CGFloat = 50
        
        for nodeID in selectedNodeIDs {
            guard var node = nodes[nodeID] else { continue }
            node.id = UUID()
            node.x += offset
            node.y += offset
            newNodes.append(node)
            nodes[node.id] = node
        }
        
        // Update selection to new nodes
        selectedNodeIDs = Set(newNodes.map { $0.id })
    }
    
    func addEdge(from: UUID, to: UUID, item: String) {
        // Check if edge already exists
        let edgeExists = edges.contains { edge in
            edge.fromNode == from && edge.toNode == to && edge.item == item
        }
        
        if !edgeExists {
            let edge = Edge(fromNode: from, toNode: to, item: item)
            edges.append(edge)
            computeFlows()
        }
    }
    
    func removeEdge(_ edge: Edge) {
        edges.removeAll { $0.id == edge.id }
        computeFlows()
    }
    
    func updateNodePosition(_ nodeID: UUID, to position: CGPoint) {
        if var node = nodes[nodeID] {
            node.x = position.x
            node.y = position.y
            nodes[nodeID] = node
        }
    }
    
    func updateNodeTarget(_ nodeID: UUID, target: Double?) {
        if var node = nodes[nodeID] {
            node.targetPerMin = target
            nodes[nodeID] = node
            computeFlows()
        }
    }
    
    func updateNodeMachine(_ nodeID: UUID, machineID: String) {
        if var node = nodes[nodeID] {
            node.selectedMachineTierID = machineID
            nodes[nodeID] = node
            computeFlows()
        }
    }
    
    func updateNodeModules(_ nodeID: UUID, modules: [Module?]) {
        if var node = nodes[nodeID] {
            node.modules = modules
            nodes[nodeID] = node
            computeFlows()
        }
    }
    
    func clearGraph() {
        nodes.removeAll()
        edges.removeAll()
        selectedNodeIDs.removeAll()
    }
}
