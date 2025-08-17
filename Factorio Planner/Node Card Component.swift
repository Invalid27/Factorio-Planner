// MARK: - Fixed Node Card Component

struct NodeCard: View {
    @EnvironmentObject var graph: GraphState
    var node: Node
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var rateText: String = ""
    @State private var isUpdatingRate: Bool = false
    @FocusState private var rateFocused: Bool
    
    // Track offsets for all selected nodes during multi-drag
    @State private var multiDragOffsets: [UUID: CGSize] = [:]
    
    private var isSelected: Bool {
        graph.selectedNodeIDs.contains(node.id)
    }
    
    var body: some View {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return AnyView(EmptyView())
        }
        
        // FIXED: Create binding that prevents recursive updates
        let speedBinding = Binding<Double>(
            get: {
                graph.nodes[node.id]?.speedMultiplier ?? 1
            },
            set: { value in
                guard let currentNode = graph.nodes[node.id],
                      currentNode.speedMultiplier != value else { return }
                
                var updatedNode = currentNode
                updatedNode.speedMultiplier = max(Constants.minSpeed, value)
                graph.updateNode(updatedNode)
            }
        )
        
        let primaryItem = recipe.outputs.keys.first ?? recipe.inputs.keys.first ?? recipe.name
        
        return AnyView(
            VStack(alignment: .leading, spacing: 2) {
                // Header
                HStack(spacing: 6) {
                    ItemBadge(item: primaryItem)
                        .hoverTooltip(recipe.name)
                    
                    Text(primaryItem)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    Button(action: {
                        graph.removeNode(node.id)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                // Controls
                HStack {
                    HStack(spacing: 4) {
                        TextField("Rate", text: Binding(
                            get: { rateText },
                            set: { text in
                                // FIXED: Prevent recursive updates
                                guard !isUpdatingRate else { return }
                                
                                rateText = text
                                let trimmed = text.trimmingCharacters(in: .whitespaces)
                                
                                if trimmed.isEmpty {
                                    graph.setTarget(for: node.id, to: nil)
                                } else if let value = Double(trimmed) {
                                    graph.setTarget(for: node.id, to: max(0, value))
                                }
                            }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                        .focused($rateFocused)
                        
                        Text("/min")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        TextField("Speed", value: speedBinding, format: .number.precision(.fractionLength(0...2)))
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 50)
                        
                        Text("×")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                }
                
                Divider()
                
                // I/O Ports with machine icon in middle
                HStack(alignment: .center, spacing: 4) {
                    // Inputs
                    VStack(alignment: .leading, spacing: 2) {
                        Text("In")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        ForEach(recipe.inputs.sorted(by: { $0.key < $1.key }), id: \.key) { item, amount in
                            PortRow(nodeID: node.id, side: .input, item: item, amount: amount)
                                .font(.caption2)
                        }
                    }
                    
                    Spacer()
                    
                    // Machine icon in center with modules
                    VStack(spacing: 2) {
                        MachineIcon(node: node)
                        
                        Text(formatMachineCount(machineCount(for: node)))
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .monospacedDigit()
                        
                        // Module slots
                        if let selectedTier = getSelectedMachineTier(for: node), selectedTier.moduleSlots > 0 {
                            ModuleSlotsView(node: node, slotCount: selectedTier.moduleSlots)
                        }
                        
                        // Module stats if any modules installed
                        if !node.modules.compactMap({ $0 }).isEmpty {
                            ModuleStatsView(node: node)
                        }
                    }
                    .padding(.top, 16)
                    .frame(maxWidth: 60)
                    
                    Spacer()
                    
                    // Outputs
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Out")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        ForEach(recipe.outputs.sorted(by: { $0.key < $1.key }), id: \.key) { item, amount in
                            PortRow(nodeID: node.id, side: .output, item: item, amount: amount)
                                .font(.caption2)
                        }
                    }
                }
            }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(isSelected ? 0.25 : 0.20))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.orange.opacity(0.4) : Color.white.opacity(0.05), lineWidth: isSelected ? 1.5 : 1)
                )
                .opacity(isSelected ? 1.0 : 0.9)
                .shadow(color: isSelected ? Color.orange.opacity(0.15) : Color.clear, radius: 4)
                .frame(minWidth: Constants.nodeMinWidth, maxWidth: Constants.nodeMaxWidth, alignment: .leading)
                .offset(dragOffset)
                .scaleEffect(isDragging ? 1.02 : 1.0)
                .animation(.easeOut(duration: 0.1), value: isDragging)
                .animation(.easeOut(duration: 0.15), value: isSelected)
                .onTapGesture {
                    handleTap()
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            handleNodeDragChanged(value)
                        }
                        .onEnded { value in
                            handleNodeDragEnded(value)
                        }
                )
                .onAppear {
                    updateRateText()
                }
                .onChange(of: graph.nodes[node.id]?.targetPerMin) { _, _ in
                    if !rateFocused {
                        updateRateText()
                    }
                }
        )
    }
    
    private func handleTap() {
        if NSEvent.modifierFlags.contains(.command) {
            // Command+click to add/remove from selection
            graph.toggleNodeSelection(node.id)
        } else if NSEvent.modifierFlags.contains(.shift) {
            // Shift+click to add to selection
            graph.selectedNodeIDs.insert(node.id)
        } else {
            // Regular click to select only this node
            graph.selectNode(node.id)
        }
    }
    
    private func handleNodeDragChanged(_ value: DragGesture.Value) {
        if !isDragging {
            isDragging = true
            
            // If this node isn't selected, select only it
            if !graph.selectedNodeIDs.contains(node.id) {
                graph.selectNode(node.id)
            }
            
            // Initialize offsets for all selected nodes
            multiDragOffsets = [:]
            for id in graph.selectedNodeIDs {
                multiDragOffsets[id] = .zero
            }
        }
        
        // Update visual position for this node
        dragOffset = value.translation
        
        // Store the offset for this node
        multiDragOffsets[node.id] = value.translation
    }
    
    private func handleNodeDragEnded(_ value: DragGesture.Value) {
        isDragging = false
        
        // FIXED: Batch update all selected nodes without triggering multiple computations
        var updatedNodes = graph.nodes
        
        for id in graph.selectedNodeIDs {
            guard var updatedNode = updatedNodes[id] else { continue }
            
            // Use the same translation for all selected nodes
            updatedNode.x += value.translation.width
            updatedNode.y += value.translation.height
            
            updatedNodes[id] = updatedNode
        }
        
        // FIXED: Update all nodes at once to prevent multiple recomputations
        let timer = graph.saveTimer
        graph.saveTimer?.invalidate()
        
        graph.nodes = updatedNodes
        
        graph.saveTimer = timer
        
        // Reset offsets
        dragOffset = .zero
        multiDragOffsets = [:]
        
        // FIXED: Single computation after all updates
        DispatchQueue.main.async {
            graph.computeFlows()
        }
    }
    
    private func updateRateText() {
        guard !isUpdatingRate else { return }
        
        isUpdatingRate = true
        defer { isUpdatingRate = false }
        
        if let targetPerMin = graph.nodes[node.id]?.targetPerMin {
            if targetPerMin == floor(targetPerMin) {
                rateText = String(format: "%.0f", targetPerMin)
            } else {
                rateText = String(format: "%.1f", targetPerMin)
            }
        } else {
            rateText = ""
        }
    }
}
