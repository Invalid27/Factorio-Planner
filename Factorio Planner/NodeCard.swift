//
//  NodeCard.swift
//  Factorio Planner
//
//  Created by Daniel on 8/17/25.
//


// Node Card Component.swift
// Complete NodeCard with context menu functionality

import SwiftUI

struct NodeCard: View {
    var node: Node
    @EnvironmentObject var graph: GraphState
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    @State private var showTargetSetter = false
    @State private var targetInput = ""
    
    private var recipe: Recipe? {
        RECIPES.first { $0.id == node.recipeID }
    }
    
    private var isSelected: Bool {
        graph.selectedNodeIDs.contains(node.id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            NodeHeader(node: node, recipe: recipe)
            
            // Input/Output Ports
            VStack(spacing: 8) {
                // Inputs
                if let recipe = recipe, !recipe.inputs.isEmpty {
                    VStack(spacing: 4) {
                        Text("INPUTS")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        ForEach(recipe.inputs.sorted(by: { $0.key < $1.key }), id: \.key) { item, amount in
                            PortRow(nodeID: node.id, side: .input, item: item, amount: amount)
                        }
                    }
                }
                
                // Outputs
                if let recipe = recipe, !recipe.outputs.isEmpty {
                    VStack(spacing: 4) {
                        Text("OUTPUTS")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        ForEach(recipe.outputs.sorted(by: { $0.key < $1.key }), id: \.key) { item, amount in
                            PortRow(nodeID: node.id, side: .output, item: item, amount: amount)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            
            // Footer with modules and stats
            NodeFooter(node: node)
        }
        .frame(minWidth: Constants.nodeMinWidth, maxWidth: Constants.nodeMaxWidth)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(radius: isDragging ? 8 : 4)
        .offset(dragOffset)
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isDragging)
        .onTapGesture {
            handleSelection()
        }
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { value in
                    handleDragEnded(value)
                }
        )
        .contextMenu {
            contextMenuItems()
        }
        .sheet(isPresented: $showTargetSetter) {
            TargetSetterView(node: node, targetInput: $targetInput) {
                if let target = Double(targetInput) {
                    var updatedNode = node
                    updatedNode.targetPerMin = target
                    graph.nodes[node.id] = updatedNode
                    graph.computeFlows()
                }
                showTargetSetter = false
            }
        }
    }
    
    // MARK: - Context Menu Items
    @ViewBuilder
    func contextMenuItems() -> some View {
        Group {
            Button {
                graph.selectedNodeIDs = [node.id]
                duplicateNode()
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Menu("Set Machine Tier") {
                if let recipe = recipe,
                   let tiers = MACHINE_TIERS[recipe.category] {
                    ForEach(tiers) { tier in
                        Button {
                            var updatedNode = node
                            updatedNode.selectedMachineTierID = tier.id
                            graph.nodes[node.id] = updatedNode
                            graph.computeFlows()
                        } label: {
                            HStack {
                                Text(tier.name)
                                if node.selectedMachineTierID == tier.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            
            Menu("Add Module") {
                if getMaxModuleSlots() > 0 {
                    ForEach(ModuleType.allCases, id: \.self) { moduleType in
                        Menu(moduleType.rawValue) {
                            ForEach(MODULES.filter { $0.type == moduleType }) { module in
                                Button {
                                    addModule(module)
                                } label: {
                                    Text(module.displayName)
                                }
                            }
                        }
                    }
                } else {
                    Text("No module slots available")
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            Button {
                showTargetSetter = true
            } label: {
                Label("Set Target", systemImage: "target")
            }
            
            Button {
                autoBalanceFromNode()
            } label: {
                Label("Auto-balance Chain", systemImage: "arrow.triangle.2.circlepath")
            }
            
            Divider()
            
            Menu("Connect To") {
                if let recipe = recipe {
                    ForEach(Array(recipe.outputs.keys), id: \.self) { outputItem in
                        if let consumers = ITEM_TO_CONSUMERS[outputItem] {
                            Menu(outputItem) {
                                ForEach(consumers, id: \.id) { consumerRecipe in
                                    Button(consumerRecipe.name) {
                                        createConnectedNode(recipe: consumerRecipe, item: outputItem, asConsumer: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Menu("Source From") {
                if let recipe = recipe {
                    ForEach(Array(recipe.inputs.keys), id: \.self) { inputItem in
                        if let producers = ITEM_TO_PRODUCERS[inputItem] {
                            Menu(inputItem) {
                                ForEach(producers, id: \.id) { producerRecipe in
                                    Button(producerRecipe.name) {
                                        createConnectedNode(recipe: producerRecipe, item: inputItem, asConsumer: false)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            Button(role: .destructive) {
                deleteNode()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func handleSelection() {
        if NSEvent.modifierFlags.contains(.command) {
            if graph.selectedNodeIDs.contains(node.id) {
                graph.selectedNodeIDs.remove(node.id)
            } else {
                graph.selectedNodeIDs.insert(node.id)
            }
        } else {
            graph.selectedNodeIDs = [node.id]
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        if !isDragging {
            isDragging = true
            if !graph.selectedNodeIDs.contains(node.id) {
                graph.selectedNodeIDs = [node.id]
            }
        }
        
        dragOffset = CGSize(
            width: value.translation.width / graph.canvasScale,
            height: value.translation.height / graph.canvasScale
        )
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let translation = CGSize(
            width: value.translation.width / graph.canvasScale,
            height: value.translation.height / graph.canvasScale
        )
        
        // Move all selected nodes
        for nodeID in graph.selectedNodeIDs {
            if var selectedNode = graph.nodes[nodeID] {
                selectedNode.x += translation.width
                selectedNode.y += translation.height
                graph.nodes[nodeID] = selectedNode
            }
        }
        
        isDragging = false
        dragOffset = .zero
        
        // Trigger auto-save
        graph.scheduleAutoSave()
    }
    
    private func duplicateNode() {
        var newNode = node
        newNode.id = UUID()
        newNode.x += 50
        newNode.y += 50
        graph.nodes[newNode.id] = newNode
        graph.selectedNodeIDs = [newNode.id]
    }
    
    private func addModule(_ module: Module) {
        guard var updatedNode = graph.nodes[node.id] else { return }
        
        // Initialize modules array if needed
        if updatedNode.modules.isEmpty {
            let slots = getMaxModuleSlots()
            updatedNode.modules = Array(repeating: nil, count: slots)
        }
        
        // Find first empty slot
        if let emptyIndex = updatedNode.modules.firstIndex(where: { $0 == nil }) {
            updatedNode.modules[emptyIndex] = module
        } else if updatedNode.modules.count < getMaxModuleSlots() {
            updatedNode.modules.append(module)
        }
        
        graph.nodes[node.id] = updatedNode
        graph.computeFlows()
    }
    
    private func getMaxModuleSlots() -> Int {
        guard let recipe = recipe,
              let tier = getSelectedMachineTier(for: node) else {
            return 0
        }
        return tier.moduleSlots
    }
    
    private func autoBalanceFromNode() {
        graph.autoBalance(startingNodeID: node.id)
    }
    
    private func createConnectedNode(recipe: Recipe, item: String, asConsumer: Bool) {
        let offset: CGFloat = 200
        let newX = asConsumer ? node.x + offset : node.x - offset
        let newY = node.y
        
        let newNode = graph.addNode(recipeID: recipe.id, at: CGPoint(x: newX, y: newY))
        
        if asConsumer {
            graph.addEdge(from: node.id, to: newNode.id, item: item)
        } else {
            graph.addEdge(from: newNode.id, to: node.id, item: item)
        }
        
        graph.computeFlows()
    }
    
    private func deleteNode() {
        graph.nodes.removeValue(forKey: node.id)
        graph.edges.removeAll { $0.fromNode == node.id || $0.toNode == node.id }
        graph.selectedNodeIDs.remove(node.id)
        graph.computeFlows()
    }
}

// MARK: - Node Header Component
struct NodeHeader: View {
    let node: Node
    let recipe: Recipe?
    @EnvironmentObject var graph: GraphState
    
    var body: some View {
        HStack(spacing: 8) {
            // Machine/Recipe Icon
            if let recipe = recipe {
                MachineIconView(category: recipe.category, size: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe?.name ?? "Unknown Recipe")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if let targetPerMin = node.targetPerMin, targetPerMin > 0 {
                    Text("\(targetPerMin, specifier: "%.1f") /min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.2))
    }
}

// MARK: - Node Footer Component
struct NodeFooter: View {
    let node: Node
    @EnvironmentObject var graph: GraphState
    
    var body: some View {
        VStack(spacing: 4) {
            // Machine tier display
            if let tier = getSelectedMachineTier(for: node) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(tier.name)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Modules display
            if !node.modules.isEmpty && node.modules.contains(where: { $0 != nil }) {
                ModuleDisplay(modules: node.modules)
            }
            
            // Stats display
            if node.totalSpeedBonus != 0 || node.totalProductivityBonus != 0 {
                HStack(spacing: 8) {
                    if node.totalSpeedBonus != 0 {
                        StatBadge(
                            value: node.totalSpeedBonus,
                            type: .speed,
                            color: .blue
                        )
                    }
                    if node.totalProductivityBonus != 0 {
                        StatBadge(
                            value: node.totalProductivityBonus,
                            type: .productivity,
                            color: .red
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

// MARK: - Supporting Views
struct TargetSetterView: View {
    let node: Node
    @Binding var targetInput: String
    let onSet: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Set Target Production")
                .font(.headline)
            
            HStack {
                TextField("Items per minute", text: $targetInput)
                    .textFieldStyle(.roundedBorder)
                Text("/min")
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("Set") {
                    onSet()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

struct StatBadge: View {
    let value: Double
    let type: String
    let color: Color
    
    enum StatType {
        case speed
        case productivity
        case efficiency
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
            Text(formatValue(value))
                .font(.caption2)
                .monospacedDigit()
        }
        .foregroundStyle(color)
    }
    
    private var icon: String {
        switch type {
        case .speed: return "speedometer"
        case .productivity: return "chart.line.uptrend.xyaxis"
        default: return "bolt.fill"
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        let percentage = value * 100
        return String(format: "%+.0f%%", percentage)
    }
}