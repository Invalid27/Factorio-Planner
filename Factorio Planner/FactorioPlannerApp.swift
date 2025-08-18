import SwiftUI
import AppKit
import Combine
import UniformTypeIdentifiers

// MARK: - Constants
private enum Constants {
    static let gridSpacing: CGFloat = 50
    static let dotSize: CGFloat = 1.2
    static let portSize: CGFloat = 14
    static let iconSize: CGFloat = 22
    static let nodeMinWidth: CGFloat = 190
    static let nodeMaxWidth: CGFloat = 210
    static let wireLineWidth: CGFloat = 2.0
    static let curveTension: CGFloat = 40
    static let minSpeed: Double = 0.1
    static let computationTolerance: Double = 1e-6
}

// MARK: - Intermediate Products
let INTERMEDIATE_PRODUCTS: Set<String> = [
    // Basic intermediates
    "Copper Cable",
    "Iron Stick",
    "Iron Gear Wheel",
    "Electronic Circuit",
    "Advanced Circuit",
    "Processing Unit",
    
    // Plates and basic materials
    "Iron Plate",
    "Copper Plate",
    "Steel Plate",
    "Plastic Bar",
    "Sulfur",
    "Battery",
    "Engine Unit",
    "Electric Engine Unit",
    "Flying Robot Frame",
    
    // Science packs (yes, they allow productivity!)
    "Automation Science Pack",
    "Logistic Science Pack",
    "Military Science Pack",
    "Chemical Science Pack",
    "Production Science Pack",
    "Utility Science Pack",
    "Space Science Pack",
    "Metallurgic Science Pack",
    "Electromagnetic Science Pack",
    "Agricultural Science Pack",
    "Cryogenic Science Pack",
    "Promethium Science Pack",
    
    // Space Age intermediates
    "Superconductor",
    "Supercapacitor",
    "Holmium Plate",
    "Tungsten Plate",
    "Tungsten Carbide",
    "Carbon",
    "Carbon Fiber",
    "Quantum Processor",
    "Bioflux",
    "Nutrients",
    
    // Rocket parts
    "Low Density Structure",
    "Rocket Fuel",
    "Rocket Control Unit",
    "Rocket Part",
    
    // Molten metals (in foundry)
    "Molten Iron",
    "Molten Copper",
    
    // Other intermediates
    "Concrete",
    "Sulfuric Acid",
    "Lubricant",
    "Solid Fuel",
    "Uranium-235",
    "Uranium-238",
    "Uranium Fuel Cell",
]

// MARK: - Enums
enum ModuleType: String, Codable, CaseIterable {
    case speed = "Speed"
    case productivity = "Productivity"
    case efficiency = "Efficiency"
    case quality = "Quality"
    
    var color: Color {
        switch self {
        case .speed: return .blue
        case .productivity: return .red
        case .efficiency: return .green
        case .quality: return .yellow
        }
    }
}

enum Quality: String, Codable, CaseIterable {
    case normal = "Normal"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: Color {
        switch self {
        case .normal: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var multiplier: Double {
        switch self {
        case .normal: return 1.0
        case .uncommon: return 1.3
        case .rare: return 1.6
        case .epic: return 1.9
        case .legendary: return 2.5
        }
    }
}

enum IOSide: String, Codable, CaseIterable {
    case input = "input"
    case output = "output"
    
    var opposite: IOSide {
        switch self {
        case .input: return .output
        case .output: return .input
        }
    }
}

// MARK: - Data Models
struct Module: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let type: ModuleType
    let level: Int
    let quality: Quality
    let speedBonus: Double
    let productivityBonus: Double
    let efficiencyBonus: Double
    let iconAsset: String?
    
    var displayName: String {
        "\(name) (\(quality.rawValue))"
    }
}

struct MachineTier: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: String
    let speed: Double
    let iconAsset: String?
    let moduleSlots: Int
}

struct Recipe: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var category: String
    var time: Double
    var inputs: [String: Double]
    var outputs: [String: Double]
}

struct Node: Identifiable, Codable, Hashable {
    var id = UUID()
    var recipeID: String
    var x: CGFloat
    var y: CGFloat
    var targetPerMin: Double?
    var speedMultiplier: Double
    var selectedMachineTierID: String?
    var modules: [Module?] = []

    init(recipeID: String, x: CGFloat, y: CGFloat, targetPerMin: Double? = nil, speedMultiplier: Double? = nil) {
        self.recipeID = recipeID
        self.x = x
        self.y = y
        self.targetPerMin = targetPerMin
        
        if let recipe = RECIPES.first(where: { $0.id == recipeID }), recipe.category == "cryogenic" {
            self.speedMultiplier = speedMultiplier ?? 2.0
        } else {
            self.speedMultiplier = speedMultiplier ?? 1.0
        }
    }
    
    var totalSpeedBonus: Double {
        return modules.compactMap { $0?.speedBonus }.reduce(0, +)
    }
    
    var totalProductivityBonus: Double {
        let moduleBonus = modules.compactMap { $0?.productivityBonus }.reduce(0, +)
        let builtInBonus = getBuiltInProductivityBonus()
        return moduleBonus + builtInBonus
    }

    private func getBuiltInProductivityBonus() -> Double {
        guard let recipe = RECIPES.first(where: { $0.id == recipeID }) else { return 0 }
        
        // Foundry has built-in 50% productivity
        if recipe.category == "casting" {
            return 0.5
        }
        
        return 0.0
    }
    
    var totalEfficiencyBonus: Double {
        return modules.compactMap { $0?.efficiencyBonus }.reduce(0, +)
    }
    
    var speed: Double {
        return getEffectiveSpeed(for: self)
    }
}

struct Edge: Identifiable, Codable, Hashable {
    var id = UUID()
    var fromNode: UUID
    var toNode: UUID
    var item: String
    var quality: Quality = .normal
}

struct PortKey: Hashable, Codable {
    var nodeID: UUID
    var item: String
    var side: IOSide
    var quality: Quality = .normal
}

// MARK: - Supporting Types
struct DragContext: Equatable {
    var fromPort: PortKey
    var startPoint: CGPoint
    var currentPoint: CGPoint
}

struct PickerContext: Identifiable, Equatable {
    var id = UUID()
    var fromPort: PortKey
    var dropPoint: CGPoint
}

struct PortFrame: Equatable {
    var key: PortKey
    var frame: CGRect
}

struct PortFramesKey: PreferenceKey {
    static var defaultValue: [PortFrame] = []
    static func reduce(value: inout [PortFrame], nextValue: () -> [PortFrame]) {
        value.append(contentsOf: nextValue())
    }
}

// MARK: - Machine Preferences
class MachinePreferences: ObservableObject, Codable {
    @Published var defaultTiers: [String: String] = [:]
    
    enum CodingKeys: CodingKey {
        case defaultTiers
    }
    
    init() {
        defaultTiers = [
            "smelting": "electric-furnace",
            "assembling": "assembling-3",
            "mining": "electric-mining-drill"
        ]
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultTiers = try container.decode([String: String].self, forKey: .defaultTiers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(defaultTiers, forKey: .defaultTiers)
    }
    
    func getDefaultTier(for category: String) -> String? {
        return defaultTiers[category]
    }
    
    func setDefaultTier(for category: String, tierID: String) {
        defaultTiers[category] = tierID
        savePreferences()
    }
    
    private func savePreferences() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "MachinePreferences")
        }
    }
    
    static func load() -> MachinePreferences {
        if let data = UserDefaults.standard.data(forKey: "MachinePreferences"),
           let preferences = try? JSONDecoder().decode(MachinePreferences.self, from: data) {
            return preferences
        }
        return MachinePreferences()
    }
}

// MARK: - Graph State (Complete Replacement)
final class GraphState: ObservableObject, Codable {
    enum CodingKeys: CodingKey {
        case nodes, edges, userSetTargets
    }
    
    enum Aggregate: String, CaseIterable {
        case max = "Max"
        case sum = "Sum"
    }
    
    @Published var nodes: [UUID: Node] = [:] {
        didSet {
            autoSave()
        }
    }
    @Published var edges: [Edge] = [] {
        didSet {
            autoSave()
        }
    }
    @Published var dragging: DragContext? = nil
    @Published var showPicker = false
    @Published var pickerContext: PickerContext? = nil
    @Published var showGeneralPicker = false
    @Published var generalPickerDropPoint: CGPoint = .zero
    @Published var aggregate: Aggregate = .max {
        didSet {
            savePreferences()
        }
    }
    @Published var portFrames: [PortKey: CGRect] = [:]
    @Published var lastMousePosition: CGPoint = CGPoint(x: 400, y: 300)
    
    // Selection and clipboard
    @Published var selectedNodeID: UUID? = nil
    @Published var clipboard: Node? = nil
    @Published var clipboardWasCut: Bool = false
    @Published var copiedModule: Module? = nil
    
    // Multi-selection and canvas controls
    @Published var selectedNodeIDs: Set<UUID> = []
    @Published var canvasScale: Double = 1.0
    @Published var canvasOffset: CGSize = .zero
    @Published var isSelecting = false
    @Published var selectionStart: CGPoint = .zero
    @Published var selectionEnd: CGPoint = .zero
    
    // Track user-set targets
    @Published var userSetTargets: [UUID: Double] = [:]
    
    private var saveTimer: Timer?
    private var isComputing = false
    private var pendingCompute = false
    
    init() {
        loadAutoSave()
        loadPreferences()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nodeArray = try container.decode([Node].self, forKey: .nodes)
        self.nodes = Dictionary(uniqueKeysWithValues: nodeArray.map { ($0.id, $0) })
        self.edges = try container.decode([Edge].self, forKey: .edges)
        self.userSetTargets = try container.decodeIfPresent([UUID: Double].self, forKey: .userSetTargets) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Array(nodes.values), forKey: .nodes)
        try container.encode(edges, forKey: .edges)
        try container.encode(userSetTargets, forKey: .userSetTargets)
    }
    
    // MARK: - Selection Methods
    func selectNode(_ nodeID: UUID?) {
        selectedNodeID = nodeID
        if let nodeID = nodeID {
            selectedNodeIDs = [nodeID]
        } else {
            selectedNodeIDs = []
        }
    }
    
    func selectNodesInRect(_ rect: CGRect) {
        selectedNodeIDs = []
        
        for (id, node) in nodes {
            let nodeRect = CGRect(
                x: node.x - 100,
                y: node.y - 50,
                width: 200,
                height: 100
            )
            
            if rect.intersects(nodeRect) {
                selectedNodeIDs.insert(id)
            }
        }
        
        selectedNodeID = selectedNodeIDs.first
    }
    
    func selectAll() {
        selectedNodeIDs = Set(nodes.keys)
        selectedNodeID = selectedNodeIDs.first
    }
    
    func deselectAll() {
        selectedNodeIDs = []
        selectedNodeID = nil
    }
    
    func moveSelectedNodes(by offset: CGSize) {
        for nodeID in selectedNodeIDs {
            if var node = nodes[nodeID] {
                node.x += offset.width
                node.y += offset.height
                nodes[nodeID] = node
            }
        }
    }
    
    // MARK: - Clipboard Methods
    func copyNode() {
        guard let selectedID = selectedNodeID,
              let node = nodes[selectedID] else { return }
        clipboard = node
        clipboardWasCut = false
    }
    
    func copySelectedNodes() {
        if let firstID = selectedNodeIDs.first,
           let node = nodes[firstID] {
            clipboard = node
            clipboardWasCut = false
        }
    }
    
    func cutNode() {
        guard let selectedID = selectedNodeID,
              let node = nodes[selectedID] else { return }
        clipboard = node
        clipboardWasCut = true
        removeNode(selectedID)
        selectedNodeID = nil
    }
    
    func cutSelectedNodes() {
        copySelectedNodes()
        clipboardWasCut = true
        deleteSelectedNodes()
    }
    
    func pasteNode() {
        guard let nodeToPaste = clipboard else { return }
        
        let offset = CGFloat(20)
        let newPosition = CGPoint(
            x: lastMousePosition.x + offset,
            y: lastMousePosition.y + offset
        )
        
        var newNode = Node(
            recipeID: nodeToPaste.recipeID,
            x: newPosition.x,
            y: newPosition.y,
            targetPerMin: nodeToPaste.targetPerMin,
            speedMultiplier: nodeToPaste.speedMultiplier
        )
        
        newNode.selectedMachineTierID = nodeToPaste.selectedMachineTierID
        newNode.modules = nodeToPaste.modules
        
        nodes[newNode.id] = newNode
        selectedNodeID = newNode.id
        computeFlows()
        
        if clipboardWasCut {
            clipboard = nil
            clipboardWasCut = false
        }
    }
    
    func deleteSelectedNode() {
        guard let selectedID = selectedNodeID else { return }
        removeNode(selectedID)
        selectedNodeID = nil
    }
    
    func deleteSelectedNodes() {
        for nodeID in selectedNodeIDs {
            removeNode(nodeID)
        }
        selectedNodeIDs = []
        selectedNodeID = nil
    }
    
    func canPaste() -> Bool {
        return clipboard != nil
    }
    
    // MARK: - Auto-Save
    private func autoSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.performSave()
        }
    }
    
    private func performSave() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: "FactorioPlannerAutoSave")
        } catch {
            print("Failed to auto-save: \(error)")
        }
    }
    
    private func loadAutoSave() {
        guard let data = UserDefaults.standard.data(forKey: "FactorioPlannerAutoSave") else {
            return
        }
        
        do {
            let savedState = try JSONDecoder().decode(GraphState.self, from: data)
            self.nodes = savedState.nodes
            self.edges = savedState.edges
            self.userSetTargets = savedState.userSetTargets
            
            DispatchQueue.main.async {
                self.computeFlows()
            }
        } catch {
            print("Failed to load auto-save: \(error)")
        }
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(aggregate.rawValue, forKey: "FactorioPlannerAggregate")
    }
    
    private func loadPreferences() {
        if let aggregateRaw = UserDefaults.standard.string(forKey: "FactorioPlannerAggregate"),
           let loadedAggregate = Aggregate(rawValue: aggregateRaw) {
            self.aggregate = loadedAggregate
        }
    }
    
    // MARK: - Graph Management
    func clearGraph() {
        nodes.removeAll()
        edges.removeAll()
        selectedNodeID = nil
        selectedNodeIDs = []
        userSetTargets.removeAll()
        computeFlows()
    }
    
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
        
        nodes[node.id] = node
        selectedNodeID = node.id
        
        return node
    }
    
    func updateNode(_ node: Node) {
        nodes[node.id] = node
        computeFlows()
    }
    
    func setTarget(for nodeID: UUID, to value: Double?) {
        guard var node = nodes[nodeID] else { return }
        
        node.targetPerMin = value.map { max(0, $0) }
        nodes[nodeID] = node
        
        if let value = value, value > 0 {
            // Clear other user-set targets in the same network
            let network = findConnectedNodes(from: nodeID)
            for id in network {
                if id != nodeID {
                    userSetTargets.removeValue(forKey: id)
                }
            }
            // Set this as the new user target
            userSetTargets[nodeID] = value
        } else {
            userSetTargets.removeValue(forKey: nodeID)
        }
        
        computeFlows()
    }
    
    func addEdge(from: UUID, to: UUID, item: String, quality: Quality = .normal) {
        guard from != to else { return }
        
        let edgeExists = edges.contains { edge in
            edge.fromNode == from && edge.toNode == to && edge.item == item && edge.quality == quality
        }
        
        if !edgeExists {
            edges.append(Edge(fromNode: from, toNode: to, item: item, quality: quality))
            computeFlows()
        }
    }
    
    func removeEdge(_ edge: Edge) {
        edges.removeAll { $0.id == edge.id }
        computeFlows()
    }
    
    func removeNode(_ nodeID: UUID) {
        nodes.removeValue(forKey: nodeID)
        edges.removeAll { $0.fromNode == nodeID || $0.toNode == nodeID }
        userSetTargets.removeValue(forKey: nodeID)
        computeFlows()
    }
    
    // MARK: - Flow Computation
    func computeFlows() {
        guard !isComputing else {
            pendingCompute = true
            return
        }
        
        isComputing = true
        defer {
            isComputing = false
            if pendingCompute {
                pendingCompute = false
                DispatchQueue.main.async { [weak self] in
                    self?.computeFlows()
                }
            }
        }
        
        // If we have user-set targets, propagate from those
        if !userSetTargets.isEmpty {
            propagateNetworkFlows()
        } else {
            standardFlowComputation()
        }
    }
    
    private func propagateNetworkFlows() {
        var targets: [UUID: Double] = [:]
        
        // Find all connected networks
        let networks = findAllNetworks()
        
        // For each network, propagate from user-set nodes
        for network in networks {
            // Find user-set nodes in this network
            let userSetInNetwork = network.filter { userSetTargets.keys.contains($0) }
            
            if !userSetInNetwork.isEmpty {
                // Use the first user-set node as source
                if let sourceNodeID = userSetInNetwork.first,
                   let sourceTarget = userSetTargets[sourceNodeID] {
                    
                    // Propagate through the network
                    propagateThroughNetwork(
                        network: network,
                        sourceNodeID: sourceNodeID,
                        sourceTarget: sourceTarget,
                        targets: &targets
                    )
                }
            }
        }
        
        // Update all nodes with computed values
        for (nodeID, var node) in nodes {
            let newTarget = targets[nodeID]
            let roundedTarget: Double? = if let target = newTarget, target > Constants.computationTolerance {
                abs(target - round(target)) < 0.01 ? round(target) : round(target * 10) / 10
            } else {
                nil
            }
            
            if node.targetPerMin != roundedTarget {
                node.targetPerMin = roundedTarget
                nodes[nodeID] = node
            }
        }
    }
    
    private func findAllNetworks() -> [[UUID]] {
        var visited = Set<UUID>()
        var networks: [[UUID]] = []
        
        for nodeID in nodes.keys {
            if !visited.contains(nodeID) {
                let network = findConnectedNodes(from: nodeID)
                visited.formUnion(network)
                networks.append(Array(network))
            }
        }
        
        return networks
    }
    
    private func findConnectedNodes(from sourceID: UUID) -> Set<UUID> {
        var connected = Set<UUID>()
        var toProcess = [sourceID]
        
        while !toProcess.isEmpty {
            let current = toProcess.removeFirst()
            if connected.contains(current) {
                continue
            }
            connected.insert(current)
            
            // Find all nodes connected via edges (both directions)
            for edge in edges {
                if edge.fromNode == current && !connected.contains(edge.toNode) {
                    toProcess.append(edge.toNode)
                }
                if edge.toNode == current && !connected.contains(edge.fromNode) {
                    toProcess.append(edge.fromNode)
                }
            }
        }
        
        return connected
    }
    
    private func propagateThroughNetwork(
        network: [UUID],
        sourceNodeID: UUID,
        sourceTarget: Double,
        targets: inout [UUID: Double]
    ) {
        guard let sourceNode = nodes[sourceNodeID],
              let sourceRecipe = RECIPES.first(where: { $0.id == sourceNode.recipeID }) else {
            return
        }
        
        // Set the source node's target
        targets[sourceNodeID] = sourceTarget
        
        // Calculate the source node's production rate
        let primaryOutput = sourceRecipe.outputs.first?.value ?? 1
        let actualOutput = primaryOutput * (1 + sourceNode.totalProductivityBonus)
        let craftsPerSec = sourceTarget / actualOutput
        
        // ALWAYS propagate upstream to suppliers (what inputs do we need?)
        propagateUpstream(from: sourceNodeID, craftsPerSec: craftsPerSec, targets: &targets, network: network)
        
        // ALWAYS propagate downstream to consumers (what can our consumers produce?)
        propagateDownstream(from: sourceNodeID, targets: &targets, network: network)
    }
    
    private func propagateUpstream(
        from nodeID: UUID,
        craftsPerSec: Double,
        targets: inout [UUID: Double],
        network: [UUID]
    ) {
        guard let node = nodes[nodeID],
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return
        }
        
        // Find all suppliers
        let incomingEdges = edges.filter { $0.toNode == nodeID }
        
        for edge in incomingEdges {
            guard network.contains(edge.fromNode),
                  let supplier = nodes[edge.fromNode],
                  let supplierRecipe = RECIPES.first(where: { $0.id == supplier.recipeID }) else {
                continue
            }
            
            // Calculate required input
            let inputAmount = recipe.inputs[edge.item] ?? 0
            let requiredInput = craftsPerSec * inputAmount
            
            // Calculate supplier's required output
            if let outputAmount = supplierRecipe.outputs[edge.item] {
                let actualOutputPerCraft = outputAmount * (1 + supplier.totalProductivityBonus)
                let requiredCraftsPerSec = requiredInput / actualOutputPerCraft
                
                // Calculate supplier's target based on its primary output
                let supplierPrimaryOutput = supplierRecipe.outputs.first?.value ?? 1
                let supplierActualPrimary = supplierPrimaryOutput * (1 + supplier.totalProductivityBonus)
                let requiredTarget = requiredCraftsPerSec * supplierActualPrimary
                
                // Only update if not user-set
                if !userSetTargets.keys.contains(edge.fromNode) {
                    // For aggregation mode
                    if aggregate == .sum {
                        targets[edge.fromNode, default: 0] += requiredTarget
                    } else {
                        targets[edge.fromNode] = max(targets[edge.fromNode] ?? 0, requiredTarget)
                    }
                    
                    // Recursively propagate
                    propagateUpstream(
                        from: edge.fromNode,
                        craftsPerSec: requiredCraftsPerSec,
                        targets: &targets,
                        network: network
                    )
                }
            }
        }
    }
    
    private func propagateDownstream(
        from nodeID: UUID,
        targets: inout [UUID: Double],
        network: [UUID]
    ) {
        guard let node = nodes[nodeID],
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
              let nodeTarget = targets[nodeID] else {
            return
        }
        
        // Calculate actual production rates for each output
        let primaryOutput = recipe.outputs.first?.value ?? 1
        let actualPrimaryOutput = primaryOutput * (1 + node.totalProductivityBonus)
        let craftsPerSec = nodeTarget / actualPrimaryOutput
        
        // Find all consumers
        let outgoingEdges = edges.filter { $0.fromNode == nodeID }
        
        for edge in outgoingEdges {
            guard network.contains(edge.toNode),
                  !userSetTargets.keys.contains(edge.toNode),
                  let consumer = nodes[edge.toNode],
                  let consumerRecipe = RECIPES.first(where: { $0.id == consumer.recipeID }) else {
                continue
            }
            
            // Calculate how much of this item we're producing
            let outputAmount = recipe.outputs[edge.item] ?? 0
            let actualItemOutput = outputAmount * (1 + node.totalProductivityBonus)
            let itemProduced = craftsPerSec * actualItemOutput
            
            // Calculate consumer's required consumption rate
            let inputRequired = consumerRecipe.inputs[edge.item] ?? 0
            if inputRequired > 0 {
                let consumerCraftsPerSec = itemProduced / inputRequired
                
                // Calculate consumer's target based on its primary output
                let consumerPrimaryOutput = consumerRecipe.outputs.first?.value ?? 1
                let consumerActualOutput = consumerPrimaryOutput * (1 + consumer.totalProductivityBonus)
                let consumerTarget = consumerCraftsPerSec * consumerActualOutput
                
                // Update consumer's target (consider existing constraints)
                if let existingTarget = targets[edge.toNode] {
                    targets[edge.toNode] = min(existingTarget, consumerTarget)
                } else {
                    targets[edge.toNode] = consumerTarget
                }
                
                // IMPORTANT: Now propagate upstream from this consumer to update ITS suppliers
                let finalConsumerTarget = targets[edge.toNode]!
                let finalConsumerCrafts = finalConsumerTarget / consumerActualOutput
                propagateUpstream(from: edge.toNode, craftsPerSec: finalConsumerCrafts, targets: &targets, network: network)
                
                // Then continue propagating downstream
                propagateDownstream(from: edge.toNode, targets: &targets, network: network)
            }
        }
    }
    
    private func standardFlowComputation() {
        var targets: [UUID: Double] = [:]
        
        // Initialize with existing values
        for (id, node) in nodes {
            targets[id] = node.targetPerMin ?? 0
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
                
                let outputAmount = recipe.outputs.first?.value ?? 1
                let actualOutput = outputAmount * (1 + consumer.totalProductivityBonus)
                let craftsPerSec = (targets[consumer.id] ?? 0) / actualOutput
                let inputAmount = recipe.inputs[edge.item] ?? 0
                let totalNeed = craftsPerSec * inputAmount
                
                switch aggregate {
                case .sum:
                    needBySupplier[edge.fromNode, default: 0] += totalNeed
                case .max:
                    needBySupplier[edge.fromNode] = max(needBySupplier[edge.fromNode] ?? 0, totalNeed)
                }
            }
            
            for (supplierID, need) in needBySupplier {
                let currentTarget = targets[supplierID] ?? 0
                if abs(currentTarget - need) > Constants.computationTolerance {
                    targets[supplierID] = need
                    hasChanges = true
                }
            }
        }
        
        // Apply computed values
        for (id, targetValue) in targets {
            guard var node = nodes[id] else { continue }
            let roundedTarget = abs(targetValue - round(targetValue)) < 0.01 ?
                round(targetValue) : round(targetValue * 10) / 10
            if abs((node.targetPerMin ?? 0) - roundedTarget) > Constants.computationTolerance {
                node.targetPerMin = roundedTarget > 0 ? roundedTarget : nil
                nodes[id] = node
            }
        }
    }
    
    func triggerFlowComputation() {
        computeFlows()
    }
    
    // MARK: - Import/Export
    func exportJSON(from window: NSWindow?) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "factorio_plan.json"
        
        guard let targetWindow = window ?? NSApp.keyWindow else { return }
        
        savePanel.beginSheetModal(for: targetWindow) { response in
            guard response == .OK, let url = savePanel.url else { return }
            
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
        
        guard let targetWindow = window ?? NSApp.keyWindow else { return }
        
        openPanel.beginSheetModal(for: targetWindow) { response in
            guard response == .OK, let url = openPanel.url else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let graphState = try JSONDecoder().decode(GraphState.self, from: data)
                
                DispatchQueue.main.async {
                    self.nodes = graphState.nodes
                    self.edges = graphState.edges
                    self.userSetTargets = graphState.userSetTargets
                    self.selectedNodeID = nil
                    self.selectedNodeIDs = []
                    self.computeFlows()
                }
            } catch {
                DispatchQueue.main.async {
                    NSAlert(error: error).runModal()
                }
            }
        }
    }
}

// MARK: - Main App
@main
struct FactorioPlannerApp: App {
    @StateObject private var graph = GraphState()
    @StateObject private var preferences = MachinePreferences.load()
    
    var body: some Scene {
        WindowGroup("Factorio Planner") {
            PlannerRoot()
                .environmentObject(graph)
                .environmentObject(preferences)
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .pasteboard) {
                Button("Cut") {
                    graph.cutNode()
                }
                .keyboardShortcut("x", modifiers: [.command])
                .disabled(graph.selectedNodeID == nil)
                
                Button("Copy") {
                    graph.copyNode()
                }
                .keyboardShortcut("c", modifiers: [.command])
                .disabled(graph.selectedNodeID == nil)
                
                Button("Paste") {
                    graph.pasteNode()
                }
                .keyboardShortcut("v", modifiers: [.command])
                .disabled(graph.clipboard == nil)
                
                Divider()
                
                Button("Delete") {
                    graph.deleteSelectedNode()
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(graph.selectedNodeID == nil)
            }
            
            CommandGroup(after: .newItem) {
                Button("Add Recipe") {
                    graph.generalPickerDropPoint = graph.lastMousePosition
                    graph.showGeneralPicker = true
                }
                .keyboardShortcut("f", modifiers: [.command])
            }
        }
    }
}

// MARK: - Root View
struct PlannerRoot: View {
    @EnvironmentObject var graph: GraphState
    @State private var window: NSWindow?
    @State private var showClearConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack(spacing: 12) {
                Button("➕ Add Recipe") {
                    graph.generalPickerDropPoint = CGPoint(
                        x: 120 + .random(in: 0...80),
                        y: 160 + .random(in: 0...60)
                    )
                    graph.showGeneralPicker = true
                }
                .buttonStyle(.borderless)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .medium))
                
                Text("|")
                    .foregroundColor(Color.white.opacity(0.2))
                
                Menu("Preferences") {
                    Menu("Default Machines") {
                        ForEach(MACHINE_TIERS.keys.sorted(), id: \.self) { category in
                            if let tiers = MACHINE_TIERS[category], tiers.count > 1 {
                                Menu(machineName(for: category)) {
                                    ForEach(tiers, id: \.id) { tier in
                                        Button(tier.name) {
                                            let prefs = MachinePreferences.load()
                                            prefs.setDefaultTier(for: category, tierID: tier.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(.primary)
                
                Menu("Flow: \(graph.aggregate.rawValue)") {
                    ForEach(GraphState.Aggregate.allCases, id: \.self) { mode in
                        Button(mode.rawValue) {
                            graph.aggregate = mode
                            graph.computeFlows()
                        }
                    }
                }
                .buttonStyle(.borderless)
                .foregroundColor(.primary)
                
                Spacer()
                
                if graph.nodes.count > 0 {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("Auto-saved • \(graph.nodes.count) nodes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button("Clear") {
                    showClearConfirmation = true
                }
                .buttonStyle(.borderless)
                .foregroundColor(graph.nodes.isEmpty ? .secondary : .primary)
                .disabled(graph.nodes.isEmpty)
                .confirmationDialog("Clear Graph", isPresented: $showClearConfirmation) {
                    Button("Clear Everything", role: .destructive) {
                        graph.clearGraph()
                    }
                    Button("Cancel", role: .cancel) {}
                }
                
                Text("|")
                    .foregroundColor(Color.white.opacity(0.2))
                
                Button("Export") {
                    graph.exportJSON(from: NSApp.keyWindow)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.primary)
                
                Button("Import") {
                    graph.importJSON(from: NSApp.keyWindow)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(height: 48)
            .background(Color(white: 0.13))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            .zIndex(100)
            
            // Canvas
            CanvasView()
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WindowAccessor(window: $window))
        .sheet(isPresented: $graph.showPicker) {
            if let context = graph.pickerContext {
                RecipePicker(context: context)
            }
        }
        .sheet(isPresented: $graph.showGeneralPicker) {
            GeneralRecipePicker()
        }
        .onPreferenceChange(PortFramesKey.self) { frames in
            var frameDict: [PortKey: CGRect] = [:]
            for portFrame in frames {
                frameDict[portFrame.key] = portFrame.frame
            }
            graph.portFrames = frameDict
        }
    }
}

// MARK: - Canvas View
struct CanvasView: View {
    @EnvironmentObject var graph: GraphState
    @State private var isDraggingCanvas = false
    @State private var tempOffset: CGSize = .zero
    @State private var lastZoomTime: Date = Date()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Rectangle()
                    .fill(Color(white: 0.11))
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Unfocus any text fields
                        NSApp.keyWindow?.makeFirstResponder(nil)
                        graph.deselectAll()
                    }
                
                // Main canvas content
                ZStack {
                    // Grid dots
                    GridBackground()
                        .scaleEffect(graph.canvasScale)
                        .offset(x: graph.canvasOffset.width + tempOffset.width,
                               y: graph.canvasOffset.height + tempOffset.height)
                        .allowsHitTesting(false)
                    
                    // Wire renderer
                    WireRenderer()
                        .allowsHitTesting(false)
                    
                    // Node cards
                    ForEach(Array(graph.nodes.values), id: \.id) { node in
                        NodeCard(node: node)
                            .position(
                                x: node.x * graph.canvasScale + graph.canvasOffset.width + tempOffset.width,
                                y: node.y * graph.canvasScale + graph.canvasOffset.height + tempOffset.height
                            )
                            .scaleEffect(graph.canvasScale)
                            .overlay(
                                graph.selectedNodeIDs.contains(node.id) ?
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange, lineWidth: 2 / graph.canvasScale)
                                    .scaleEffect(1.05)
                                    .allowsHitTesting(false)
                                : nil
                            )
                    }
                }
                .coordinateSpace(name: "canvas")
                
                // Selection rectangle overlay
                if graph.isSelecting {
                    SelectionRectangle(
                        start: graph.selectionStart,
                        end: graph.selectionEnd
                    )
                        .scaleEffect(graph.canvasScale)
                        .offset(x: graph.canvasOffset.width + tempOffset.width,
                               y: graph.canvasOffset.height + tempOffset.height)
                        .allowsHitTesting(false)
                }
                
                // UI Controls overlay
                VStack {
                    HStack {
                        Spacer()
                        ZoomControls()
                            .padding()
                    }
                    Spacer()
                }
            }
            // Selection drag gesture
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if !NSEvent.modifierFlags.contains(.option) && !isDraggingCanvas {
                            let canvasLocation = CGPoint(
                                x: (value.startLocation.x - graph.canvasOffset.width) / graph.canvasScale,
                                y: (value.startLocation.y - graph.canvasOffset.height) / graph.canvasScale
                            )
                            
                            if !graph.isSelecting {
                                graph.isSelecting = true
                                graph.selectionStart = canvasLocation
                            }
                            
                            let currentLocation = CGPoint(
                                x: (value.location.x - graph.canvasOffset.width) / graph.canvasScale,
                                y: (value.location.y - graph.canvasOffset.height) / graph.canvasScale
                            )
                            graph.selectionEnd = currentLocation
                        }
                    }
                    .onEnded { _ in
                        if graph.isSelecting {
                            let rect = CGRect(
                                x: min(graph.selectionStart.x, graph.selectionEnd.x),
                                y: min(graph.selectionStart.y, graph.selectionEnd.y),
                                width: abs(graph.selectionEnd.x - graph.selectionStart.x),
                                height: abs(graph.selectionEnd.y - graph.selectionStart.y)
                            )
                            
                            graph.selectNodesInRect(rect)
                            graph.isSelecting = false
                        }
                    }
            )
            // Pan gesture with Option key
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if NSEvent.modifierFlags.contains(.option) {
                            isDraggingCanvas = true
                            tempOffset = value.translation
                        }
                    }
                    .onEnded { _ in
                        if isDraggingCanvas {
                            graph.canvasOffset.width += tempOffset.width
                            graph.canvasOffset.height += tempOffset.height
                            tempOffset = .zero
                            isDraggingCanvas = false
                        }
                        let currentScale = graph.canvasScale
                            graph.canvasScale = currentScale * 1.0001  // Tiny change
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                graph.canvasScale = currentScale  // Reset to exact value
                        }
                    }
            )
            // Zoom with scroll wheel
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    guard let window = NSApp.keyWindow,
                          window.firstResponder != nil else { return event }
                    
                    if !event.modifierFlags.contains(.option) {
                        // Throttle zoom events - only process every 16ms (60fps max)
                        let now = Date()
                        if now.timeIntervalSince(lastZoomTime) < 0.016 {
                            return event
                        }
                        lastZoomTime = now
                        
                        // Use stepped zoom instead of continuous
                        let zoomStep: Double = event.scrollingDeltaY > 0 ? 0.02 : -0.02  // Fixed step size
                        let newScale = max(0.3, min(3.0, graph.canvasScale + zoomStep))
                        
                        // Only update if there's a meaningful change
                        if abs(newScale - graph.canvasScale) > 0.01 {
                            // Get mouse location in window
                            let mouseLocation = window.contentView?.convert(event.locationInWindow, from: nil) ?? .zero
                            
                            // Calculate canvas location before zoom
                            let canvasLocationBefore = CGPoint(
                                x: (mouseLocation.x - graph.canvasOffset.width) / graph.canvasScale,
                                y: (mouseLocation.y - graph.canvasOffset.height) / graph.canvasScale
                            )
                            
                            graph.canvasScale = newScale
                            
                            // Adjust offset to keep mouse position stable
                            graph.canvasOffset.width = mouseLocation.x - canvasLocationBefore.x * graph.canvasScale
                            graph.canvasOffset.height = mouseLocation.y - canvasLocationBefore.y * graph.canvasScale
                        }
                    }
                    
                    return event
                }
            }
            // Mouse tracking
            .onContinuousHover { phase in
                switch phase {
                case .active(let location):
                    let canvasLocation = CGPoint(
                        x: (location.x - graph.canvasOffset.width) / graph.canvasScale,
                        y: (location.y - graph.canvasOffset.height) / graph.canvasScale
                    )
                    graph.lastMousePosition = canvasLocation
                case .ended:
                    break
                }
            }
            // Right-click context menu
            .contextMenu {
                Button("Add Recipe") {
                    graph.generalPickerDropPoint = graph.lastMousePosition
                    graph.showGeneralPicker = true
                }
                
                if !graph.selectedNodeIDs.isEmpty {
                    Divider()
                    
                    Button("Delete Selected") {
                        graph.deleteSelectedNodes()
                    }
                    
                    Button("Copy Selected") {
                        graph.copySelectedNodes()
                    }
                }
                
                if graph.canPaste() {
                    Button("Paste") {
                        graph.pasteNode()
                    }
                }
            }
        }
        .onKeyPress { key in
            switch key.key {
            case .delete:
                if !graph.selectedNodeIDs.isEmpty {
                    graph.deleteSelectedNodes()
                    return .handled
                }
            case .escape:
                graph.deselectAll()
                return .handled
            default:
                break
            }
            return .ignored
        }
    }
}

// MARK: - Canvas Controls
struct SelectionRectangle: View {
    let start: CGPoint
    let end: CGPoint
    
    private var rect: CGRect {
        CGRect(
            x: min(start.x, end.x),
            y: min(start.y, end.y),
            width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
    }
    
    var body: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.1))
            .overlay(
                Rectangle()
                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
            )
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}

struct ZoomControls: View {
    @EnvironmentObject var graph: GraphState
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    graph.canvasScale = min(3.0, graph.canvasScale + 0.2)
                }
            }) {
                Image(systemName: "plus.magnifyingglass")
                    .font(.system(size: 16))
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("+", modifiers: .command)
            
            Text("\(Int(graph.canvasScale * 100))%")
                .font(.caption2)
                .monospacedDigit()
                .frame(width: 40)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    graph.canvasScale = max(0.3, graph.canvasScale - 0.2)
                }
            }) {
                Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: 16))
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("-", modifiers: .command)
            
            Divider()
                .frame(width: 20)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    graph.canvasScale = 1.0
                    graph.canvasOffset = .zero
                }
            }) {
                Image(systemName: "1.square")
                    .font(.system(size: 16))
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("0", modifiers: .command)
            .help("Reset zoom")
        }
    }
}

struct GridBackground: View {
    var body: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(white: 0.12), location: 0),
                        .init(color: Color(white: 0.10), location: 1)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                )
            )
            .overlay(
                Canvas { context, size in
                    let dotPath = Path(CGRect(x: 0, y: 0, width: Constants.dotSize, height: Constants.dotSize))
                    
                    for x in stride(from: 25.0, through: size.width, by: Constants.gridSpacing) {
                        for y in stride(from: 25.0, through: size.height, by: Constants.gridSpacing) {
                            context.translateBy(x: x, y: y)
                            context.fill(dotPath, with: .color(Color.white.opacity(0.05)))
                            context.translateBy(x: -x, y: -y)
                        }
                    }
                }
            )
    }
}

// MARK: - Utility Views
struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Scroll Wheel Extension
extension View {
    func onScrollWheel(perform action: @escaping (NSEvent) -> Void) -> some View {
        self.background(ScrollWheelHandler(action: action))
    }
}

struct ScrollWheelHandler: NSViewRepresentable {
    let action: (NSEvent) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = ScrollDetectorView()
        view.onScroll = action
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    class ScrollDetectorView: NSView {
        var onScroll: ((NSEvent) -> Void)?
        
        override func scrollWheel(with event: NSEvent) {
            onScroll?(event)
        }
        
        override var acceptsFirstResponder: Bool { true }
    }
}

// MARK: - Icon Components
struct IconOrMonogram: View {
    var item: String
    var size: CGFloat = Constants.iconSize
    
    var body: some View {
        Group {
            if let assetName = ICON_ASSETS[item] {
                Image(assetName)
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Monogram(item: item, size: size)
            }
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
    }
}

struct ItemBadge: View {
    var item: String
    
    var body: some View {
        IconOrMonogram(item: item, size: Constants.iconSize)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.blue.opacity(0.35))
            )
            .frame(width: Constants.iconSize, height: Constants.iconSize)
    }
}

struct Monogram: View {
    var item: String
    var size: CGFloat = Constants.iconSize
    
    var body: some View {
        let initials = item.split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
        
        Text(String(initials))
            .font(.caption)
            .bold()
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.blue.opacity(0.35))
            )
    }
}

// MARK: - Tooltip
extension View {
    func hoverTooltip(_ text: String) -> some View {
        modifier(HoverTooltip(text: text))
    }
}

struct HoverTooltip: ViewModifier {
    var text: String
    @State private var hovering = false
    
    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                hovering = isHovering
            }
            .overlay(alignment: .top) {
                if hovering {
                    Tooltip(text: text)
                        .fixedSize(horizontal: true, vertical: true)
                        .offset(y: -26)
                        .zIndex(999)
                        .allowsHitTesting(false)
                }
            }
            .animation(.easeInOut(duration: 0.12), value: hovering)
    }
}

struct Tooltip: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.15))
            )
    }
}

// MARK: - Node Card
struct NodeCard: View {
    @EnvironmentObject var graph: GraphState
    var node: Node
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var rateText: String = ""
    @FocusState private var rateFocused: Bool
    
    private var isSelected: Bool {
        graph.selectedNodeID == node.id
    }
    
    private var recipe: Recipe? {
        RECIPES.first(where: { $0.id == node.recipeID })
    }
    
    private var hasQualityModules: Bool {
        node.modules.contains { $0?.type == .quality }
    }
    
    var body: some View {
        guard let recipe = recipe else {
            return AnyView(EmptyView())
        }
        
        let speedBinding = Binding<Double>(
            get: { graph.nodes[node.id]?.speedMultiplier ?? 1 },
            set: { value in
                guard var updatedNode = graph.nodes[node.id] else { return }
                updatedNode.speedMultiplier = max(Constants.minSpeed, value)
                graph.updateNode(updatedNode)
            }
        )
        
        let primaryItem = recipe.outputs.keys.first ?? recipe.inputs.keys.first ?? recipe.name
        let selectedTier = getSelectedMachineTier(for: node)
        
        return AnyView(
            VStack(alignment: .leading, spacing: 2) {
                // Header
                headerSection(primaryItem: primaryItem, selectedTier: selectedTier)
                
                // Controls
                controlsSection(speedBinding: speedBinding)
                
                Divider()
                
                // I/O Ports with machine icon in middle
                portsSection(recipe: recipe, selectedTier: selectedTier)
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
                // Force unfocus the rate field
                rateFocused = false
                graph.selectNode(node.id)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            graph.selectNode(node.id)
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        isDragging = false
                        
                        guard var updatedNode = graph.nodes[node.id] else { return }
                        updatedNode.x = node.x + value.translation.width / graph.canvasScale
                        updatedNode.y = node.y + value.translation.height / graph.canvasScale
                        
                        withAnimation(nil) {
                            graph.nodes[node.id] = updatedNode
                        }
                        
                        dragOffset = .zero
                        graph.computeFlows()
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
    
    @ViewBuilder
    private func headerSection(primaryItem: String, selectedTier: MachineTier?) -> some View {
        HStack(spacing: 6) {
            ItemBadge(item: primaryItem)
                .hoverTooltip(recipe?.name ?? "")
            
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
    }
    
    @ViewBuilder
    private func controlsSection(speedBinding: Binding<Double>) -> some View {
        HStack {
            HStack(spacing: 4) {
                TextField("Rate", text: Binding(
                    get: { rateText },
                    set: { text in
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
                .onReceive(NotificationCenter.default.publisher(for: NSTextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? NSTextField {
                        textField.selectText(nil)
                    }
                }
                
                Text("/s")
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
    }
    
    @ViewBuilder
    private func portsSection(recipe: Recipe, selectedTier: MachineTier?) -> some View {
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
                
                if let tier = selectedTier, tier.moduleSlots > 0 {
                    ModuleSlotsView(node: node, slotCount: tier.moduleSlots)
                }
                
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
                
                outputViews(recipe: recipe)
            }
        }
    }
    
    @ViewBuilder
    private func outputViews(recipe: Recipe) -> some View {
        ForEach(recipe.outputs.sorted(by: { $0.key < $1.key }), id: \.key) { item, amount in
            if hasQualityModules {
                // Show each quality tier as a separate row
                ForEach(Quality.allCases, id: \.self) { quality in
                    PortRow(nodeID: node.id, side: .output, item: item, amount: amount, quality: quality)
                        .font(.caption2)
                }
            } else {
                // Normal output
                PortRow(nodeID: node.id, side: .output, item: item, amount: amount, quality: .normal)
                    .font(.caption2)
            }
        }
    }
    
    private func updateRateText() {
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

// MARK: - Port Row Component
struct PortRow: View {
    @EnvironmentObject var graph: GraphState
    var nodeID: UUID
    var side: IOSide
    var item: String
    var amount: Double
    var quality: Quality = .normal
    
    @State private var centerInCanvas: CGPoint = .zero
    
    private var node: Node? {
        graph.nodes[nodeID]
    }
    
    private var totalQualityBonus: Double {
        guard let node = node else { return 0 }
        return node.modules.compactMap { module in
            if module?.type == .quality {
                let baseChance: Double = switch module?.level {
                    case 1: 0.01
                    case 2: 0.02
                    case 3: 0.025
                    default: 0.0
                }
                
                let multiplier: Double = switch module?.quality {
                    case .normal: 1.0
                    case .uncommon: 1.3
                    case .rare: 1.6
                    case .epic: 1.9
                    case .legendary: 2.5
                    default: 1.0
                }
                
                return baseChance * multiplier
            }
            return nil
        }.reduce(0, +)
    }
    
    private var flowRate: Double {
        guard let node = graph.nodes[nodeID],
              let targetPerSec = node.targetPerMin,
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return 0
        }
        
        if side == .output {
            // Calculate output flow
            let primaryOutput = recipe.outputs.first?.value ?? 1
            let actualPrimaryOutput = primaryOutput * (1 + node.totalProductivityBonus)
            let craftsPerSec = targetPerSec / actualPrimaryOutput
            
            let thisItemAmount = amount * (1 + node.totalProductivityBonus)
            let baseFlow = craftsPerSec * thisItemAmount
            
            if totalQualityBonus > 0 {
                return calculateQualityFlow(baseFlow: baseFlow, forQuality: quality)
            }
            return quality == .normal ? baseFlow : 0
        } else {
            // Calculate input flow
            let primaryOutput = recipe.outputs.first?.value ?? 1
            let actualOutput = primaryOutput * (1 + node.totalProductivityBonus)
            let craftsPerSec = targetPerSec / actualOutput
            return craftsPerSec * amount
        }
    }
    
    private func calculateQualityFlow(baseFlow: Double, forQuality: Quality) -> Double {
        guard totalQualityBonus > 0 else {
            return forQuality == .normal ? baseFlow : 0
        }
        
        let qualityChance = min(totalQualityBonus, 1.0)
        
        switch forQuality {
        case .normal:
            return baseFlow * (1.0 - qualityChance)
        case .uncommon:
            return baseFlow * (qualityChance * 0.9)
        case .rare:
            return baseFlow * (qualityChance * 0.09)
        case .epic:
            return baseFlow * (qualityChance * 0.009)
        case .legendary:
            return baseFlow * (qualityChance * 0.001)
        }
    }
    
    private var flowRateText: String {
        if flowRate == 0 {
            if quality == .normal {
                return "×\(amount.formatted())"
            } else {
                return ""
            }
        } else if flowRate == floor(flowRate) {
            return String(format: "%.0f", flowRate)
        } else if flowRate < 0.1 {
            return String(format: "%.2f", flowRate)
        } else {
            return String(format: "%.1f", flowRate)
        }
    }
    
    private var itemDisplayName: String {
        if quality != .normal {
            return "\(item) (\(quality.rawValue))"
        }
        return item
    }
    
    var body: some View {
        if flowRate > 0.001 || quality == .normal {
            HStack(spacing: 4) {
                if side == .input {
                    portContent()
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    portContent()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    @ViewBuilder
    private func portContent() -> some View {
        HStack(spacing: 4) {
            if side == .input {
                IconOrMonogram(item: item, size: 16)
                    .overlay(qualityIndicator(), alignment: .topTrailing)
                    .hoverTooltip(itemDisplayName)
                
                Text(flowRateText)
                    .foregroundStyle(flowRate > 0 ? .primary : .secondary)
                    .font(.caption2)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
            } else {
                Text(flowRateText)
                    .foregroundStyle(flowRate > 0 ? .primary : .secondary)
                    .font(.caption2)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
                
                IconOrMonogram(item: item, size: 16)
                    .overlay(qualityIndicator(), alignment: .topTrailing)
                    .hoverTooltip(itemDisplayName)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .frame(minWidth: 0)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isPortConnected(nodeID: nodeID, item: item, side: side, quality: quality, edges: graph.edges)
                      ? Color.clear
                      : Color.orange.opacity(0.3))
                .animation(.easeInOut(duration: 0.2), value: isPortConnected(nodeID: nodeID, item: item, side: side, quality: quality, edges: graph.edges))
        )
        .background(
            GeometryReader { geometry in
                let frame = geometry.frame(in: .named("canvas"))
                Color.clear
                    .onAppear {
                        updateCenterInCanvas(frame)
                    }
                    .onChange(of: frame) { _, newFrame in
                        updateCenterInCanvas(newFrame)
                    }
                    .preference(
                        key: PortFramesKey.self,
                        value: [PortFrame(
                            key: PortKey(nodeID: nodeID, item: item, side: side, quality: quality),
                            frame: CGRect(x: centerInCanvas.x - 5, y: centerInCanvas.y - 5, width: 10, height: 10)
                        )]
                    )
            }
        )
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { _ in
                    handleDragEnd()
                }
        )
    }
    
    @ViewBuilder
    private func qualityIndicator() -> some View {
        if quality != .normal {
            Circle()
                .fill(quality.color)
                .frame(width: 6, height: 6)
                .offset(x: 6, y: -2)
        }
    }
    
    private func updateCenterInCanvas(_ frame: CGRect) {
        let canvasX = (frame.midX - graph.canvasOffset.width) / graph.canvasScale
        let canvasY = (frame.midY - graph.canvasOffset.height) / graph.canvasScale
        centerInCanvas = CGPoint(x: canvasX, y: canvasY)
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let startPoint = centerInCanvas
        let currentPoint = CGPoint(
            x: startPoint.x + value.translation.width / graph.canvasScale,
            y: startPoint.y + value.translation.height / graph.canvasScale
        )
        
        if graph.dragging == nil {
            graph.dragging = DragContext(
                fromPort: PortKey(nodeID: nodeID, item: item, side: side, quality: quality),
                startPoint: startPoint,
                currentPoint: currentPoint
            )
        } else {
            graph.dragging?.currentPoint = currentPoint
        }
    }
    
    private func handleDragEnd() {
        guard let dragContext = graph.dragging else { return }
        
        let currentPoint = dragContext.currentPoint
        let oppositeSide = side.opposite
        
        let hitPort = graph.portFrames.first { portKey, rect in
            portKey.item == item &&
            portKey.side == oppositeSide &&
            (portKey.quality == quality || (side == .output && portKey.quality == .normal)) &&
            rect.insetBy(dx: -8, dy: -8).contains(currentPoint)
        }?.key
        
        if let targetPort = hitPort {
            if side == .output {
                graph.addEdge(from: nodeID, to: targetPort.nodeID, item: item, quality: quality)
            } else {
                graph.addEdge(from: targetPort.nodeID, to: nodeID, item: item, quality: targetPort.quality)
            }
        } else {
            graph.pickerContext = PickerContext(
                fromPort: PortKey(nodeID: nodeID, item: item, side: side, quality: quality),
                dropPoint: currentPoint
            )
            graph.showPicker = true
        }
        
        graph.dragging = nil
    }
}

// MARK: - Machine Icon
struct MachineIcon: View {
    var node: Node
    @EnvironmentObject var graph: GraphState
    
    var body: some View {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return AnyView(EmptyView())
        }
        
        let selectedTier = getSelectedMachineTier(for: node)
        let iconColor = machineIconColor(for: recipe.category)
        
        return AnyView(
            Group {
                if let tier = selectedTier, let assetName = tier.iconAsset {
                    Image(assetName)
                        .renderingMode(.original)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                } else if let assetName = ICON_ASSETS[recipe.category] {
                    Image(assetName)
                        .renderingMode(.original)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                } else {
                    Image(systemName: machineIconName(for: recipe.category))
                        .font(.title2)
                        .foregroundStyle(iconColor)
                }
            }
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(iconColor.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture {
                cycleMachineTier(for: node)
            }
            .hoverTooltip(selectedTier?.name ?? machineName(for: recipe.category))
        )
    }
    
    private func cycleMachineTier(for node: Node) {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
              let tiers = MACHINE_TIERS[recipe.category],
              tiers.count > 1 else {
            return
        }
        
        var updatedNode = node
        
        let currentIndex: Int
        if let selectedTierID = node.selectedMachineTierID,
           let index = tiers.firstIndex(where: { $0.id == selectedTierID }) {
            currentIndex = index
        } else {
            currentIndex = 0
        }
        
        let nextIndex = (currentIndex + 1) % tiers.count
        let nextTier = tiers[nextIndex]
        
        updatedNode.selectedMachineTierID = nextTier.id
        updatedNode.modules = Array(repeating: nil, count: nextTier.moduleSlots)
        
        graph.updateNode(updatedNode)
    }
    
    private func machineIconName(for category: String) -> String {
        switch category {
        case "assembling": return "gearshape.2"
        case "smelting", "casting": return "flame"
        case "chemistry", "cryogenic": return "flask"
        case "biochamber": return "leaf"
        case "electromagnetic": return "bolt"
        case "crushing", "recycling": return "hammer"
        case "space-manufacturing": return "sparkles"
        case "centrifuging": return "tornado"
        case "rocket-building": return "airplane"
        case "mining": return "cube"
        case "quality": return "star"
        default: return "gearshape"
        }
    }
    
    private func machineIconColor(for category: String) -> Color {
        switch category {
        case "assembling": return .blue
        case "smelting", "casting": return .orange
        case "chemistry", "cryogenic": return .green
        case "biochamber": return Color.green
        case "electromagnetic": return .purple
        case "crushing", "recycling": return .gray
        case "space-manufacturing": return .cyan
        case "centrifuging": return .yellow
        case "rocket-building": return .red
        case "mining": return .brown
        case "quality": return .yellow
        default: return .secondary
        }
    }
}

// MARK: - Wire Rendering
struct WireRenderer: NSViewRepresentable {
    @EnvironmentObject var graph: GraphState
    
    func makeNSView(context: Context) -> WireRendererNSView {
        let view = WireRendererNSView()
        view.setGraphState(graph)
        return view
    }
    
    func updateNSView(_ nsView: WireRendererNSView, context: Context) {
        nsView.needsDisplay = true
    }
}

class WireRendererNSView: NSView {
    weak var graphState: GraphState?
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    func setGraphState(_ state: GraphState) {
        self.graphState = state
        
        cancellables.removeAll()
        
        state.$edges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        state.$portFrames
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        state.$dragging
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
        
        state.$nodes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext,
              let graphState = graphState else { return }
        
        drawWires(context: context, graphState: graphState, viewHeight: bounds.height)
        
        // Draw temporary drag wire on top
        if let dragging = graphState.dragging {
            let scale = graphState.canvasScale
            let offset = graphState.canvasOffset
            
            let fromPoint = CGPoint(
                x: dragging.startPoint.x * scale + offset.width,
                y: bounds.height - (dragging.startPoint.y * scale + offset.height)
            )
            let toPoint = CGPoint(
                x: dragging.currentPoint.x * scale + offset.width,
                y: bounds.height - (dragging.currentPoint.y * scale + offset.height)
            )
            drawTempWire(context: context, from: fromPoint, to: toPoint)
        }
    }
    
    private func drawWires(context: CGContext, graphState: GraphState, viewHeight: CGFloat) {
        context.setLineWidth(Constants.wireLineWidth)
        context.setStrokeColor(NSColor.orange.withAlphaComponent(0.9).cgColor)
        
        let scale = graphState.canvasScale
        let offset = graphState.canvasOffset
        
        // First pass: Draw all wires
        for edge in graphState.edges {
            let outputPortKey = PortKey(nodeID: edge.fromNode, item: edge.item, side: .output, quality: edge.quality)
            let inputPortKey = PortKey(nodeID: edge.toNode, item: edge.item, side: .input, quality: .normal)
            
            guard let fromRect = graphState.portFrames[outputPortKey],
                  let toRect = graphState.portFrames[inputPortKey] else {
                continue
            }
            
            let startPoint = CGPoint(
                x: fromRect.midX * scale + offset.width,
                y: viewHeight - (fromRect.midY * scale + offset.height)
            )
            let endPoint = CGPoint(
                x: toRect.midX * scale + offset.width,
                y: viewHeight - (toRect.midY * scale + offset.height)
            )
            
            drawCubicCurve(context: context, from: startPoint, to: endPoint)
        }
        
        // Second pass: Draw all labels on top of wires
        for edge in graphState.edges {
            let outputPortKey = PortKey(nodeID: edge.fromNode, item: edge.item, side: .output, quality: edge.quality)
            let inputPortKey = PortKey(nodeID: edge.toNode, item: edge.item, side: .input, quality: .normal)
            
            guard let fromRect = graphState.portFrames[outputPortKey],
                  let toRect = graphState.portFrames[inputPortKey] else {
                continue
            }
            
            let startPoint = CGPoint(
                x: fromRect.midX * scale + offset.width,
                y: viewHeight - (fromRect.midY * scale + offset.height)
            )
            let endPoint = CGPoint(
                x: toRect.midX * scale + offset.width,
                y: viewHeight - (toRect.midY * scale + offset.height)
            )
            
            let midPoint = CGPoint(
                x: (startPoint.x + endPoint.x) / 2,
                y: (startPoint.y + endPoint.y) / 2
            )
            drawFlowLabel(context: context, at: midPoint, edge: edge, graphState: graphState)
        }
    }
    
    private func drawCubicCurve(context: CGContext, from: CGPoint, to: CGPoint) {
        let path = CGMutablePath()
        path.move(to: from)
        
        let deltaX = max(abs(to.x - from.x) * 0.5, Constants.curveTension)
        let control1 = CGPoint(x: from.x + deltaX, y: from.y)
        let control2 = CGPoint(x: to.x - deltaX, y: to.y)
        
        path.addCurve(to: to, control1: control1, control2: control2)
        context.addPath(path)
        context.strokePath()
    }
    
    private func drawTempWire(context: CGContext, from: CGPoint, to: CGPoint) {
        context.saveGState()
        context.setLineWidth(Constants.wireLineWidth)
        context.setStrokeColor(NSColor.blue.withAlphaComponent(0.8).cgColor)
        context.setLineDash(phase: 0, lengths: [6, 6])
        
        drawCubicCurve(context: context, from: from, to: to)
        context.restoreGState()
    }
    
    private func drawFlowLabel(context: CGContext, at point: CGPoint, edge: Edge, graphState: GraphState) {
        guard let consumerNode = graphState.nodes[edge.toNode],
              let consumerRecipe = RECIPES.first(where: { $0.id == consumerNode.recipeID }),
              let targetPerSec = consumerNode.targetPerMin,
              targetPerSec > 0 else { return }
        
        let outputAmount = consumerRecipe.outputs.first?.value ?? 1
        let actualOutput = outputAmount * (1 + consumerNode.totalProductivityBonus)
        let craftsPerSec = targetPerSec / actualOutput
        let inputAmount = consumerRecipe.inputs[edge.item] ?? 0
        let flowRate = craftsPerSec * inputAmount
        
        let flowText = flowRate == floor(flowRate) ?
            String(format: "%.0f", flowRate) :
            String(format: "%.1f", flowRate)
        
        // Calculate text size
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 12)
        ]
        let textSize = flowText.size(withAttributes: attrs)
        let padding: CGFloat = 4
        let boxRect = CGRect(x: point.x - textSize.width/2 - padding,
                             y: point.y - textSize.height/2 - padding/2,
                             width: textSize.width + padding * 2,
                             height: textSize.height + padding)
        
        // Draw background
        let roundedPath = CGPath(roundedRect: boxRect, cornerWidth: 4, cornerHeight: 4, transform: nil)
        context.setFillColor(NSColor.orange.withAlphaComponent(0.9).cgColor)
        context.addPath(roundedPath)
        context.fillPath()
        
        // Draw border
        context.setStrokeColor(NSColor.orange.withAlphaComponent(0.6).cgColor)
        context.setLineWidth(1)
        context.addPath(roundedPath)
        context.strokePath()
        
        // Draw text
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        
        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 12),
            .foregroundColor: NSColor.black
        ]
        
        let textRect = CGRect(x: point.x - textSize.width/2,
                              y: point.y - textSize.height/2,
                              width: textSize.width,
                              height: textSize.height)
        
        flowText.draw(in: textRect, withAttributes: textAttrs)
        
        NSGraphicsContext.restoreGraphicsState()
    }
}

// MARK: - Module System Components
struct ModuleSlotsView: View {
    @EnvironmentObject var graph: GraphState
    var node: Node
    var slotCount: Int
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Modules")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 2) {
                ForEach(0..<slotCount, id: \.self) { index in
                    ModuleSlot(node: node, slotIndex: index)
                }
            }
        }
    }
}

struct ModuleSlot: View {
    @EnvironmentObject var graph: GraphState
    var node: Node
    var slotIndex: Int
    @State private var showModulePicker = false
    @State private var showQualityPicker = false
    @State private var selectedModuleBase: (type: ModuleType, level: Int)? = nil
    
    private var currentModule: Module? {
        if slotIndex < node.modules.count {
            return node.modules[slotIndex]
        }
        return nil
    }
    
    private var hasRestrictions: Bool {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return false
        }
        
        let testProductivityModule = Module(
            id: "test", name: "Test", type: .productivity, level: 1,
            quality: .normal, speedBonus: 0, productivityBonus: 0.1,
            efficiencyBonus: 0, iconAsset: nil
        )
        
        return !canUseModule(testProductivityModule, forRecipe: recipe)
    }
    
    private var canPasteModule: Bool {
        guard let copiedModule = graph.copiedModule,
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return false
        }
        return canUseModule(copiedModule, forRecipe: recipe)
    }
    
    var body: some View {
        Button(action: {
            if currentModule == nil {
                showModulePicker = true
            } else {
                showQualityPicker = true
            }
        }) {
            Group {
                if let module = currentModule {
                    ModuleIcon(module: module, size: 12)
                } else {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: hasRestrictions ? "plus.circle" : "plus")
                                .font(.system(size: 6))
                                .foregroundStyle(hasRestrictions ? .orange : .secondary)
                        )
                        .frame(width: 12, height: 12)
                }
            }
        }
        .buttonStyle(.plain)
        .help(currentModule?.displayName ?? (hasRestrictions ? "This recipe has module restrictions" : "Add module"))
        .contextMenu {
            if let module = currentModule {
                Button(action: {
                    copyModule()
                }) {
                    Label("Copy Module", systemImage: "doc.on.doc")
                }
                
                Button(action: {
                    showQualityPicker = true
                }) {
                    Label("Change Quality", systemImage: "star")
                }
                
                Divider()
                
                Button(action: {
                    removeModule()
                }) {
                    Label("Remove Module", systemImage: "trash")
                }
            } else if graph.copiedModule != nil {
                Button(action: {
                    pasteModule()
                }) {
                    Label("Paste Module", systemImage: "doc.on.clipboard")
                }
                .disabled(!canPasteModule)
            }
            
            if graph.copiedModule != nil {
                Button(action: {
                    pasteToAllSlots()
                }) {
                    Label("Paste to All Slots", systemImage: "doc.on.doc.fill")
                }
                .disabled(!canPasteModule)
            }
            
            if currentModule != nil {
                Button(action: {
                    clearAllSlots()
                }) {
                    Label("Clear All Slots", systemImage: "xmark.circle")
                }
            }
        }
        .popover(isPresented: $showModulePicker) {
            ModuleGridPicker(
                node: node,
                slotIndex: slotIndex,
                onSelect: { type, level in
                    selectedModuleBase = (type, level)
                    showModulePicker = false
                    showQualityPicker = true
                },
                onClose: {
                    showModulePicker = false
                }
            )
        }
        .popover(isPresented: $showQualityPicker) {
            QualityPicker(
                onSelect: { quality in
                    if let base = selectedModuleBase {
                        installModule(type: base.type, level: base.level, quality: quality)
                    } else if let current = currentModule {
                        installModule(type: current.type, level: current.level, quality: quality)
                    }
                    showQualityPicker = false
                    selectedModuleBase = nil
                },
                onClose: {
                    showQualityPicker = false
                    selectedModuleBase = nil
                }
            )
        }
    }
    
    private func installModule(type: ModuleType, level: Int, quality: Quality) {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else { return }
        
        let module = MODULES.first { mod in
            mod.type == type &&
            mod.level == level &&
            mod.quality == quality
        }
        
        guard let module = module,
              canUseModule(module, forRecipe: recipe) else {
            return
        }
        
        var updatedNode = node
        
        while updatedNode.modules.count <= slotIndex {
            updatedNode.modules.append(nil)
        }
        
        updatedNode.modules[slotIndex] = module
        graph.updateNode(updatedNode)
    }
    
    private func copyModule() {
        if let module = currentModule {
            graph.copiedModule = module
        }
    }
    
    private func pasteModule() {
        guard let copiedModule = graph.copiedModule,
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
              canUseModule(copiedModule, forRecipe: recipe) else {
            return
        }
        
        var updatedNode = node
        
        while updatedNode.modules.count <= slotIndex {
            updatedNode.modules.append(nil)
        }
        
        updatedNode.modules[slotIndex] = copiedModule
        graph.updateNode(updatedNode)
    }
    
    private func removeModule() {
        var updatedNode = node
        if slotIndex < updatedNode.modules.count {
            updatedNode.modules[slotIndex] = nil
        }
        graph.updateNode(updatedNode)
    }
    
    private func pasteToAllSlots() {
        guard let copiedModule = graph.copiedModule,
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
              canUseModule(copiedModule, forRecipe: recipe),
              let selectedTier = getSelectedMachineTier(for: node) else {
            return
        }
        
        var updatedNode = node
        updatedNode.modules = Array(repeating: copiedModule, count: selectedTier.moduleSlots)
        graph.updateNode(updatedNode)
    }
    
    private func clearAllSlots() {
        guard let selectedTier = getSelectedMachineTier(for: node) else {
            return
        }
        
        var updatedNode = node
        updatedNode.modules = Array(repeating: nil, count: selectedTier.moduleSlots)
        graph.updateNode(updatedNode)
    }
}

struct ModuleIcon: View {
    var module: Module
    var size: CGFloat = 18
    
    var body: some View {
        Group {
            if let assetName = module.iconAsset {
                Image(assetName)
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(module.type.color.opacity(0.8))
                    .overlay(
                        Text(String(module.type.rawValue.first ?? "M"))
                            .font(.system(size: size * 0.5, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(module.quality.color, lineWidth: 1)
        )
        .hoverTooltip(module.displayName)
    }
}

struct ModuleStatsView: View {
    var node: Node
    
    var body: some View {
        VStack(spacing: 1) {
            if node.totalSpeedBonus != 0 {
                HStack(spacing: 2) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 8))
                    Text(formatBonus(node.totalSpeedBonus))
                        .font(.system(size: 8))
                        .monospacedDigit()
                }
                .foregroundStyle(node.totalSpeedBonus > 0 ? .green : .red)
            }
            
            if node.totalProductivityBonus != 0 {
                HStack(spacing: 2) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 8))
                    Text(formatBonus(node.totalProductivityBonus))
                        .font(.system(size: 8))
                        .monospacedDigit()
                }
                .foregroundStyle(.orange)
            }
            
            if node.totalEfficiencyBonus != 0 {
                HStack(spacing: 2) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 8))
                    Text(formatBonus(node.totalEfficiencyBonus))
                        .font(.system(size: 8))
                        .monospacedDigit()
                }
                .foregroundStyle(node.totalEfficiencyBonus > 0 ? .green : .red)
            }
        }
    }
    
    private func formatBonus(_ value: Double) -> String {
        let percentage = value * 100
        let sign = percentage >= 0 ? "+" : ""
        return "\(sign)\(Int(percentage))%"
    }
}

struct ModuleGridPicker: View {
    var node: Node
    var slotIndex: Int
    var onSelect: (ModuleType, Int) -> Void
    var onClose: () -> Void
    
    private var recipe: Recipe? {
        RECIPES.first(where: { $0.id == node.recipeID })
    }
    
    private func canUseModuleType(_ type: ModuleType) -> Bool {
        guard let recipe = recipe else { return false }
        
        let testModule = switch type {
        case .speed:
            Module(id: "test", name: "Test", type: type, level: 1, quality: .normal,
                  speedBonus: 0.2, productivityBonus: 0, efficiencyBonus: -0.5, iconAsset: nil)
        case .productivity:
            Module(id: "test", name: "Test", type: type, level: 1, quality: .normal,
                  speedBonus: -0.15, productivityBonus: 0.04, efficiencyBonus: -0.8, iconAsset: nil)
        case .efficiency:
            Module(id: "test", name: "Test", type: type, level: 1, quality: .normal,
                  speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.3, iconAsset: nil)
        case .quality:
            Module(id: "test", name: "Test", type: type, level: 1, quality: .normal,
                  speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: nil)
        }
        
        return canUseModule(testModule, forRecipe: recipe)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Select Module")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 4) {
                ForEach([ModuleType.speed, .productivity, .efficiency, .quality], id: \.self) { type in
                    HStack(spacing: 4) {
                        ForEach(1...3, id: \.self) { level in
                            ModuleGridButton(
                                type: type,
                                level: level,
                                enabled: canUseModuleType(type),
                                action: {
                                    onSelect(type, level)
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(10)
        .frame(width: 140)
    }
}

struct ModuleGridButton: View {
    var type: ModuleType
    var level: Int
    var enabled: Bool
    var action: () -> Void
    
    private var iconAsset: String? {
        let baseName = switch type {
        case .speed: "speed_module"
        case .productivity: "productivity_module"
        case .efficiency: "efficiency_module"
        case .quality: "quality_module"
        }
        
        return level == 1 ? baseName : "\(baseName)_\(level)"
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                if let asset = iconAsset {
                    Image(asset)
                        .renderingMode(.original)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .opacity(enabled ? 1.0 : 0.3)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(type.color.opacity(enabled ? 0.8 : 0.2))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(level)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        )
                }
                
                HStack(spacing: 1) {
                    ForEach(1...3, id: \.self) { i in
                        Circle()
                            .fill(i <= level ? type.color : Color.gray.opacity(0.3))
                            .frame(width: 3, height: 3)
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(enabled ? 0.05 : 0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(type.color.opacity(enabled ? 0.3 : 0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .help("\(type.rawValue) Module \(level)")
    }
}

struct QualityPicker: View {
    var onSelect: (Quality) -> Void
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Select Quality")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
            }
            
            VStack(spacing: 4) {
                ForEach(Quality.allCases, id: \.self) { quality in
                    Button(action: {
                        onSelect(quality)
                    }) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(quality.color)
                                .frame(width: 10, height: 10)
                            
                            Text(quality.rawValue)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if quality == .normal {
                                Text("Default")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(10)
        .frame(width: 140)
    }
}

// MARK: - General Recipe Picker
struct GeneralRecipePicker: View {
    @EnvironmentObject var graph: GraphState
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var selectedIndex: Int = 0
    @FocusState private var searchFieldFocused: Bool
    
    private var categories: [String] {
        let allCategories = Set(RECIPES.map { $0.category })
        return ["All"] + allCategories.sorted()
    }
    
    private var filteredRecipes: [Recipe] {
        var recipes = RECIPES
        
        if selectedCategory != "All" {
            recipes = recipes.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            recipes = recipes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return recipes.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Choose Recipe")
                    .font(.headline)
                Spacer()
                Button("Close") {
                    graph.showGeneralPicker = false
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            
            HStack(spacing: 12) {
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 140)
                
                TextField("Search recipes...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .focused($searchFieldFocused)
                    .onSubmit {
                        if selectedIndex >= 0 && selectedIndex < filteredRecipes.count {
                            selectRecipe(filteredRecipes[selectedIndex])
                        }
                    }
                    .onChange(of: searchText) { _, _ in
                        selectedIndex = 0
                    }
            }
    
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(filteredRecipes.enumerated()), id: \.element.id) { index, recipe in
                            RecipeListRow(
                                recipe: recipe,
                                isSelected: index == selectedIndex,
                                onSelect: {
                                    selectRecipe(recipe)
                                }
                            )
                            .id(recipe.id)
                            .onHover { isHovered in
                                if isHovered {
                                    selectedIndex = index
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            
            if filteredRecipes.isEmpty {
                Text("No recipes found")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding(16)
        .frame(minWidth: 520, minHeight: 400)
        .onAppear {
            searchFieldFocused = true
            selectedIndex = 0
        }
        .onKeyPress(phases: .down) { press in
            handleKeyPress(press)
        }
    }
    
    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .downArrow:
            if selectedIndex < filteredRecipes.count - 1 {
                selectedIndex += 1
            }
            return .handled
        case .upArrow:
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            return .handled
        case .return:
            if selectedIndex >= 0 && selectedIndex < filteredRecipes.count {
                selectRecipe(filteredRecipes[selectedIndex])
            }
            return .handled
        default:
            return .ignored
        }
    }
    
    private func selectRecipe(_ recipe: Recipe) {
        graph.showGeneralPicker = false
        graph.addNode(recipeID: recipe.id, at: graph.generalPickerDropPoint)
    }
}

// MARK: - Recipe Picker (for port connections)
struct RecipePicker: View {
    @EnvironmentObject var graph: GraphState
    var context: PickerContext
    @State private var searchText = ""
    @State private var selectedIndex: Int = 0
    @FocusState private var searchFieldFocused: Bool
    
    private var availableRecipes: [Recipe] {
        let recipes = switch context.fromPort.side {
        case .output:
            ITEM_TO_CONSUMERS[context.fromPort.item] ?? []
        case .input:
            ITEM_TO_PRODUCERS[context.fromPort.item] ?? []
        }
        
        if searchText.isEmpty {
            return recipes.sorted { $0.name < $1.name }
        } else {
            return recipes
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 40, height: 40)
                        
                        IconOrMonogram(item: context.fromPort.item, size: 32)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(titleText)
                            .font(.headline)
                        
                        HStack(spacing: 4) {
                            Text(context.fromPort.item)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary.opacity(0.9))
                        }
                    }
                }
                
                Spacer()
                
                Button("Close") {
                    graph.showPicker = false
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            
            Divider()
            
            TextField("Search recipes...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .focused($searchFieldFocused)
                .onSubmit {
                    if selectedIndex >= 0 && selectedIndex < availableRecipes.count {
                        selectRecipe(availableRecipes[selectedIndex])
                    }
                }
                .onChange(of: searchText) { _, _ in
                    selectedIndex = 0
                }
            
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(availableRecipes.enumerated()), id: \.element.id) { index, recipe in
                            RecipeListRow(
                                recipe: recipe,
                                isSelected: index == selectedIndex,
                                onSelect: {
                                    selectRecipe(recipe)
                                }
                            )
                            .id(recipe.id)
                            .onHover { isHovered in
                                if isHovered {
                                    selectedIndex = index
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            
            if availableRecipes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    
                    Text("No recipes found")
                        .foregroundStyle(.secondary)
                    
                    if context.fromPort.side == .input {
                        Text("'\(context.fromPort.item)' might be a raw resource or needs to be obtained differently")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
        }
        .padding(16)
        .frame(minWidth: 480, minHeight: 400)
        .onAppear {
            searchFieldFocused = true
            selectedIndex = 0
        }
        .onKeyPress(phases: .down) { press in
            handleKeyPress(press)
        }
    }
    
    private var titleText: String {
        switch context.fromPort.side {
        case .output:
            return "What uses this?"
        case .input:
            return "How to make this?"
        }
    }
    
    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case .downArrow:
            if selectedIndex < availableRecipes.count - 1 {
                selectedIndex += 1
            }
            return .handled
        case .upArrow:
            if selectedIndex > 0 {
                selectedIndex -= 1
            }
            return .handled
        case .return:
            if selectedIndex >= 0 && selectedIndex < availableRecipes.count {
                selectRecipe(availableRecipes[selectedIndex])
            }
            return .handled
        default:
            return .ignored
        }
    }
    
    private func selectRecipe(_ recipe: Recipe) {
        graph.showPicker = false
        
        let nodePosition: CGPoint
        switch context.fromPort.side {
        case .output:
            nodePosition = CGPoint(
                x: context.dropPoint.x + 140,
                y: context.dropPoint.y - 60
            )
        case .input:
            nodePosition = CGPoint(
                x: context.dropPoint.x - 140,
                y: context.dropPoint.y - 60
            )
        }
        
        let newNode = graph.addNode(recipeID: recipe.id, at: nodePosition)
        
        switch context.fromPort.side {
        case .output:
            graph.addEdge(from: context.fromPort.nodeID, to: newNode.id, item: context.fromPort.item, quality: context.fromPort.quality)
        case .input:
            graph.addEdge(from: newNode.id, to: context.fromPort.nodeID, item: context.fromPort.item, quality: context.fromPort.quality)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            graph.triggerFlowComputation()
        }
    }
}

// MARK: - Recipe List Row
struct RecipeListRow: View {
    var recipe: Recipe
    var isSelected: Bool = false
    var onSelect: () -> Void
    @State private var isHovered = false
    
    private var isAlternative: Bool {
        return isAlternativeRecipe(recipe)
    }
    
    private var primaryOutputItem: String {
        if let firstOutput = recipe.outputs.keys.first {
            return firstOutput
        }
        return recipe.name
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if isAlternative {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 4, height: 40)
            }
            
            IconOrMonogram(item: primaryOutputItem, size: 32)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(recipe.name)
                        .font(.system(.body, weight: .medium))
                        .foregroundStyle(isAlternative ? .blue : .primary)
                    
                    if isAlternative {
                        Text("ALT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .cornerRadius(4)
                    }
                    
                    Text(recipe.category)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text("\(recipe.time, specifier: "%.1f")s")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 16) {
                    if !recipe.inputs.isEmpty {
                        HStack(spacing: 4) {
                            Text("In:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ForEach(recipe.inputs.sorted(by: { $0.key < $1.key }).prefix(4), id: \.key) { item, amount in
                                HStack(spacing: 2) {
                                    IconOrMonogram(item: item, size: 12)
                                    Text("×\(amount, format: .number)")
                                        .font(.caption)
                                }
                            }
                            if recipe.inputs.count > 4 {
                                Text("+\(recipe.inputs.count - 4)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    
                    if !recipe.outputs.isEmpty {
                        HStack(spacing: 4) {
                            Text("Out:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ForEach(recipe.outputs.sorted(by: { $0.key < $1.key }).prefix(3), id: \.key) { item, amount in
                                HStack(spacing: 2) {
                                    IconOrMonogram(item: item, size: 12)
                                    Text("×\(amount, format: .number)")
                                        .font(.caption)
                                }
                            }
                            if recipe.outputs.count > 3 {
                                Text("+\(recipe.outputs.count - 3)")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onSelect()
        }
    }
    
    private var backgroundFill: Color {
        if isSelected {
            return isAlternative ? Color.blue.opacity(0.25) : Color.white.opacity(0.15)
        } else if isAlternative && isHovered {
            return Color.blue.opacity(0.15)
        } else if isAlternative {
            return Color.blue.opacity(0.08)
        } else if isHovered {
            return Color.white.opacity(0.08)
        } else {
            return Color.white.opacity(0.03)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return isAlternative ? Color.blue.opacity(0.5) : Color.white.opacity(0.3)
        } else if isAlternative {
            return Color.blue.opacity(0.3)
        } else {
            return Color.white.opacity(isHovered ? 0.15 : 0.05)
        }
    }
}

// MARK: - Helper Functions
func getSelectedMachineTier(for node: Node, preferences: MachinePreferences? = nil) -> MachineTier? {
    guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }),
          let tiers = MACHINE_TIERS[recipe.category] else {
        return nil
    }
    
    if let selectedTierID = node.selectedMachineTierID,
       let tier = tiers.first(where: { $0.id == selectedTierID }) {
        return tier
    }
    
    // Fix: Use nil-coalescing operator to provide default if preferences is nil
    let prefs = preferences ?? MachinePreferences.load()
    if let defaultTierID = prefs.getDefaultTier(for: recipe.category),
       let tier = tiers.first(where: { $0.id == defaultTierID }) {
        return tier
    }
    
    return tiers.first
}

func canUseModule(_ module: Module, forRecipe recipe: Recipe) -> Bool {
    // Check if this is a productivity module
    if module.type == .productivity {
        // Check if the recipe produces any intermediate products
        let producesIntermediate = recipe.outputs.keys.contains { output in
            INTERMEDIATE_PRODUCTS.contains(output)
        }
        
        // Productivity modules can only be used on recipes that produce intermediates
        return producesIntermediate
    }
    
    // Quality modules have some restrictions too
    if module.type == .quality {
        // Quality modules can't be used on recipes that produce fluids
        let fluidOutputs: Set<String> = [
            "Water", "Steam", "Crude Oil", "Heavy Oil", "Light Oil", "Petroleum Gas",
            "Sulfuric Acid", "Lubricant", "Molten Iron", "Molten Copper", "Holmium Solution",
            "Ammonia", "Fluorine", "Nitrogen", "Hydrogen", "Oxygen", "Lava"
        ]
        
        let hasFluidOutput = recipe.outputs.keys.contains { output in
            fluidOutputs.contains(output)
        }
        
        // Can't use quality modules on fluid recipes
        if hasFluidOutput {
            return false
        }
    }
    
    // Speed and efficiency modules can be used on any recipe
    return true
}

func getEffectiveSpeed(for node: Node) -> Double {
    let baseSpeed = if let selectedTier = getSelectedMachineTier(for: node) {
        selectedTier.speed
    } else {
        1.0
    }
    
    let moduleSpeedBonus = node.totalSpeedBonus
    let effectiveSpeed = (baseSpeed * (1 + moduleSpeedBonus)) * node.speedMultiplier
    
    return max(Constants.minSpeed, effectiveSpeed)
}

func formatMachineCount(_ count: Double) -> String {
    if count == floor(count) {
        return String(format: "%.0f", count)
    } else {
        return String(format: "%.1f", count)
    }
}

func machineName(for category: String) -> String {
    switch category {
    case "assembling": return "Assembling Machine"
    case "smelting": return "Furnace"
    case "casting": return "Foundry"
    case "chemistry": return "Chemical Plant"
    case "cryogenic": return "Cryogenic Plant"
    case "biochamber": return "Biochamber"
    case "electromagnetic": return "Electromagnetic Plant"
    case "crushing": return "Crusher"
    case "recycling": return "Recycler"
    case "space-manufacturing": return "Space Platform"
    case "centrifuging": return "Centrifuge"
    case "rocket-building": return "Rocket Silo"
    case "mining": return "Mining Drill"
    case "quality": return "Quality Module"
    case "oil-refinery": return "Oil Refinery"
    default: return category.capitalized
    }
}

func machineCount(for node: Node) -> Double {
    guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
        return 0
    }
    
    let outputAmount = recipe.outputs.first?.value ?? 1
    let actualOutput = outputAmount * (1 + node.totalProductivityBonus)
    let craftsPerSec = (node.targetPerMin ?? 0) / actualOutput
    let machines = (craftsPerSec * recipe.time) / max(Constants.minSpeed, node.speed)
    
    return machines
}

func isPortConnected(nodeID: UUID, item: String, side: IOSide, quality: Quality = .normal, edges: [Edge]) -> Bool {
    return edges.contains { edge in
        switch side {
        case .output:
            return edge.fromNode == nodeID && edge.item == item && edge.quality == quality
        case .input:
            return edge.toNode == nodeID && edge.item == item
        }
    }
}

func isAlternativeRecipe(_ recipe: Recipe) -> Bool {
    return ALTERNATIVE_RECIPE_IDS.contains(recipe.id)
}

// MARK: - Alternative Recipe IDs
let ALTERNATIVE_RECIPE_IDS: Set<String> = [
    // Alternative oil processing
    "solid-fuel-from-light-oil",
    "solid-fuel-from-petroleum",
    "solid-fuel-from-heavy-oil",
    
    // Alternative molten metal recipes (Foundry)
    "iron-plate-from-molten",
    "copper-plate-from-molten",
    "steel-plate-from-molten",
    "molten-iron-from-lava",
    "molten-copper-from-lava",
    "casting-copper-cable",
    "casting-iron-gear-wheel",
    "casting-iron-stick",
    "casting-low-density-structure",
    "casting-pipe",
    "casting-pipe-to-ground",
    
    // Advanced asteroid crushing
    "advanced-metallic-asteroid-crushing",
    "advanced-carbonic-asteroid-crushing",
    "advanced-oxide-asteroid-crushing",
    
    // Biochamber alternatives
    "bioplastic",
    "biosulfur",
    "biolubricant",
    "rocket-fuel-from-jelly",
    "iron-bacteria-cultivation",
    "copper-bacteria-cultivation",
    
    // Cryogenic alternatives
    "solid-fuel-from-ammonia",
    "ammonia-rocket-fuel",
    
    // Nuclear processing alternatives
    "kovarex-enrichment-process",
    "nuclear-fuel-reprocessing",
    
    // Advanced oil processing
    "advanced-oil-processing",
    "coal-liquefaction",
    "heavy-oil-cracking",
    "light-oil-cracking"
]

// MARK: - Machine Tiers Data
let MACHINE_TIERS: [String: [MachineTier]] = [
    "assembling": [
        MachineTier(id: "assembling-1", name: "Assembling Machine 1", category: "assembling", speed: 0.5, iconAsset: "assembling_machine_1", moduleSlots: 0),
        MachineTier(id: "assembling-2", name: "Assembling Machine 2", category: "assembling", speed: 0.75, iconAsset: "assembling_machine_2", moduleSlots: 2),
        MachineTier(id: "assembling-3", name: "Assembling Machine 3", category: "assembling", speed: 1.25, iconAsset: "assembling_machine_3", moduleSlots: 4)
    ],
    "smelting": [
        MachineTier(id: "stone-furnace", name: "Stone Furnace", category: "smelting", speed: 1.0, iconAsset: "stone_furnace", moduleSlots: 0),
        MachineTier(id: "steel-furnace", name: "Steel Furnace", category: "smelting", speed: 2.0, iconAsset: "steel_furnace", moduleSlots: 0),
        MachineTier(id: "electric-furnace", name: "Electric Furnace", category: "smelting", speed: 2.0, iconAsset: "electric_furnace", moduleSlots: 2)
    ],
    "chemistry": [
        MachineTier(id: "chemical-plant", name: "Chemical Plant", category: "chemistry", speed: 1.0, iconAsset: "chemical_plant", moduleSlots: 3)
    ],
    "casting": [
        MachineTier(id: "foundry", name: "Foundry", category: "casting", speed: 2.0, iconAsset: "foundry", moduleSlots: 4)
    ],
    "cryogenic": [
        MachineTier(id: "cryogenic-plant", name: "Cryogenic Plant", category: "cryogenic", speed: 1.0, iconAsset: "cryogenic_plant", moduleSlots: 4)
    ],
    "biochamber": [
        MachineTier(id: "biochamber", name: "Biochamber", category: "biochamber", speed: 1.0, iconAsset: "biochamber", moduleSlots: 4)
    ],
    "electromagnetic": [
        MachineTier(id: "electromagnetic-plant", name: "Electromagnetic Plant", category: "electromagnetic", speed: 1.0, iconAsset: "electromagnetic_plant", moduleSlots: 5)
    ],
    "crushing": [
        MachineTier(id: "crusher", name: "Crusher", category: "crushing", speed: 1.0, iconAsset: "crusher", moduleSlots: 2)
    ],
    "recycling": [
        MachineTier(id: "recycler", name: "Recycler", category: "recycling", speed: 1.0, iconAsset: "recycler", moduleSlots: 4)
    ],
    "space-manufacturing": [
        MachineTier(id: "space-platform", name: "Space Platform", category: "space-manufacturing", speed: 1.0, iconAsset: "space_platform_foundation", moduleSlots: 0)
    ],
    "centrifuging": [
        MachineTier(id: "centrifuge", name: "Centrifuge", category: "centrifuging", speed: 1.0, iconAsset: "centrifuge", moduleSlots: 2)
    ],
    "rocket-building": [
        MachineTier(id: "rocket-silo", name: "Rocket Silo", category: "rocket-building", speed: 1.0, iconAsset: "rocket_part", moduleSlots: 4)
    ],
    "mining": [
        MachineTier(id: "burner-mining-drill", name: "Burner Mining Drill", category: "mining", speed: 0.25, iconAsset: "burner_mining_drill", moduleSlots: 0),
        MachineTier(id: "electric-mining-drill", name: "Electric Mining Drill", category: "mining", speed: 0.5, iconAsset: "electric_mining_drill", moduleSlots: 3),
        MachineTier(id: "big-mining-drill", name: "Big Mining Drill", category: "mining", speed: 2.0, iconAsset: "big_mining_drill", moduleSlots: 4)
    ],
    "oil-refinery": [
        MachineTier(id: "oil-refinery", name: "Oil Refinery", category: "oil-refinery", speed: 1.0, iconAsset: "oil_refinery", moduleSlots: 3)
    ]
]

// MARK: - Modules Data
let MODULES: [Module] = [
    // Speed Modules - Level 1
    Module(id: "speed-1-normal", name: "Speed Module", type: .speed, level: 1, quality: .normal,
           speedBonus: 0.2, productivityBonus: 0, efficiencyBonus: -0.5, iconAsset: "speed_module"),
    Module(id: "speed-1-uncommon", name: "Speed Module", type: .speed, level: 1, quality: .uncommon,
           speedBonus: 0.26, productivityBonus: 0, efficiencyBonus: -0.65, iconAsset: "speed_module"),
    Module(id: "speed-1-rare", name: "Speed Module", type: .speed, level: 1, quality: .rare,
           speedBonus: 0.32, productivityBonus: 0, efficiencyBonus: -0.8, iconAsset: "speed_module"),
    Module(id: "speed-1-epic", name: "Speed Module", type: .speed, level: 1, quality: .epic,
           speedBonus: 0.38, productivityBonus: 0, efficiencyBonus: -0.95, iconAsset: "speed_module"),
    Module(id: "speed-1-legendary", name: "Speed Module", type: .speed, level: 1, quality: .legendary,
           speedBonus: 0.5, productivityBonus: 0, efficiencyBonus: -1.25, iconAsset: "speed_module"),
    
    // Speed Modules - Level 2
    Module(id: "speed-2-normal", name: "Speed Module 2", type: .speed, level: 2, quality: .normal,
           speedBonus: 0.3, productivityBonus: 0, efficiencyBonus: -0.6, iconAsset: "speed_module_2"),
    Module(id: "speed-2-uncommon", name: "Speed Module 2", type: .speed, level: 2, quality: .uncommon,
           speedBonus: 0.39, productivityBonus: 0, efficiencyBonus: -0.78, iconAsset: "speed_module_2"),
    Module(id: "speed-2-rare", name: "Speed Module 2", type: .speed, level: 2, quality: .rare,
           speedBonus: 0.48, productivityBonus: 0, efficiencyBonus: -0.96, iconAsset: "speed_module_2"),
    Module(id: "speed-2-epic", name: "Speed Module 2", type: .speed, level: 2, quality: .epic,
           speedBonus: 0.57, productivityBonus: 0, efficiencyBonus: -1.14, iconAsset: "speed_module_2"),
    Module(id: "speed-2-legendary", name: "Speed Module 2", type: .speed, level: 2, quality: .legendary,
           speedBonus: 0.75, productivityBonus: 0, efficiencyBonus: -1.5, iconAsset: "speed_module_2"),
    
    // Speed Modules - Level 3
    Module(id: "speed-3-normal", name: "Speed Module 3", type: .speed, level: 3, quality: .normal,
           speedBonus: 0.5, productivityBonus: 0, efficiencyBonus: -0.7, iconAsset: "speed_module_3"),
    Module(id: "speed-3-uncommon", name: "Speed Module 3", type: .speed, level: 3, quality: .uncommon,
           speedBonus: 0.65, productivityBonus: 0, efficiencyBonus: -0.91, iconAsset: "speed_module_3"),
    Module(id: "speed-3-rare", name: "Speed Module 3", type: .speed, level: 3, quality: .rare,
           speedBonus: 0.8, productivityBonus: 0, efficiencyBonus: -1.12, iconAsset: "speed_module_3"),
    Module(id: "speed-3-epic", name: "Speed Module 3", type: .speed, level: 3, quality: .epic,
           speedBonus: 0.95, productivityBonus: 0, efficiencyBonus: -1.33, iconAsset: "speed_module_3"),
    Module(id: "speed-3-legendary", name: "Speed Module 3", type: .speed, level: 3, quality: .legendary,
           speedBonus: 1.25, productivityBonus: 0, efficiencyBonus: -1.75, iconAsset: "speed_module_3"),
    
    // Productivity Modules - Level 1
    Module(id: "productivity-1-normal", name: "Productivity Module", type: .productivity, level: 1, quality: .normal,
           speedBonus: -0.15, productivityBonus: 0.04, efficiencyBonus: -0.8, iconAsset: "productivity_module"),
    Module(id: "productivity-1-uncommon", name: "Productivity Module", type: .productivity, level: 1, quality: .uncommon,
           speedBonus: -0.195, productivityBonus: 0.052, efficiencyBonus: -1.04, iconAsset: "productivity_module"),
    Module(id: "productivity-1-rare", name: "Productivity Module", type: .productivity, level: 1, quality: .rare,
           speedBonus: -0.24, productivityBonus: 0.064, efficiencyBonus: -1.28, iconAsset: "productivity_module"),
    Module(id: "productivity-1-epic", name: "Productivity Module", type: .productivity, level: 1, quality: .epic,
           speedBonus: -0.285, productivityBonus: 0.076, efficiencyBonus: -1.52, iconAsset: "productivity_module"),
    Module(id: "productivity-1-legendary", name: "Productivity Module", type: .productivity, level: 1, quality: .legendary,
           speedBonus: -0.375, productivityBonus: 0.1, efficiencyBonus: -2.0, iconAsset: "productivity_module"),
    
    // Productivity Modules - Level 2
    Module(id: "productivity-2-normal", name: "Productivity Module 2", type: .productivity, level: 2, quality: .normal,
           speedBonus: -0.15, productivityBonus: 0.06, efficiencyBonus: -0.8, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-uncommon", name: "Productivity Module 2", type: .productivity, level: 2, quality: .uncommon,
           speedBonus: -0.195, productivityBonus: 0.078, efficiencyBonus: -1.04, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-rare", name: "Productivity Module 2", type: .productivity, level: 2, quality: .rare,
           speedBonus: -0.24, productivityBonus: 0.096, efficiencyBonus: -1.28, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-epic", name: "Productivity Module 2", type: .productivity, level: 2, quality: .epic,
           speedBonus: -0.285, productivityBonus: 0.114, efficiencyBonus: -1.52, iconAsset: "productivity_module_2"),
    Module(id: "productivity-2-legendary", name: "Productivity Module 2", type: .productivity, level: 2, quality: .legendary,
           speedBonus: -0.375, productivityBonus: 0.15, efficiencyBonus: -2.0, iconAsset: "productivity_module_2"),
    
    // Productivity Modules - Level 3
    Module(id: "productivity-3-normal", name: "Productivity Module 3", type: .productivity, level: 3, quality: .normal,
           speedBonus: -0.15, productivityBonus: 0.1, efficiencyBonus: -0.8, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-uncommon", name: "Productivity Module 3", type: .productivity, level: 3, quality: .uncommon,
           speedBonus: -0.195, productivityBonus: 0.13, efficiencyBonus: -1.04, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-rare", name: "Productivity Module 3", type: .productivity, level: 3, quality: .rare,
           speedBonus: -0.24, productivityBonus: 0.16, efficiencyBonus: -1.28, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-epic", name: "Productivity Module 3", type: .productivity, level: 3, quality: .epic,
           speedBonus: -0.285, productivityBonus: 0.19, efficiencyBonus: -1.52, iconAsset: "productivity_module_3"),
    Module(id: "productivity-3-legendary", name: "Productivity Module 3", type: .productivity, level: 3, quality: .legendary,
           speedBonus: -0.375, productivityBonus: 0.25, efficiencyBonus: -2.0, iconAsset: "productivity_module_3"),
    
    // Efficiency Modules - Level 1
    Module(id: "efficiency-1-normal", name: "Efficiency Module", type: .efficiency, level: 1, quality: .normal,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.3, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-uncommon", name: "Efficiency Module", type: .efficiency, level: 1, quality: .uncommon,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.39, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-rare", name: "Efficiency Module", type: .efficiency, level: 1, quality: .rare,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.48, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-epic", name: "Efficiency Module", type: .efficiency, level: 1, quality: .epic,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.57, iconAsset: "efficiency_module"),
    Module(id: "efficiency-1-legendary", name: "Efficiency Module", type: .efficiency, level: 1, quality: .legendary,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.75, iconAsset: "efficiency_module"),
    
    // Efficiency Modules - Level 2
    Module(id: "efficiency-2-normal", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .normal,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.4, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-uncommon", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .uncommon,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.52, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-rare", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .rare,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.64, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-epic", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .epic,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.76, iconAsset: "efficiency_module_2"),
    Module(id: "efficiency-2-legendary", name: "Efficiency Module 2", type: .efficiency, level: 2, quality: .legendary,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 1.0, iconAsset: "efficiency_module_2"),
    
    // Efficiency Modules - Level 3
    Module(id: "efficiency-3-normal", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .normal,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.5, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-uncommon", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .uncommon,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.65, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-rare", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .rare,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.8, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-epic", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .epic,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.95, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-legendary", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .legendary,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 1.25, iconAsset: "efficiency_module_3"),
    
    // Quality Modules - Level 1
    Module(id: "quality-1-normal", name: "Quality Module", type: .quality, level: 1, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module"),
    Module(id: "quality-1-uncommon", name: "Quality Module", type: .quality, level: 1, quality: .uncommon,
           speedBonus: -0.065, productivityBonus: 0, efficiencyBonus: -0.13, iconAsset: "quality_module"),
    Module(id: "quality-1-rare", name: "Quality Module", type: .quality, level: 1, quality: .rare,
           speedBonus: -0.08, productivityBonus: 0, efficiencyBonus: -0.16, iconAsset: "quality_module"),
    Module(id: "quality-1-epic", name: "Quality Module", type: .quality, level: 1, quality: .epic,
           speedBonus: -0.095, productivityBonus: 0, efficiencyBonus: -0.19, iconAsset: "quality_module"),
    Module(id: "quality-1-legendary", name: "Quality Module", type: .quality, level: 1, quality: .legendary,
           speedBonus: -0.125, productivityBonus: 0, efficiencyBonus: -0.25, iconAsset: "quality_module"),
    
    // Quality Modules - Level 2
    Module(id: "quality-2-normal", name: "Quality Module 2", type: .quality, level: 2, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module_2"),
    Module(id: "quality-2-uncommon", name: "Quality Module 2", type: .quality, level: 2, quality: .uncommon,
           speedBonus: -0.065, productivityBonus: 0, efficiencyBonus: -0.13, iconAsset: "quality_module_2"),
    Module(id: "quality-2-rare", name: "Quality Module 2", type: .quality, level: 2, quality: .rare,
           speedBonus: -0.08, productivityBonus: 0, efficiencyBonus: -0.16, iconAsset: "quality_module_2"),
    Module(id: "quality-2-epic", name: "Quality Module 2", type: .quality, level: 2, quality: .epic,
           speedBonus: -0.095, productivityBonus: 0, efficiencyBonus: -0.19, iconAsset: "quality_module_2"),
    Module(id: "quality-2-legendary", name: "Quality Module 2", type: .quality, level: 2, quality: .legendary,
           speedBonus: -0.125, productivityBonus: 0, efficiencyBonus: -0.25, iconAsset: "quality_module_2"),
    
    // Quality Modules - Level 3
    Module(id: "quality-3-normal", name: "Quality Module 3", type: .quality, level: 3, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module_3"),
    Module(id: "quality-3-uncommon", name: "Quality Module 3", type: .quality, level: 3, quality: .uncommon,
           speedBonus: -0.065, productivityBonus: 0, efficiencyBonus: -0.13, iconAsset: "quality_module_3"),
    Module(id: "quality-3-rare", name: "Quality Module 3", type: .quality, level: 3, quality: .rare,
           speedBonus: -0.08, productivityBonus: 0, efficiencyBonus: -0.16, iconAsset: "quality_module_3"),
    Module(id: "quality-3-epic", name: "Quality Module 3", type: .quality, level: 3, quality: .epic,
           speedBonus: -0.095, productivityBonus: 0, efficiencyBonus: -0.19, iconAsset: "quality_module_3"),
    Module(id: "quality-3-legendary", name: "Quality Module 3", type: .quality, level: 3, quality: .legendary,
           speedBonus: -0.125, productivityBonus: 0, efficiencyBonus: -0.25, iconAsset: "quality_module_3"),
]

// MARK: - Recipe Data (Basic subset for testing)

let BASE_RECIPES: [Recipe] = [
    // Smelting
    Recipe(id: "iron-plate", name: "Iron Plate", category: "smelting", time: 3.2, inputs: ["Iron Ore": 1], outputs: ["Iron Plate": 1]),
    Recipe(id: "copper-plate", name: "Copper Plate", category: "smelting", time: 3.2, inputs: ["Copper Ore": 1], outputs: ["Copper Plate": 1]),
    Recipe(id: "steel-plate", name: "Steel Plate", category: "smelting", time: 16, inputs: ["Iron Plate": 5], outputs: ["Steel Plate": 1]),
    Recipe(id: "stone-brick", name: "Stone Brick", category: "smelting", time: 3.2, inputs: ["Stone": 2], outputs: ["Stone Brick": 1]),

    // Basic Components
    Recipe(id: "copper-cable", name: "Copper Cable", category: "assembling", time: 0.5, inputs: ["Copper Plate": 1], outputs: ["Copper Cable": 2]),
    Recipe(id: "iron-stick", name: "Iron Stick", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1], outputs: ["Iron Stick": 2]),
    Recipe(id: "iron-gear-wheel", name: "Iron Gear Wheel", category: "assembling", time: 0.5, inputs: ["Iron Plate": 2], outputs: ["Iron Gear Wheel": 1]),
    Recipe(id: "pipe", name: "Pipe", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1], outputs: ["Pipe": 1]),
    Recipe(id: "engine-unit", name: "Engine Unit", category: "assembling", time: 10, inputs: ["Steel Plate": 1, "Iron Gear Wheel": 1, "Pipe": 2], outputs: ["Engine Unit": 1]),
    Recipe(id: "electric-engine-unit", name: "Electric Engine Unit", category: "assembling", time: 10, inputs: ["Engine Unit": 1, "Electronic Circuit": 2, "Lubricant": 15], outputs: ["Electric Engine Unit": 1]),

    // Circuits
    Recipe(id: "electronic-circuit", name: "Electronic Circuit", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1, "Copper Cable": 3], outputs: ["Electronic Circuit": 1]),
    Recipe(id: "advanced-circuit", name: "Advanced Circuit", category: "assembling", time: 6, inputs: ["Electronic Circuit": 2, "Plastic Bar": 2, "Copper Cable": 4], outputs: ["Advanced Circuit": 1]),
    Recipe(id: "processing-unit", name: "Processing Unit", category: "assembling", time: 10, inputs: ["Electronic Circuit": 20, "Advanced Circuit": 2, "Sulfuric Acid": 5], outputs: ["Processing Unit": 1]),

    // Science Packs (base game)
    Recipe(id: "automation-science-pack", name: "Automation Science Pack", category: "assembling", time: 5, inputs: ["Copper Plate": 1, "Iron Gear Wheel": 1], outputs: ["Automation Science Pack": 1]),
    Recipe(id: "logistic-science-pack", name: "Logistic Science Pack", category: "assembling", time: 6, inputs: ["Inserter": 1, "Transport Belt": 1], outputs: ["Logistic Science Pack": 1]),
    Recipe(id: "military-science-pack", name: "Military Science Pack", category: "assembling", time: 10, inputs: ["Piercing Rounds Magazine": 1, "Grenade": 1, "Wall": 2], outputs: ["Military Science Pack": 2]),
    Recipe(id: "chemical-science-pack", name: "Chemical Science Pack", category: "assembling", time: 24, inputs: ["Engine Unit": 2, "Advanced Circuit": 3, "Sulfur": 1], outputs: ["Chemical Science Pack": 2]),
    Recipe(id: "production-science-pack", name: "Production Science Pack", category: "assembling", time: 21, inputs: ["Electric Furnace": 1, "Productivity Module": 1, "Rail": 30], outputs: ["Production Science Pack": 3]),
    Recipe(id: "utility-science-pack", name: "Utility Science Pack", category: "assembling", time: 21, inputs: ["Low Density Structure": 3, "Processing Unit": 2, "Flying Robot Frame": 1], outputs: ["Utility Science Pack": 3]),

    // Space Age Science Packs (corrected)
    Recipe(id: "space-science-pack", name: "Space Science Pack", category: "space-manufacturing", time: 15, inputs: ["Carbon": 1, "Ice": 1, "Iron Plate": 2], outputs: ["Space Science Pack": 5]), // corrected inputs
    Recipe(id: "metallurgic-science-pack", name: "Metallurgic Science Pack", category: "assembling", time: 10, inputs: ["Molten Copper": 200, "Tungsten Carbide": 3, "Tungsten Plate": 2], outputs: ["Metallurgic Science Pack": 1]), // corrected contents & time
    Recipe(id: "electromagnetic-science-pack", name: "Electromagnetic Science Pack", category: "electromagnetic", time: 10, inputs: ["Supercapacitor": 1, "Holmium Solution": 25, "Electrolyte": 25, "Accumulator": 1], outputs: ["Electromagnetic Science Pack": 1]), // corrected contents
    Recipe(id: "agricultural-science-pack", name: "Agricultural Science Pack", category: "biochamber", time: 6, inputs: ["Bioflux": 1, "Nutrients": 4, "Biter Egg": 1], outputs: ["Agricultural Science Pack": 2]),
    Recipe(id: "cryogenic-science-pack", name: "Cryogenic Science Pack", category: "cryogenic", time: 30, inputs: ["Lithium Plate": 3, "Fusion Power Cell": 1, "Ice": 6], outputs: ["Cryogenic Science Pack": 1]),
    Recipe(id: "promethium-science-pack", name: "Promethium Science Pack", category: "assembling", time: 10, inputs: ["Processing Unit": 3, "Promethium Asteroid Chunk": 2, "Biter Egg": 1], outputs: ["Promethium Science Pack": 10]),

    // Transport
    Recipe(id: "transport-belt", name: "Transport Belt", category: "assembling", time: 0.5, inputs: ["Iron Plate": 1, "Iron Gear Wheel": 1], outputs: ["Transport Belt": 2]),
    Recipe(id: "inserter", name: "Inserter", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 1, "Iron Gear Wheel": 1, "Iron Plate": 1], outputs: ["Inserter": 1]),
    Recipe(id: "fast-inserter", name: "Fast Inserter", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 2, "Iron Plate": 2, "Inserter": 1], outputs: ["Fast Inserter": 1]),
    Recipe(id: "bulk-inserter", name: "Bulk Inserter", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 15, "Iron Gear Wheel": 15, "Fast Inserter": 1], outputs: ["Bulk Inserter": 1]),

    // Military
    Recipe(id: "piercing-rounds-magazine", name: "Piercing Rounds Magazine", category: "assembling", time: 3, inputs: ["Copper Plate": 5, "Steel Plate": 1, "Firearm Magazine": 1], outputs: ["Piercing Rounds Magazine": 1]),
    Recipe(id: "firearm-magazine", name: "Firearm Magazine", category: "assembling", time: 1, inputs: ["Iron Plate": 4], outputs: ["Firearm Magazine": 1]),
    Recipe(id: "grenade", name: "Grenade", category: "assembling", time: 8, inputs: ["Iron Plate": 5, "Coal": 10], outputs: ["Grenade": 1]),
    Recipe(id: "wall", name: "Wall", category: "assembling", time: 0.5, inputs: ["Stone Brick": 5], outputs: ["Wall": 1]),

    // Oil Processing
    Recipe(id: "basic-oil-processing", name: "Basic Oil Processing", category: "oil-refinery", time: 5, inputs: ["Crude Oil": 100], outputs: ["Petroleum Gas": 45]),
    Recipe(id: "advanced-oil-processing", name: "Advanced Oil Processing", category: "oil-refinery", time: 5, inputs: ["Crude Oil": 100, "Water": 50], outputs: ["Heavy Oil": 25, "Light Oil": 45, "Petroleum Gas": 55]),
    Recipe(id: "coal-liquefaction", name: "Coal Liquefaction", category: "oil-refinery", time: 5, inputs: ["Coal": 10, "Heavy Oil": 25, "Steam": 50], outputs: ["Heavy Oil": 90, "Light Oil": 20, "Petroleum Gas": 10]),
    Recipe(id: "heavy-oil-cracking", name: "Heavy Oil Cracking", category: "chemistry", time: 2, inputs: ["Heavy Oil": 40, "Water": 30], outputs: ["Light Oil": 30]),
    Recipe(id: "light-oil-cracking", name: "Light Oil Cracking", category: "chemistry", time: 2, inputs: ["Light Oil": 30, "Water": 30], outputs: ["Petroleum Gas": 20]),
    Recipe(id: "plastic-bar", name: "Plastic Bar", category: "chemistry", time: 1, inputs: ["Coal": 1, "Petroleum Gas": 20], outputs: ["Plastic Bar": 2]),
    Recipe(id: "sulfur", name: "Sulfur", category: "chemistry", time: 1, inputs: ["Water": 30, "Petroleum Gas": 30], outputs: ["Sulfur": 2]),
    Recipe(id: "sulfuric-acid", name: "Sulfuric Acid", category: "chemistry", time: 1, inputs: ["Iron Plate": 1, "Sulfur": 5, "Water": 100], outputs: ["Sulfuric Acid": 50]),
    Recipe(id: "lubricant", name: "Lubricant", category: "chemistry", time: 1, inputs: ["Heavy Oil": 10], outputs: ["Lubricant": 10]),
    Recipe(id: "battery", name: "Battery", category: "chemistry", time: 4, inputs: ["Iron Plate": 1, "Copper Plate": 1, "Sulfuric Acid": 20], outputs: ["Battery": 1]),

    // Alternative Fuel Processing (ALT recipes)
    Recipe(id: "solid-fuel-from-light-oil", name: "Solid Fuel (Light Oil)", category: "chemistry", time: 2, inputs: ["Light Oil": 10], outputs: ["Solid Fuel": 1]),
    Recipe(id: "solid-fuel-from-petroleum", name: "Solid Fuel (Petroleum)", category: "chemistry", time: 2, inputs: ["Petroleum Gas": 20], outputs: ["Solid Fuel": 1]),
    Recipe(id: "solid-fuel-from-heavy-oil", name: "Solid Fuel (Heavy Oil)", category: "chemistry", time: 2, inputs: ["Heavy Oil": 20], outputs: ["Solid Fuel": 1]),

    // Modules
    Recipe(id: "speed-module", name: "Speed Module", category: "assembling", time: 15, inputs: ["Advanced Circuit": 5, "Electronic Circuit": 5], outputs: ["Speed Module": 1]),
    Recipe(id: "speed-module-2", name: "Speed Module 2", category: "assembling", time: 30, inputs: ["Speed Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Speed Module 2": 1]),
    Recipe(id: "speed-module-3", name: "Speed Module 3", category: "assembling", time: 60, inputs: ["Speed Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Speed Module 3": 1]),
    Recipe(id: "productivity-module", name: "Productivity Module", category: "assembling", time: 15, inputs: ["Advanced Circuit": 5, "Electronic Circuit": 5], outputs: ["Productivity Module": 1]),
    Recipe(id: "productivity-module-2", name: "Productivity Module 2", category: "assembling", time: 30, inputs: ["Productivity Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Productivity Module 2": 1]),
    Recipe(id: "productivity-module-3", name: "Productivity Module 3", category: "assembling", time: 60, inputs: ["Productivity Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Productivity Module 3": 1]),
    Recipe(id: "efficiency-module", name: "Efficiency Module", category: "assembling", time: 15, inputs: ["Advanced Circuit": 5, "Electronic Circuit": 5], outputs: ["Efficiency Module": 1]),
    Recipe(id: "efficiency-module-2", name: "Efficiency Module 2", category: "assembling", time: 30, inputs: ["Efficiency Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Efficiency Module 2": 1]),
    Recipe(id: "efficiency-module-3", name: "Efficiency Module 3", category: "assembling", time: 60, inputs: ["Efficiency Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Efficiency Module 3": 1]),
    Recipe(id: "quality-module", name: "Quality Module", category: "assembling", time: 15, inputs: ["Electronic Circuit": 5, "Advanced Circuit": 5], outputs: ["Quality Module": 1]),
    Recipe(id: "quality-module-2", name: "Quality Module 2", category: "assembling", time: 30, inputs: ["Quality Module": 4, "Advanced Circuit": 5, "Processing Unit": 5], outputs: ["Quality Module 2": 1]),
    Recipe(id: "quality-module-3", name: "Quality Module 3", category: "assembling", time: 60, inputs: ["Quality Module 2": 4, "Advanced Circuit": 5, "Processing Unit": 5, "Superconductor": 1], outputs: ["Quality Module 3": 1]),

    // Rocket Components
    Recipe(id: "low-density-structure", name: "Low Density Structure", category: "assembling", time: 30, inputs: ["Steel Plate": 2, "Copper Plate": 20, "Plastic Bar": 5], outputs: ["Low Density Structure": 1]),
    Recipe(id: "rocket-fuel", name: "Rocket Fuel", category: "assembling", time: 30, inputs: ["Solid Fuel": 10, "Light Oil": 10], outputs: ["Rocket Fuel": 1]),
    Recipe(id: "rocket-control-unit", name: "Rocket Control Unit", category: "assembling", time: 30, inputs: ["Processing Unit": 1, "Speed Module": 1], outputs: ["Rocket Control Unit": 1]),
    Recipe(id: "rocket-part", name: "Rocket Part", category: "rocket-building", time: 3, inputs: ["Low Density Structure": 10, "Rocket Fuel": 10, "Rocket Control Unit": 10], outputs: ["Rocket Part": 1]),

    // Production Buildings
    Recipe(id: "electric-furnace", name: "Electric Furnace", category: "assembling", time: 5, inputs: ["Steel Plate": 10, "Advanced Circuit": 5, "Stone Brick": 10], outputs: ["Electric Furnace": 1]),
    Recipe(id: "oil-refinery", name: "Oil Refinery", category: "assembling", time: 8, inputs: ["Steel Plate": 15, "Iron Gear Wheel": 10, "Stone Brick": 10, "Electronic Circuit": 10, "Pipe": 10], outputs: ["Oil Refinery": 1]),
    Recipe(id: "chemical-plant", name: "Chemical Plant", category: "assembling", time: 5, inputs: ["Steel Plate": 5, "Iron Gear Wheel": 5, "Electronic Circuit": 5, "Pipe": 5], outputs: ["Chemical Plant": 1]),
    Recipe(id: "centrifuge", name: "Centrifuge", category: "assembling", time: 4, inputs: ["Concrete": 100, "Steel Plate": 50, "Advanced Circuit": 100, "Iron Gear Wheel": 100], outputs: ["Centrifuge": 1]),
    Recipe(id: "lab", name: "Lab", category: "assembling", time: 2, inputs: ["Electronic Circuit": 10, "Iron Gear Wheel": 10, "Transport Belt": 4], outputs: ["Lab": 1]),
    Recipe(id: "rail", name: "Rail", category: "assembling", time: 0.5, inputs: ["Stone": 1, "Iron Stick": 1, "Steel Plate": 1], outputs: ["Rail": 2]),
    Recipe(id: "flying-robot-frame", name: "Flying Robot Frame", category: "assembling", time: 20, inputs: ["Electric Engine Unit": 1, "Battery": 2, "Steel Plate": 1, "Electronic Circuit": 3], outputs: ["Flying Robot Frame": 1]),
    Recipe(id: "accumulator", name: "Accumulator", category: "assembling", time: 10, inputs: ["Iron Plate": 2, "Battery": 5], outputs: ["Accumulator": 1]),
    Recipe(id: "solar-panel", name: "Solar Panel", category: "assembling", time: 10, inputs: ["Steel Plate": 5, "Electronic Circuit": 15, "Copper Plate": 5], outputs: ["Solar Panel": 1]),

    // Concrete
    Recipe(id: "concrete", name: "Concrete", category: "assembling", time: 10, inputs: ["Stone Brick": 5, "Iron Ore": 1, "Water": 100], outputs: ["Concrete": 10]),
    Recipe(id: "hazard-concrete", name: "Hazard Concrete", category: "assembling", time: 0.25, inputs: ["Concrete": 10], outputs: ["Hazard Concrete": 10]),
    Recipe(id: "refined-concrete", name: "Refined Concrete", category: "assembling", time: 15, inputs: ["Concrete": 20, "Iron Stick": 8, "Steel Plate": 1, "Water": 100], outputs: ["Refined Concrete": 10]),

    // Nuclear
    Recipe(id: "uranium-processing", name: "Uranium Processing", category: "centrifuging", time: 12, inputs: ["Uranium Ore": 10], outputs: ["Uranium-235": 0.007, "Uranium-238": 0.993]),
    Recipe(id: "uranium-fuel-cell", name: "Uranium Fuel Cell", category: "assembling", time: 10, inputs: ["Iron Plate": 10, "Uranium-235": 1, "Uranium-238": 19], outputs: ["Uranium Fuel Cell": 10]),
    Recipe(id: "nuclear-fuel-reprocessing", name: "Nuclear Fuel Reprocessing", category: "centrifuging", time: 60, inputs: ["Used Up Uranium Fuel Cell": 5], outputs: ["Uranium-238": 3]),
    Recipe(id: "kovarex-enrichment-process", name: "Kovarex Enrichment Process", category: "centrifuging", time: 60, inputs: ["Uranium-235": 40, "Uranium-238": 5], outputs: ["Uranium-235": 41, "Uranium-238": 2]),

    // Alternative Molten Metal Recipes (Foundry)
    Recipe(id: "molten-iron", name: "Molten Iron", category: "casting", time: 32, inputs: ["Iron Ore": 50, "Calcite": 1], outputs: ["Molten Iron": 500]), // corrected to 32s
    Recipe(id: "molten-copper", name: "Molten Copper", category: "casting", time: 32, inputs: ["Copper Ore": 50, "Calcite": 1], outputs: ["Molten Copper": 500]), // corrected to 32s
    Recipe(id: "molten-iron-from-lava", name: "Molten Iron from Lava", category: "casting", time: 16, inputs: ["Lava": 500, "Calcite": 1], outputs: ["Molten Iron": 250, "Stone": 10]), // corrected to 16s, Calcite 1
    Recipe(id: "molten-copper-from-lava", name: "Molten Copper from Lava", category: "casting", time: 16, inputs: ["Lava": 500, "Calcite": 1], outputs: ["Molten Copper": 250, "Stone": 15]), // corrected to 16s, Calcite 1

    Recipe(id: "iron-plate-from-molten", name: "Iron Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Iron": 20], outputs: ["Iron Plate": 2]), // corrected to 3.2s, 20 -> 2
    Recipe(id: "copper-plate-from-molten", name: "Copper Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Copper": 20], outputs: ["Copper Plate": 2]), // corrected to 3.2s, 20 -> 2
    Recipe(id: "steel-plate-from-molten", name: "Steel Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Iron": 30], outputs: ["Steel Plate": 1]),

    // Foundry cast derivatives
    Recipe(id: "casting-copper-cable", name: "Casting Copper Cable", category: "casting", time: 1, inputs: ["Molten Copper": 5], outputs: ["Copper Cable": 2]), // corrected to 1s
    Recipe(id: "casting-iron-gear-wheel", name: "Casting Iron Gear Wheel", category: "casting", time: 1, inputs: ["Molten Iron": 10], outputs: ["Iron Gear Wheel": 1]), // corrected to 1s
    Recipe(id: "casting-iron-stick", name: "Casting Iron Stick", category: "casting", time: 1, inputs: ["Molten Iron": 20], outputs: ["Iron Stick": 4]), // corrected to 1s, 20 -> 4
    Recipe(id: "casting-low-density-structure", name: "Casting Low Density Structure", category: "casting", time: 15, inputs: ["Molten Copper": 250, "Molten Iron": 80, "Plastic Bar": 5], outputs: ["Low Density Structure": 1]), // corrected inputs & time
    Recipe(id: "casting-pipe", name: "Casting Pipe", category: "casting", time: 1, inputs: ["Molten Iron": 10], outputs: ["Pipe": 1]), // corrected to 1s
    Recipe(id: "casting-pipe-to-ground", name: "Casting Pipe to Ground", category: "casting", time: 1, inputs: ["Pipe": 10, "Molten Iron": 50], outputs: ["Pipe to Ground": 2]), // corrected to 1s; requires 10 Pipes

    // Vulcanus-specific
    Recipe(id: "tungsten-plate", name: "Tungsten Plate", category: "smelting", time: 10, inputs: ["Tungsten Ore": 4, "Sulfuric Acid": 10], outputs: ["Tungsten Plate": 1]),
    Recipe(id: "tungsten-carbide", name: "Tungsten Carbide", category: "assembling", time: 2, inputs: ["Tungsten Plate": 2, "Carbon": 1], outputs: ["Tungsten Carbide": 1]),
    Recipe(id: "carbon", name: "Carbon", category: "chemistry", time: 1, inputs: ["Coal": 2, "Sulfuric Acid": 20], outputs: ["Carbon": 1]),
    Recipe(id: "carbon-fiber", name: "Carbon Fiber", category: "assembling", time: 4, inputs: ["Carbon": 4, "Plastic Bar": 2], outputs: ["Carbon Fiber": 1]),

    // Fulgora-specific
    Recipe(id: "holmium-solution", name: "Holmium Solution", category: "chemistry", time: 1, inputs: ["Holmium Ore": 2, "Stone": 1, "Water": 10], outputs: ["Holmium Solution": 10]),
    Recipe(id: "holmium-plate", name: "Holmium Plate", category: "assembling", time: 1, inputs: ["Holmium Solution": 20], outputs: ["Holmium Plate": 1]),
    Recipe(id: "superconductor", name: "Superconductor", category: "electromagnetic", time: 5, inputs: ["Copper Plate": 2, "Plastic Bar": 1, "Holmium Plate": 1, "Light Oil": 5], outputs: ["Superconductor": 1]),
    Recipe(id: "supercapacitor", name: "Supercapacitor", category: "electromagnetic", time: 10, inputs: ["Battery": 2, "Electronic Circuit": 4, "Superconductor": 2, "Holmium Solution": 10], outputs: ["Supercapacitor": 1]),
    Recipe(id: "lightning-rod", name: "Lightning Rod", category: "assembling", time: 5, inputs: ["Copper Plate": 3, "Steel Plate": 8], outputs: ["Lightning Rod": 1]),
    Recipe(id: "lightning-collector", name: "Lightning Collector", category: "electromagnetic", time: 10, inputs: ["Lightning Rod": 2, "Accumulator": 1, "Superconductor": 4], outputs: ["Lightning Collector": 1]),
    Recipe(id: "scrap-recycling", name: "Scrap Recycling", category: "recycling", time: 0.2, inputs: ["Scrap": 1], outputs: ["Iron Gear Wheel": 0.2, "Concrete": 0.05, "Copper Cable": 0.03, "Steel Plate": 0.02, "Solid Fuel": 0.07, "Stone": 0.04, "Battery": 0.01, "Processing Unit": 0.002, "Low Density Structure": 0.001, "Ice": 0.05, "Holmium Ore": 0.01]),

    // Electromagnetic Plant exclusives
    Recipe(id: "electromagnetic-plant", name: "Electromagnetic Plant", category: "electromagnetic", time: 10, inputs: ["Steel Plate": 20, "Advanced Circuit": 10, "Holmium Plate": 20, "Processing Unit": 10], outputs: ["Electromagnetic Plant": 1]),
    Recipe(id: "tesla-turret", name: "Tesla Turret", category: "electromagnetic", time: 10, inputs: ["Steel Plate": 20, "Supercapacitor": 1, "Processing Unit": 10], outputs: ["Tesla Turret": 1]),
    Recipe(id: "tesla-ammo", name: "Tesla Ammo", category: "electromagnetic", time: 10, inputs: ["Supercapacitor": 1, "Steel Plate": 1], outputs: ["Tesla Ammo": 1]),

    // Space Platform
    Recipe(id: "space-platform-foundation", name: "Space Platform Foundation", category: "assembling", time: 10, inputs: ["Steel Plate": 20, "Low Density Structure": 10], outputs: ["Space Platform Foundation": 1]),
    Recipe(id: "asteroid-collector", name: "Asteroid Collector", category: "space-manufacturing", time: 10, inputs: ["Low Density Structure": 20, "Electric Engine Unit": 5, "Processing Unit": 5], outputs: ["Asteroid Collector": 1]),
    Recipe(id: "crusher", name: "Crusher", category: "space-manufacturing", time: 10, inputs: ["Steel Plate": 10, "Iron Gear Wheel": 5, "Electric Engine Unit": 2], outputs: ["Crusher": 1]),
    Recipe(id: "thruster", name: "Thruster", category: "space-manufacturing", time: 10, inputs: ["Steel Plate": 10, "Iron Gear Wheel": 10, "Pipe": 5], outputs: ["Thruster": 1]),
    Recipe(id: "cargo-bay", name: "Cargo Bay", category: "space-manufacturing", time: 10, inputs: ["Steel Plate": 20, "Low Density Structure": 5, "Processing Unit": 1], outputs: ["Cargo Bay": 1]),

    // Asteroid Crushing
    Recipe(id: "metallic-asteroid-crushing", name: "Metallic Asteroid Crushing", category: "crushing", time: 2, inputs: ["Metallic Asteroid": 1], outputs: ["Iron Ore": 20, "Copper Ore": 10, "Stone": 8]),
    Recipe(id: "carbonic-asteroid-crushing", name: "Carbonic Asteroid Crushing", category: "crushing", time: 2, inputs: ["Carbonic Asteroid": 1], outputs: ["Carbon": 10, "Sulfur": 4, "Water": 20]),
    Recipe(id: "oxide-asteroid-crushing", name: "Oxide Asteroid Crushing", category: "crushing", time: 2, inputs: ["Oxide Asteroid": 1], outputs: ["Ice": 10, "Calcite": 5, "Iron Ore": 5]),
    Recipe(id: "promethium-asteroid-crushing", name: "Promethium Asteroid Crushing", category: "crushing", time: 2, inputs: ["Promethium Asteroid": 1], outputs: ["Promethium Asteroid Chunk": 10]),

    // Advanced Asteroid Crushing
    Recipe(id: "advanced-metallic-asteroid-crushing", name: "Advanced Metallic Asteroid Crushing", category: "crushing", time: 5, inputs: ["Metallic Asteroid": 1], outputs: ["Iron Ore": 25, "Copper Ore": 12, "Stone": 10, "Holmium Ore": 1, "Tungsten Ore": 1]),
    Recipe(id: "advanced-carbonic-asteroid-crushing", name: "Advanced Carbonic Asteroid Crushing", category: "crushing", time: 5, inputs: ["Carbonic Asteroid": 1], outputs: ["Carbon": 12, "Sulfur": 5, "Water": 25]),
    Recipe(id: "advanced-oxide-asteroid-crushing", name: "Advanced Oxide Asteroid Crushing", category: "crushing", time: 5, inputs: ["Oxide Asteroid": 1], outputs: ["Ice": 12, "Calcite": 6, "Iron Ore": 6]),

    // Space Platform Processing
    Recipe(id: "asteroid-chunk-processing", name: "Asteroid Chunk Processing", category: "assembling", time: 1, inputs: ["Asteroid Chunk": 1], outputs: ["Iron Ore": 1, "Copper Ore": 1, "Stone": 1]),
    Recipe(id: "thruster-fuel", name: "Thruster Fuel (basic)", category: "chemistry", time: 10, inputs: ["Carbon": 2, "Water": 10], outputs: ["Thruster Fuel": 1]),
    Recipe(id: "thruster-oxidizer", name: "Thruster Oxidizer (basic)", category: "chemistry", time: 10, inputs: ["Water": 10, "Iron Ore": 2], outputs: ["Thruster Oxidizer": 1]),

    // Gleba / Biochamber
    Recipe(id: "nutrients", name: "Nutrients", category: "biochamber", time: 2, inputs: ["Spoilage": 10, "Water": 10], outputs: ["Nutrients": 20]),
    Recipe(id: "bioflux", name: "Bioflux", category: "biochamber", time: 4, inputs: ["Yumako Mash": 12, "Jellynut Paste": 12], outputs: ["Bioflux": 2]),
    Recipe(id: "jelly", name: "Jelly", category: "biochamber", time: 20, inputs: ["Jellynut Paste": 40, "Water": 20], outputs: ["Jelly": 20]),
    Recipe(id: "biter-egg", name: "Biter Egg", category: "biochamber", time: 10, inputs: ["Biter Egg Fragment": 10, "Nutrients": 20], outputs: ["Biter Egg": 1]),
    Recipe(id: "pentapod-egg", name: "Pentapod Egg", category: "biochamber", time: 15, inputs: ["Pentapod Egg Fragment": 10, "Nutrients": 30], outputs: ["Pentapod Egg": 1]),
    Recipe(id: "yumako-processing", name: "Yumako Processing", category: "biochamber", time: 1, inputs: ["Yumako": 2], outputs: ["Yumako Mash": 3]),
    Recipe(id: "jellynut-processing", name: "Jellynut Processing", category: "biochamber", time: 1, inputs: ["Jellynut": 2], outputs: ["Jellynut Paste": 3]),
    Recipe(id: "tree-seed-from-wood", name: "Tree Seed from Wood", category: "biochamber", time: 2, inputs: ["Wood": 10], outputs: ["Tree Seed": 1]),
    Recipe(id: "yumako-cultivation", name: "Yumako Cultivation", category: "biochamber", time: 60, inputs: ["Yumako Seed": 2, "Nutrients": 50, "Water": 50], outputs: ["Yumako": 30]),
    Recipe(id: "jellynut-cultivation", name: "Jellynut Cultivation", category: "biochamber", time: 60, inputs: ["Jellynut Seed": 2, "Nutrients": 50, "Water": 50], outputs: ["Jellynut": 20]),
    Recipe(id: "fish-breeding", name: "Fish Breeding", category: "biochamber", time: 180, inputs: ["Raw Fish": 2, "Nutrients": 100, "Water": 100], outputs: ["Raw Fish": 4]),

    // Biochamber Alternatives
    Recipe(id: "bioplastic", name: "Bioplastic", category: "biochamber", time: 5, inputs: ["Yumako Mash": 10, "Jellynut Paste": 10], outputs: ["Plastic Bar": 2]),
    Recipe(id: "biosulfur", name: "Biosulfur", category: "biochamber", time: 2, inputs: ["Yumako Mash": 5, "Bacteria": 5], outputs: ["Sulfur": 2]),
    Recipe(id: "biolubricant", name: "Biolubricant", category: "biochamber", time: 2, inputs: ["Jellynut Paste": 10], outputs: ["Lubricant": 10]),
    Recipe(id: "rocket-fuel-from-jelly", name: "Rocket Fuel from Jelly", category: "biochamber", time: 30, inputs: ["Jelly": 30], outputs: ["Rocket Fuel": 1]),
    Recipe(id: "iron-bacteria-cultivation", name: "Iron Bacteria Cultivation", category: "biochamber", time: 4, inputs: ["Iron Bacteria": 1, "Nutrients": 10], outputs: ["Iron Ore": 1]),
    Recipe(id: "copper-bacteria-cultivation", name: "Copper Bacteria Cultivation", category: "biochamber", time: 4, inputs: ["Copper Bacteria": 1, "Nutrients": 10], outputs: ["Copper Ore": 1]),

    // Aquilo / Cryogenic
    Recipe(id: "ice-melting", name: "Ice Melting", category: "chemistry", time: 1, inputs: ["Ice": 1], outputs: ["Water": 10]),
    Recipe(id: "ammonia", name: "Ammonia", category: "chemistry", time: 2, inputs: ["Nitrogen": 50, "Hydrogen": 100], outputs: ["Ammonia": 20]),
    Recipe(id: "solid-fuel-from-ammonia", name: "Solid Fuel from Ammonia", category: "cryogenic", time: 2, inputs: ["Ammonia": 20], outputs: ["Solid Fuel": 1]),
    Recipe(id: "ammonia-rocket-fuel", name: "Ammonia Rocket Fuel", category: "cryogenic", time: 10, inputs: ["Ammonia": 40, "Iron Plate": 5, "Oxidizer": 20], outputs: ["Solid Rocket Fuel": 1]),
    Recipe(id: "lithium-plate", name: "Lithium Plate", category: "chemistry", time: 2, inputs: ["Lithium Ore": 1, "Sulfuric Acid": 10], outputs: ["Lithium Plate": 1]),
    Recipe(id: "fluorine", name: "Fluorine", category: "chemistry", time: 2, inputs: ["Fluorite": 2, "Sulfuric Acid": 30, "Steam": 50], outputs: ["Fluorine": 10]),
    Recipe(id: "fluoroketone-cold", name: "Fluoroketone (Cold)", category: "cryogenic", time: 5, inputs: ["Fluorine": 10, "Ammonia": 10, "Carbon": 1], outputs: ["Fluoroketone (Cold)": 20]),
    Recipe(id: "fluoroketone-hot", name: "Fluoroketone (Hot)", category: "chemistry", time: 5, inputs: ["Fluoroketone (Cold)": 20], outputs: ["Fluoroketone (Hot)": 20]),
    Recipe(id: "fusion-power-cell", name: "Fusion Power Cell", category: "assembling", time: 10, inputs: ["Lithium Plate": 1, "Deuterium": 50, "Tritium": 50], outputs: ["Fusion Power Cell": 1]),
    Recipe(id: "fusion-reactor", name: "Fusion Reactor", category: "assembling", time: 60, inputs: ["Processing Unit": 200, "Tungsten Plate": 50, "Superconductor": 50, "Lithium Plate": 50], outputs: ["Fusion Reactor": 1]),
    Recipe(id: "cryogenic-plant", name: "Cryogenic Plant", category: "cryogenic", time: 30, inputs: ["Steel Plate": 40, "Processing Unit": 20, "Concrete": 40, "Refined Concrete": 20], outputs: ["Cryogenic Plant": 1]),
    Recipe(id: "railgun-turret", name: "Railgun Turret", category: "assembling", time: 20, inputs: ["Steel Plate": 40, "Superconductor": 10, "Processing Unit": 20, "Tungsten Plate": 10], outputs: ["Railgun Turret": 1]),
    Recipe(id: "railgun-ammo", name: "Railgun Ammo", category: "assembling", time: 10, inputs: ["Steel Plate": 5, "Superconductor": 1, "Explosives": 1], outputs: ["Railgun Ammo": 10]),
    Recipe(id: "rocket-turret", name: "Rocket Turret", category: "assembling", time: 10, inputs: ["Steel Plate": 40, "Electronic Circuit": 30, "Iron Gear Wheel": 30], outputs: ["Rocket Turret": 1]),

    // Aquilo Advanced
    Recipe(id: "quantum-processor", name: "Quantum Processor", category: "electromagnetic", time: 30, inputs: ["Processing Unit": 2, "Superconductor": 2, "Carbon Fiber": 1, "Tungsten Carbide": 1], outputs: ["Quantum Processor": 1]),
    Recipe(id: "mech-armor", name: "Mech Armor", category: "assembling", time: 60, inputs: ["Processing Unit": 200, "Steel Plate": 400, "Low Density Structure": 100, "Supercapacitor": 20, "Holmium Plate": 100], outputs: ["Mech Armor": 1]),
    Recipe(id: "personal-roboport-mk2", name: "Personal Roboport MK2", category: "assembling", time: 20, inputs: ["Personal Roboport": 5, "Processing Unit": 100, "Supercapacitor": 20], outputs: ["Personal Roboport MK2": 1]),
    Recipe(id: "personal-roboport", name: "Personal Roboport", category: "assembling", time: 10, inputs: ["Advanced Circuit": 10, "Iron Gear Wheel": 40, "Steel Plate": 20, "Battery": 45], outputs: ["Personal Roboport": 1]),

    // Utilities
    Recipe(id: "explosives", name: "Explosives", category: "chemistry", time: 4, inputs: ["Sulfur": 1, "Coal": 1, "Water": 10], outputs: ["Explosives": 2]),
    Recipe(id: "cliff-explosives", name: "Cliff Explosives", category: "assembling", time: 8, inputs: ["Explosives": 10, "Empty Barrel": 1, "Grenade": 1], outputs: ["Cliff Explosives": 1]),
    Recipe(id: "barrel", name: "Barrel", category: "assembling", time: 1, inputs: ["Steel Plate": 1], outputs: ["Empty Barrel": 1]),
    Recipe(id: "repair-pack", name: "Repair Pack", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 2, "Iron Gear Wheel": 2], outputs: ["Repair Pack": 1]),
    Recipe(id: "automation-core", name: "Automation Core", category: "assembling", time: 2, inputs: ["Iron Gear Wheel": 4, "Electronic Circuit": 2], outputs: ["Automation Core": 1]),
    Recipe(id: "logistic-robot", name: "Logistic Robot", category: "assembling", time: 0.5, inputs: ["Flying Robot Frame": 1, "Advanced Circuit": 2], outputs: ["Logistic Robot": 1]),
    Recipe(id: "construction-robot", name: "Construction Robot", category: "assembling", time: 0.5, inputs: ["Flying Robot Frame": 1, "Electronic Circuit": 2], outputs: ["Construction Robot": 1]),
    Recipe(id: "roboport", name: "Roboport", category: "assembling", time: 5, inputs: ["Steel Plate": 45, "Iron Gear Wheel": 45, "Advanced Circuit": 45], outputs: ["Roboport": 1]),
    Recipe(id: "beacon", name: "Beacon", category: "assembling", time: 15, inputs: ["Electronic Circuit": 20, "Advanced Circuit": 20, "Steel Plate": 10, "Copper Cable": 10], outputs: ["Beacon": 1]),
    Recipe(id: "heat-pipe", name: "Heat Pipe", category: "assembling", time: 1, inputs: ["Steel Plate": 10, "Copper Plate": 20], outputs: ["Heat Pipe": 1]),
    Recipe(id: "heat-exchanger", name: "Heat Exchanger", category: "assembling", time: 3, inputs: ["Steel Plate": 10, "Copper Plate": 100, "Pipe": 10], outputs: ["Heat Exchanger": 1]),
    Recipe(id: "steam-turbine", name: "Steam Turbine", category: "assembling", time: 3, inputs: ["Iron Gear Wheel": 50, "Copper Plate": 50, "Pipe": 20], outputs: ["Steam Turbine": 1]),
    Recipe(id: "nuclear-reactor", name: "Nuclear Reactor", category: "assembling", time: 8, inputs: ["Concrete": 500, "Steel Plate": 500, "Advanced Circuit": 500, "Copper Plate": 500], outputs: ["Nuclear Reactor": 1]),
    Recipe(id: "satellite", name: "Satellite", category: "assembling", time: 5, inputs: ["Low Density Structure": 100, "Solar Panel": 100, "Accumulator": 100, "Radar": 5, "Processing Unit": 100, "Rocket Fuel": 50], outputs: ["Satellite": 1]),
    Recipe(id: "radar", name: "Radar", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 5, "Iron Gear Wheel": 5, "Iron Plate": 10], outputs: ["Radar": 1])

]

// Generate recycling recipes dynamically
func generateRecyclingRecipes() -> [Recipe] {
    var recyclingRecipes: [Recipe] = []
    
    let nonRecyclables: Set<String> = [
        "Water", "Steam", "Crude Oil", "Heavy Oil", "Light Oil", "Petroleum Gas",
        "Sulfuric Acid", "Lubricant", "Molten Iron", "Molten Copper",
        "Spoilage", "Scrap", "Used Up Uranium Fuel Cell"
    ]
    
    for recipe in BASE_RECIPES {
        guard !recipe.category.contains("recycling") else { continue }
        
        for (item, _) in recipe.outputs {
            if nonRecyclables.contains(item) { continue }
            
            var recycleOutputs: [String: Double] = [:]
            
            for (inputItem, inputAmount) in recipe.inputs {
                if !nonRecyclables.contains(inputItem) {
                    recycleOutputs[inputItem] = inputAmount * 0.25
                }
            }
            
            if !recycleOutputs.isEmpty {
                let recycleId = "recycle-" + item.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                
                recyclingRecipes.append(Recipe(
                    id: recycleId,
                    name: "Recycle \(item)",
                    category: "recycling",
                    time: 0.3,
                    inputs: [item: 1],
                    outputs: recycleOutputs
                ))
            }
        }
    }
    
    return recyclingRecipes
}

let RECIPES: [Recipe] = BASE_RECIPES + generateRecyclingRecipes()

// MARK: - Item Mappings
let ITEM_TO_PRODUCERS: [String: [Recipe]] = {
    var mapping: [String: [Recipe]] = [:]
    for recipe in RECIPES {
        for (outputItem, _) in recipe.outputs {
            mapping[outputItem, default: []].append(recipe)
        }
    }
    return mapping
}()

let ITEM_TO_CONSUMERS: [String: [Recipe]] = {
    var mapping: [String: [Recipe]] = [:]
    for recipe in RECIPES {
        for (inputItem, _) in recipe.inputs {
            mapping[inputItem, default: []].append(recipe)
        }
    }
    return mapping
}()

// MARK: - Icon Assets
let ICON_ASSETS: [String: String] = [
    "Iron Plate": "iron_plate",
    "Copper Plate": "copper_plate",
    "Steel Plate": "steel_plate",
    "Stone Brick": "stone_brick",
    "Coal": "coal",
    "Iron Ore": "iron_ore",
    "Copper Ore": "copper_ore",
    "Stone": "stone",
    "Wood": "wood",
    "Uranium Ore": "uranium_ore",
    "Uranium-235": "uranium_235",
    "Uranium-238": "uranium_238",
    "Water": "water",
    "Steam": "steam",
    "Crude Oil": "crude_oil",
    "Heavy Oil": "heavy_oil",
    "Light Oil": "light_oil",
    "Petroleum Gas": "petroleum_gas",
    
    // Basic Components
    "Copper Cable": "copper_cable",
    "Iron Stick": "iron_stick",
    "Iron Gear Wheel": "iron_gear_wheel",
    "Pipe": "pipe",
    "Pipe to Ground": "pipe_to_ground",
    "Engine Unit": "engine_unit",
    "Electric Engine Unit": "electric_engine_unit",
    
    // Circuits
    "Electronic Circuit": "electronic_circuit",
    "Advanced Circuit": "advanced_circuit",
    "Processing Unit": "processing_unit",
    
    // Transport & Logistics
    "Transport Belt": "transport_belt",
    "Fast Transport Belt": "fast_transport_belt",
    "Express Transport Belt": "express_transport_belt",
    "Turbo Transport Belt": "turbo_transport_belt",
    "Underground Belt": "underground_belt",
    "Fast Underground Belt": "fast_underground_belt",
    "Express Underground Belt": "express_underground_belt",
    "Turbo Underground Belt": "turbo_underground_belt",
    "Splitter": "splitter",
    "Fast Splitter": "fast_splitter",
    "Express Splitter": "express_splitter",
    "Turbo Splitter": "turbo_splitter",
    
    // Inserters
    "Burner Inserter": "burner_inserter",
    "Inserter": "inserter",
    "Long-handed Inserter": "long_handed_inserter",
    "Fast Inserter": "fast_inserter",
    "Bulk Inserter": "bulk_inserter",
    "Stack Inserter": "stack_inserter",
    "Filter Inserter": "filter_inserter",
    "Stack Filter Inserter": "stack_filter_inserter",
    
    // Power
    "Solar Panel": "solar_panel",
    "Accumulator": "accumulator",
    "Steam Engine": "steam_engine",
    "Steam Turbine": "steam_turbine",
    "Boiler": "boiler",
    "Nuclear Reactor": "nuclear_reactor",
    "Heat Pipe": "heat_pipe",
    "Heat Exchanger": "heat_exchanger",
    "Offshore Pump": "offshore_pump",
    "Pump": "pump",
    "Pumpjack": "pumpjack",
    
    // Storage
    "Wooden Chest": "wooden_chest",
    "Iron Chest": "iron_chest",
    "Steel Chest": "steel_chest",
    "Storage Tank": "storage_tank",
    "Passive Provider Chest": "passive_provider_chest",
    "Active Provider Chest": "active_provider_chest",
    "Storage Chest": "storage_chest",
    "Buffer Chest": "buffer_chest",
    "Requester Chest": "requester_chest",
    
    // Logistics Network
    "Logistic Robot": "logistic_robot",
    "Construction Robot": "construction_robot",
    "Roboport": "roboport",
    "Flying Robot Frame": "flying_robot_frame",
    "Personal Roboport": "personal_roboport",
    "Personal Roboport MK2": "personal_roboport_mk2",
    
    // Railway
    "Rail": "rail",
    "Train Stop": "train_stop",
    "Rail Signal": "rail_signal",
    "Rail Chain Signal": "rail_chain_signal",
    "Locomotive": "locomotive",
    "Cargo Wagon": "cargo_wagon",
    "Fluid Wagon": "fluid_wagon",
    "Artillery Wagon": "artillery_wagon",
    
    // Production Buildings
    "Assembling Machine 1": "assembling_machine_1",
    "Assembling Machine 2": "assembling_machine_2",
    "Assembling Machine 3": "assembling_machine_3",
    "Oil Refinery": "oil_refinery",
    "Chemical Plant": "chemical_plant",
    "Centrifuge": "centrifuge",
    "Lab": "lab",
    "Beacon": "beacon",
    "Rocket Silo": "rocket_silo",
    "Stone Furnace": "stone_furnace",
    "Steel Furnace": "steel_furnace",
    "Electric Furnace": "electric_furnace",
    "Burner Mining Drill": "burner_mining_drill",
    "Electric Mining Drill": "electric_mining_drill",
    "Big Mining Drill": "big_mining_drill",
    
    // Oil Processing Products
    "Plastic Bar": "plastic_bar",
    "Sulfur": "sulfur",
    "Sulfuric Acid": "sulfuric_acid",
    "Lubricant": "lubricant",
    "Battery": "battery",
    "Explosives": "explosives",
    "Solid Fuel": "solid_fuel",
    "Rocket Fuel": "rocket_fuel",
    "Nuclear Fuel": "nuclear_fuel",
    "Solid Rocket Fuel": "solid_rocket_fuel",
    
    // Advanced Materials
    "Concrete": "concrete",
    "Hazard Concrete": "hazard_concrete",
    "Refined Concrete": "refined_concrete",
    "Refined Hazard Concrete": "refined_hazard_concrete",
    "Landfill": "landfill",
    "Cliff Explosives": "cliff_explosives",
    
    // Modules
    "Speed Module": "speed_module",
    "Speed Module 2": "speed_module_2",
    "Speed Module 3": "speed_module_3",
    "Productivity Module": "productivity_module",
    "Productivity Module 2": "productivity_module_2",
    "Productivity Module 3": "productivity_module_3",
    "Efficiency Module": "efficiency_module",
    "Efficiency Module 2": "efficiency_module_2",
    "Efficiency Module 3": "efficiency_module_3",
    "Quality Module": "quality_module",
    "Quality Module 2": "quality_module_2",
    "Quality Module 3": "quality_module_3",
    
    // Nuclear
    "Uranium Fuel Cell": "uranium_fuel_cell",
    "Used Up Uranium Fuel Cell": "used_up_uranium_fuel_cell",
    "Fusion Power Cell": "fusion_power_cell",
    "Fusion Reactor": "fusion_reactor",
    
    // Science Packs
    "Automation Science Pack": "automation_science_pack",
    "Logistic Science Pack": "logistic_science_pack",
    "Military Science Pack": "military_science_pack",
    "Chemical Science Pack": "chemical_science_pack",
    "Production Science Pack": "production_science_pack",
    "Utility Science Pack": "utility_science_pack",
    "Space Science Pack": "space_science_pack",
    "Metallurgic Science Pack": "metallurgic_science_pack",
    "Electromagnetic Science Pack": "electromagnetic_science_pack",
    "Agricultural Science Pack": "agricultural_science_pack",
    "Cryogenic Science Pack": "cryogenic_science_pack",
    "Promethium Science Pack": "promethium_science_pack",
    
    // Rocket Components
    "Low Density Structure": "low_density_structure",
    "Rocket Control Unit": "rocket_control_unit",
    "Rocket Part": "rocket_part",
    "Satellite": "satellite",
    
    // Military
    "Firearm Magazine": "firearm_magazine",
    "Piercing Rounds Magazine": "piercing_rounds_magazine",
    "Uranium Rounds Magazine": "uranium_rounds_magazine",
    "Grenade": "grenade",
    "Wall": "wall",
    "Radar": "radar",
    "Rocket": "rocket",
    "Explosive Rocket": "explosive_rocket",
    "Cannon Shell": "cannon_shell",
    "Explosive Cannon Shell": "explosive_cannon_shell",
    "Uranium Cannon Shell": "uranium_cannon_shell",
    "Explosive Uranium Cannon Shell": "explosive_uranium_cannon_shell",
    "Artillery Shell": "artillery_shell",
    "Flamethrower Ammo": "flamethrower_ammo",
    "Poison Capsule": "poison_capsule",
    "Slowdown Capsule": "slowdown_capsule",
    "Defender Capsule": "defender_capsule",
    "Distractor Capsule": "distractor_capsule",
    "Destroyer Capsule": "destroyer_capsule",
    
    // Armor
    "Light Armor": "light_armor",
    "Heavy Armor": "heavy_armor",
    "Modular Armor": "modular_armor",
    "Power Armor": "power_armor",
    "Power Armor MK2": "power_armor_mk2",
    "Mech Armor": "mech_armor",
    
    // Space Age - Vulcanus
    "Tungsten Ore": "tungsten_ore",
    "Tungsten Plate": "tungsten_plate",
    "Tungsten Carbide": "tungsten_carbide",
    "Carbon": "carbon",
    "Carbon Fiber": "carbon_fiber",
    "Foundry": "foundry",
    "Molten Iron": "molten_iron",
    "Molten Copper": "molten_copper",
    "Calcite": "calcite",
    "Lava": "lava",
    
    // Space Age - Fulgora
    "Electromagnetic Plant": "electromagnetic_plant",
    "Superconductor": "superconductor",
    "Supercapacitor": "supercapacitor",
    "Holmium Ore": "holmium_ore",
    "Holmium Plate": "holmium_plate",
    "Holmium Solution": "holmium_solution",
    "Lightning Rod": "lightning_rod",
    "Lightning Collector": "lightning_collector",
    "Lightning Conductor": "lightning_conductor",
    "Scrap": "scrap",
    "Recycler": "recycler",
    "Tesla Turret": "tesla_turret",
    "Tesla Ammo": "tesla_ammo",
    
    // Space Age - Gleba
    "Biochamber": "biochamber",
    "Biolab": "biolab",
    "Nutrients": "nutrients",
    "Pentapod Egg": "pentapod_egg",
    "Pentapod Egg Fragment": "pentapod_egg_fragment",
    "Bioflux": "bioflux",
    "Yumako": "yumako",
    "Jellynut": "jellynut",
    "Tree Seed": "tree_seed",
    "Yumako Seed": "yumako_seed",
    "Jellynut Seed": "jellynut_seed",
    "Yumako Mash": "yumako_mash",
    "Jellynut Paste": "jellynut_paste",
    "Jelly": "jelly",
    "Spoilage": "spoilage",
    "Biomass": "biomass",
    "Biter Neural Tissue": "biter_neural_tissue",
    "Bacteria": "bacteria",
    "Iron Bacteria": "iron_bacteria",
    "Copper Bacteria": "copper_bacteria",
    "Biter Egg": "biter_egg",
    "Biter Egg Fragment": "biter_egg_fragment",
    "Raw Fish": "raw_fish",
    
    // Space Age - Aquilo
    "Cryogenic Plant": "cryogenic_plant",
    "Ice": "ice",
    "Ammonia": "ammonia",
    "Ammoniacal Solution": "ammoniacal_solution",
    "Lithium Ore": "lithium_ore",
    "Lithium Plate": "lithium_plate",
    "Pipeline": "pipeline",
    "Underground Pipeline": "pipeline_to_ground",
    "Thruster Fuel": "thruster_fuel",
    "Thruster Oxidizer": "thruster_oxidizer",
    "Oxidizer": "oxidizer",
    "Fluorine": "fluorine",
    "Fluorite": "fluorite",
    "Fluoroketone (Cold)": "fluoroketone_cold",
    "Fluoroketone (Hot)": "fluoroketone_hot",
    "Rocket Turret": "rocket_turret",
    "Railgun Turret": "railgun_turret",
    "Railgun Ammo": "railgun_ammo",
    "Deuterium": "deuterium",
    "Tritium": "tritium",
    "Hydrogen": "hydrogen",
    "Nitrogen": "nitrogen",
    "Oxygen": "oxygen",
    "Air": "air",
    
    // Space Platform
    "Space Platform Foundation": "space_platform_foundation",
    "Asteroid Collector": "asteroid_collector",
    "Crusher": "crusher",
    "Metallic Asteroid": "metallic_asteroid",
    "Carbonic Asteroid": "carbonic_asteroid",
    "Oxide Asteroid": "oxide_asteroid",
    "Promethium Asteroid": "promethium_asteroid",
    "Promethium Ore": "promethium_ore",
    "Promethium Asteroid Chunk": "promethium_asteroid_chunk",
    "Asteroid Chunk": "asteroid_chunk",
    "Space Platform Hub": "space_platform_hub",
    "Cargo Bay": "cargo_bay",
    "Thruster": "thruster",
    
    // Advanced Components
    "Quantum Processor": "quantum_processor",
    "Automation Core": "automation_core",
    
    // Miscellaneous
    "Repair Pack": "repair_pack",
    "Empty Barrel": "barrel",
    
    // Machine categories for center icons
    "assembling": "assembling_machine_3",
    "smelting": "electric_furnace",
    "chemistry": "chemical_plant",
    "biochamber": "biochamber",
    "biolab": "biolab",
    "electromagnetic": "electromagnetic_plant",
    "casting": "foundry",
    "cryogenic": "cryogenic_plant",
    "crushing": "crusher",
    "recycling": "recycler",
    "space-manufacturing": "space_platform_foundation",
    "centrifuging": "centrifuge",
    "rocket-building": "rocket_silo",
    "mining": "electric_mining_drill",
    "quality": "quality_module",
    "oil-refinery": "oil_refinery"
]
