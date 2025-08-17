import SwiftUI
import AppKit
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

// Intermediate products that allow productivity modules
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

// MARK: - Port Components
struct PortRow: View {
    @EnvironmentObject var graph: GraphState
    var nodeID: UUID
    var side: IOSide
    var item: String
    var amount: Double
    
    @State private var centerInCanvas: CGPoint = .zero
    
    private var flowRate: Double {
        guard let node = graph.nodes[nodeID],
              let targetPerMin = node.targetPerMin,
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return 0
        }
        
        if side == .output {
            let totalOutput = recipe.outputs.values.reduce(0, +)
            let actualOutput = totalOutput * (1 + node.totalProductivityBonus)
            let thisOutputRatio = amount / totalOutput
            return targetPerMin * thisOutputRatio * (1 + node.totalProductivityBonus)
        } else {
            let outputAmount = recipe.outputs.values.first ?? 1
            let actualOutput = outputAmount * (1 + node.totalProductivityBonus)
            let craftsPerMin = targetPerMin / actualOutput
            return craftsPerMin * amount
        }
    }
    
    private var flowRateText: String {
        if flowRate == 0 {
            return "×\(amount.formatted())"
        } else if flowRate == floor(flowRate) {
            return String(format: "%.0f", flowRate)
        } else {
            return String(format: "%.1f", flowRate)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if side == .input {
                HStack(spacing: 4) {
                    HStack(spacing: 4) {
                        IconOrMonogram(item: item, size: 16)
                            .hoverTooltip(item)
                        
                        Text(flowRateText)
                            .foregroundStyle(flowRate > 0 ? .primary : .secondary)
                            .font(.caption2)
                            .monospacedDigit()
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .layoutPriority(1)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .frame(minWidth: 0)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isPortConnected(nodeID: nodeID, item: item, side: .input, edges: graph.edges)
                                  ? Color.clear
                                  : Color.orange.opacity(0.3))
                            .animation(.easeInOut(duration: 0.2), value: isPortConnected(nodeID: nodeID, item: item, side: .input, edges: graph.edges))
                    )
                    .background(
                        GeometryReader { geometry in
                            let frame = geometry.frame(in: .named("canvas"))
                            Color.clear
                                .onAppear {
                                    centerInCanvas = CGPoint(x: frame.midX, y: frame.midY)
                                }
                                .onChange(of: frame) { _, newFrame in
                                    centerInCanvas = CGPoint(x: newFrame.midX, y: newFrame.midY)
                                }
                                .preference(
                                    key: PortFramesKey.self,
                                    value: [PortFrame(key: PortKey(nodeID: nodeID, item: item, side: side), frame: frame)]
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
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Text(flowRateText)
                            .foregroundStyle(flowRate > 0 ? .primary : .secondary)
                            .font(.caption2)
                            .monospacedDigit()
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .layoutPriority(1)
                        
                        IconOrMonogram(item: item, size: 16)
                            .hoverTooltip(item)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .frame(minWidth: 0)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isPortConnected(nodeID: nodeID, item: item, side: .output, edges: graph.edges)
                                  ? Color.clear
                                  : Color.orange.opacity(0.3))
                            .animation(.easeInOut(duration: 0.2), value: isPortConnected(nodeID: nodeID, item: item, side: .output, edges: graph.edges))
                    )
                    .background(
                        GeometryReader { geometry in
                            let frame = geometry.frame(in: .named("canvas"))
                            Color.clear
                                .onAppear {
                                    centerInCanvas = CGPoint(x: frame.midX, y: frame.midY)
                                }
                                .onChange(of: frame) { _, newFrame in
                                    centerInCanvas = CGPoint(x: newFrame.midX, y: newFrame.midY)
                                }
                                .preference(
                                    key: PortFramesKey.self,
                                    value: [PortFrame(key: PortKey(nodeID: nodeID, item: item, side: side), frame: frame)]
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
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let startPoint = centerInCanvas
        let currentPoint = CGPoint(
            x: startPoint.x + value.translation.width,
            y: startPoint.y + value.translation.height
        )
        
        if graph.dragging == nil {
            graph.dragging = DragContext(
                fromPort: PortKey(nodeID: nodeID, item: item, side: side),
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
            rect.insetBy(dx: -8, dy: -8).contains(currentPoint)
        }?.key
        
        if let targetPort = hitPort {
            if side == .output {
                graph.addEdge(from: nodeID, to: targetPort.nodeID, item: item)
            } else {
                graph.addEdge(from: targetPort.nodeID, to: nodeID, item: item)
            }
        } else {
            graph.pickerContext = PickerContext(
                fromPort: PortKey(nodeID: nodeID, item: item, side: side),
                dropPoint: currentPoint
            )
            graph.showPicker = true
        }
        
        graph.dragging = nil
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

// MARK: - Wire Rendering
struct WiresLayer: View {
    @EnvironmentObject var graph: GraphState
    var portFrames: [PortKey: CGRect]
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                for edge in graph.edges {
                    let outputPortKey = PortKey(nodeID: edge.fromNode, item: edge.item, side: .output)
                    let inputPortKey = PortKey(nodeID: edge.toNode, item: edge.item, side: .input)
                    
                    guard let fromRect = portFrames[outputPortKey],
                          let toRect = portFrames[inputPortKey] else {
                        continue
                    }
                    
                    let startPoint = CGPoint(x: fromRect.midX, y: fromRect.midY)
                    let endPoint = CGPoint(x: toRect.midX, y: toRect.midY)
                    let path = createCubicPath(from: startPoint, to: endPoint)
                    
                    context.stroke(
                        path,
                        with: .color(.orange.opacity(0.9)),
                        lineWidth: Constants.wireLineWidth
                    )
                }
            }
            .allowsHitTesting(false)
            
            ForEach(graph.edges, id: \.id) { edge in
                WireFlowLabel(edge: edge, portFrames: portFrames)
            }
        }
    }
}

struct WireFlowLabel: View {
    @EnvironmentObject var graph: GraphState
    var edge: Edge
    var portFrames: [PortKey: CGRect]
    
    var body: some View {
        let outputPortKey = PortKey(nodeID: edge.fromNode, item: edge.item, side: .output)
        let inputPortKey = PortKey(nodeID: edge.toNode, item: edge.item, side: .input)
        
        guard let fromRect = portFrames[outputPortKey],
              let toRect = portFrames[inputPortKey],
              let consumerNode = graph.nodes[edge.toNode],
              let consumerRecipe = RECIPES.first(where: { $0.id == consumerNode.recipeID }),
              let targetPerMin = consumerNode.targetPerMin,
              targetPerMin > 0 else {
            return AnyView(EmptyView())
        }
        
        let outputAmount = consumerRecipe.outputs.values.first ?? 1
        let actualOutput = outputAmount * (1 + consumerNode.totalProductivityBonus)
        let craftsPerMin = targetPerMin / actualOutput
        let inputAmount = consumerRecipe.inputs[edge.item] ?? 0
        let flowRate = craftsPerMin * inputAmount
        
        let startPoint = CGPoint(x: fromRect.midX, y: fromRect.midY)
        let endPoint = CGPoint(x: toRect.midX, y: toRect.midY)
        let midPoint = CGPoint(
            x: (startPoint.x + endPoint.x) / 2,
            y: (startPoint.y + endPoint.y) / 2
        )
        
        let flowText: String
        if flowRate == floor(flowRate) {
            flowText = String(format: "%.0f", flowRate)
        } else {
            flowText = String(format: "%.1f", flowRate)
        }
        
        return AnyView(
            Text(flowText)
                .font(.body)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.orange.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.orange.opacity(0.6))
                )
                .position(midPoint)
                .allowsHitTesting(false)
        )
    }
}

struct WireTempPath: View {
    var from: CGPoint
    var to: CGPoint
    
    var body: some View {
        Canvas { context, size in
            let path = createCubicPath(from: from, to: to)
            let dashedPath = path.strokedPath(.init(lineWidth: Constants.wireLineWidth, dash: [6, 6]))
            
            context.stroke(
                dashedPath,
                with: .color(.blue.opacity(0.8))
            )
        }
        .allowsHitTesting(false)
    }
}

func createCubicPath(from startPoint: CGPoint, to endPoint: CGPoint) -> Path {
    var path = Path()
    let deltaX = max(abs(endPoint.x - startPoint.x) * 0.5, Constants.curveTension)
    
    path.move(to: startPoint)
    path.addCurve(
        to: endPoint,
        control1: CGPoint(x: startPoint.x + deltaX, y: startPoint.y),
        control2: CGPoint(x: endPoint.x - deltaX, y: endPoint.y)
    )
    return path
}

// MARK: - Updated General Recipe Picker with Arrow Key Navigation

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
    
    private var selectedRecipeID: String? {
        guard selectedIndex >= 0 && selectedIndex < filteredRecipes.count else { return nil }
        return filteredRecipes[selectedIndex].id
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
                        // When Enter is pressed, select the current recipe
                        if selectedIndex >= 0 && selectedIndex < filteredRecipes.count {
                            selectRecipe(filteredRecipes[selectedIndex])
                        }
                    }
                    .onChange(of: searchText) { _, _ in
                        // Reset selection to first item when search changes
                        selectedIndex = 0
                    }
            }
            
            ScrollViewReader { proxy in
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
                .onChange(of: selectedIndex) { _, newIndex in
                    // Scroll to selected item when using arrow keys
                    if newIndex >= 0 && newIndex < filteredRecipes.count {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            proxy.scrollTo(filteredRecipes[newIndex].id, anchor: .center)
                        }
                    }
                }
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

// MARK: - Updated Recipe Picker (for port connections) with Arrow Key Navigation
// Replace your existing RecipePicker with this version:

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
    
    private var selectedRecipeID: String? {
        guard selectedIndex >= 0 && selectedIndex < availableRecipes.count else { return nil }
        return availableRecipes[selectedIndex].id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon
            HStack {
                // Show the item icon and name
                HStack(spacing: 10) {
                    // Larger, more prominent icon
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
                            
                            // Debug: Show if icon exists
                            if ICON_ASSETS[context.fromPort.item] == nil {
                                Text("(no icon)")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
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
                    // When Enter is pressed, select the current recipe
                    if selectedIndex >= 0 && selectedIndex < availableRecipes.count {
                        selectRecipe(availableRecipes[selectedIndex])
                    }
                }
                .onChange(of: searchText) { _, _ in
                    // Reset selection to first item when search changes
                    selectedIndex = 0
                }
            
            ScrollViewReader { proxy in
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
                .onChange(of: selectedIndex) { _, newIndex in
                    // Scroll to selected item when using arrow keys
                    if newIndex >= 0 && newIndex < availableRecipes.count {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            proxy.scrollTo(availableRecipes[newIndex].id, anchor: .center)
                        }
                    }
                }
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
            
            // Debug print to see what item we're looking for
            print("Looking for icon for item: '\(context.fromPort.item)'")
            print("Icon asset found: \(ICON_ASSETS[context.fromPort.item] ?? "NOT FOUND")")
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
            graph.addEdge(from: context.fromPort.nodeID, to: newNode.id, item: context.fromPort.item)
        case .input:
            graph.addEdge(from: newNode.id, to: context.fromPort.nodeID, item: context.fromPort.item)
        }
    }
}

struct RecipeListRow: View {
    var recipe: Recipe
    var isSelected: Bool = false
    var onSelect: () -> Void
    @State private var isHovered = false
    
    private var isAlternative: Bool {
        return isAlternativeRecipe(recipe)
    }
    
    // Get the primary output item for the icon
    private var primaryOutputItem: String {
        // For most recipes, use the first output
        if let firstOutput = recipe.outputs.keys.first {
            return firstOutput
        }
        // Fallback to recipe name if no outputs (shouldn't happen)
        return recipe.name
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Alternative recipe indicator
            if isAlternative {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 4, height: 40)
            }
            
            // Recipe Icon (primary output)
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
                    // Inputs
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
                    
                    // Outputs
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


// MARK: - Module System
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

// MARK: - Machine Tier System
struct MachineTier: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let category: String
    let speed: Double
    let iconAsset: String?
    let moduleSlots: Int
}

// MARK: - Default Machine Preferences
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
        MachineTier(id: "foundry", name: "Foundry", category: "casting", speed: 1.0, iconAsset: "foundry", moduleSlots: 4)
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
    "quality": [
        MachineTier(id: "quality-module", name: "Quality Module", category: "quality", speed: 1.0, iconAsset: "quality_module", moduleSlots: 0)
    ]
]

// MARK: - Available Modules Data
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
    
    // Efficiency Modules - Level 3
    Module(id: "efficiency-3-normal", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .normal,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.5, iconAsset: "efficiency_module_3"),
    Module(id: "efficiency-3-uncommon", name: "Efficiency Module 3", type: .efficiency, level: 3, quality: .uncommon,
           speedBonus: 0, productivityBonus: 0, efficiencyBonus: 0.65, iconAsset: "efficiency_module_3"),
    
    // Quality Modules
    Module(id: "quality-1-normal", name: "Quality Module", type: .quality, level: 1, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module"),
    Module(id: "quality-2-normal", name: "Quality Module 2", type: .quality, level: 2, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module_2"),
    Module(id: "quality-3-normal", name: "Quality Module 3", type: .quality, level: 3, quality: .normal,
           speedBonus: -0.05, productivityBonus: 0, efficiencyBonus: -0.1, iconAsset: "quality_module_3")
]

// MARK: - Recipe Model
struct Recipe: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var category: String
    var time: Double
    var inputs: [String: Double]
    var outputs: [String: Double]
}

// MARK: - Recipes Data (complete list with alternatives)
let RECIPES: [Recipe] = [
    // Basic Resources
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
    
    // Science Packs (CORRECTED)
    Recipe(id: "automation-science-pack", name: "Automation Science Pack", category: "assembling", time: 5, inputs: ["Copper Plate": 1, "Iron Gear Wheel": 1], outputs: ["Automation Science Pack": 1]),
    Recipe(id: "logistic-science-pack", name: "Logistic Science Pack", category: "assembling", time: 6, inputs: ["Inserter": 1, "Transport Belt": 1], outputs: ["Logistic Science Pack": 1]),
    Recipe(id: "military-science-pack", name: "Military Science Pack", category: "assembling", time: 10, inputs: ["Piercing Rounds Magazine": 1, "Grenade": 1, "Wall": 2], outputs: ["Military Science Pack": 2]),
    Recipe(id: "chemical-science-pack", name: "Chemical Science Pack", category: "assembling", time: 24, inputs: ["Engine Unit": 2, "Advanced Circuit": 3, "Sulfur": 1], outputs: ["Chemical Science Pack": 2]),
    Recipe(id: "production-science-pack", name: "Production Science Pack", category: "assembling", time: 21, inputs: ["Electric Furnace": 1, "Productivity Module": 1, "Rail": 30], outputs: ["Production Science Pack": 3]),
    Recipe(id: "utility-science-pack", name: "Utility Science Pack", category: "assembling", time: 21, inputs: ["Low Density Structure": 3, "Processing Unit": 2, "Flying Robot Frame": 1], outputs: ["Utility Science Pack": 3]),
    
    // Space Age Science Packs (NEW)
    Recipe(id: "space-science-pack", name: "Space Science Pack", category: "space-manufacturing", time: 15, inputs: ["Asteroid Chunk": 1, "Empty Barrel": 1, "Processing Unit": 1], outputs: ["Space Science Pack": 5]),
    Recipe(id: "metallurgic-science-pack", name: "Metallurgic Science Pack", category: "assembling", time: 36, inputs: ["Tungsten Carbide": 3, "Tungsten Plate": 6, "Carbon": 1], outputs: ["Metallurgic Science Pack": 1]),
    Recipe(id: "electromagnetic-science-pack", name: "Electromagnetic Science Pack", category: "electromagnetic", time: 10, inputs: ["Supercapacitor": 1, "Holmium Plate": 1, "Accumulator": 1], outputs: ["Electromagnetic Science Pack": 1]),
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
    
    // Alternative Molten Metal Recipes (ALT recipes from Foundry)
    Recipe(id: "molten-iron", name: "Molten Iron", category: "casting", time: 32, inputs: ["Iron Ore": 50, "Calcite": 1], outputs: ["Molten Iron": 500]),
    Recipe(id: "molten-copper", name: "Molten Copper", category: "casting", time: 32, inputs: ["Copper Ore": 50, "Calcite": 1], outputs: ["Molten Copper": 500]),
    Recipe(id: "molten-iron-from-lava", name: "Molten Iron from Lava", category: "casting", time: 16, inputs: ["Lava": 500, "Calcite": 2], outputs: ["Molten Iron": 250, "Stone": 10]),
    Recipe(id: "molten-copper-from-lava", name: "Molten Copper from Lava", category: "casting", time: 16, inputs: ["Lava": 500, "Calcite": 2], outputs: ["Molten Copper": 250, "Stone": 10]),
    Recipe(id: "iron-plate-from-molten", name: "Iron Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Iron": 10], outputs: ["Iron Plate": 1]),
    Recipe(id: "copper-plate-from-molten", name: "Copper Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Copper": 10], outputs: ["Copper Plate": 1]),
    Recipe(id: "steel-plate-from-molten", name: "Steel Plate (Molten)", category: "casting", time: 3.2, inputs: ["Molten Iron": 30], outputs: ["Steel Plate": 1]),
    Recipe(id: "concrete-from-molten", name: "Concrete (Foundry)", category: "casting", time: 10, inputs: ["Molten Iron": 20, "Water": 100, "Stone Brick": 5], outputs: ["Concrete": 10]),
    Recipe(id: "casting-copper-cable", name: "Casting Copper Cable", category: "casting", time: 0.5, inputs: ["Molten Copper": 5], outputs: ["Copper Cable": 2]),
    Recipe(id: "casting-iron-gear-wheel", name: "Casting Iron Gear Wheel", category: "casting", time: 0.5, inputs: ["Molten Iron": 10], outputs: ["Iron Gear Wheel": 1]),
    Recipe(id: "casting-iron-stick", name: "Casting Iron Stick", category: "casting", time: 0.5, inputs: ["Molten Iron": 5], outputs: ["Iron Stick": 2]),
    Recipe(id: "casting-low-density-structure", name: "Casting Low Density Structure", category: "casting", time: 15, inputs: ["Molten Copper": 200, "Molten Iron": 20, "Plastic Bar": 5], outputs: ["Low Density Structure": 1]),
    Recipe(id: "casting-pipe", name: "Casting Pipe", category: "casting", time: 0.5, inputs: ["Molten Iron": 10], outputs: ["Pipe": 1]),
    Recipe(id: "casting-pipe-to-ground", name: "Casting Pipe to Ground", category: "casting", time: 1, inputs: ["Molten Iron": 50, "Pipe": 2], outputs: ["Pipe to Ground": 2]),
    
    // Vulcanus-specific
    Recipe(id: "tungsten-plate", name: "Tungsten Plate", category: "smelting", time: 10, inputs: ["Tungsten Ore": 4, "Sulfuric Acid": 10], outputs: ["Tungsten Plate": 1]),
    Recipe(id: "tungsten-carbide", name: "Tungsten Carbide", category: "assembling", time: 2, inputs: ["Tungsten Plate": 2, "Carbon": 1], outputs: ["Tungsten Carbide": 1]),
    Recipe(id: "carbon", name: "Carbon", category: "chemistry", time: 1, inputs: ["Coal": 2, "Sulfuric Acid": 20], outputs: ["Carbon": 1]),
    Recipe(id: "carbon-fiber", name: "Carbon Fiber", category: "assembling", time: 4, inputs: ["Carbon": 4, "Plastic Bar": 2], outputs: ["Carbon Fiber": 1]),
    
    // Fulgora-specific (NEW)
    Recipe(id: "holmium-solution", name: "Holmium Solution", category: "chemistry", time: 1, inputs: ["Holmium Ore": 2, "Stone": 1, "Water": 10], outputs: ["Holmium Solution": 10]),
    Recipe(id: "holmium-plate", name: "Holmium Plate", category: "assembling", time: 1, inputs: ["Holmium Solution": 20], outputs: ["Holmium Plate": 1]),
    Recipe(id: "superconductor", name: "Superconductor", category: "electromagnetic", time: 5, inputs: ["Copper Plate": 2, "Plastic Bar": 1, "Holmium Plate": 1, "Light Oil": 5], outputs: ["Superconductor": 1]),
    Recipe(id: "supercapacitor", name: "Supercapacitor", category: "electromagnetic", time: 10, inputs: ["Battery": 2, "Electronic Circuit": 4, "Superconductor": 2, "Holmium Solution": 10], outputs: ["Supercapacitor": 1]),
    Recipe(id: "lightning-rod", name: "Lightning Rod", category: "assembling", time: 5, inputs: ["Copper Plate": 3, "Steel Plate": 8], outputs: ["Lightning Rod": 1]),
    Recipe(id: "lightning-collector", name: "Lightning Collector", category: "electromagnetic", time: 10, inputs: ["Lightning Rod": 2, "Accumulator": 1, "Superconductor": 4], outputs: ["Lightning Collector": 1]),
    Recipe(id: "scrap-recycling", name: "Scrap Recycling", category: "recycling", time: 0.2, inputs: ["Scrap": 1], outputs: ["Iron Gear Wheel": 0.2, "Concrete": 0.05, "Copper Cable": 0.03, "Steel Plate": 0.02, "Solid Fuel": 0.07, "Stone": 0.04, "Battery": 0.01, "Processing Unit": 0.002, "Low Density Structure": 0.001, "Ice": 0.05, "Holmium Ore": 0.01]),
    
    // Electromagnetic Plant exclusive recipes (NEW)
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
    
    // Advanced Asteroid Crushing (ALT recipes)
    Recipe(id: "advanced-metallic-asteroid-crushing", name: "Advanced Metallic Asteroid Crushing", category: "crushing", time: 5, inputs: ["Metallic Asteroid": 1], outputs: ["Iron Ore": 25, "Copper Ore": 12, "Stone": 10, "Holmium Ore": 1, "Tungsten Ore": 1]),
    Recipe(id: "advanced-carbonic-asteroid-crushing", name: "Advanced Carbonic Asteroid Crushing", category: "crushing", time: 5, inputs: ["Carbonic Asteroid": 1], outputs: ["Carbon": 12, "Sulfur": 5, "Water": 25]),
    Recipe(id: "advanced-oxide-asteroid-crushing", name: "Advanced Oxide Asteroid Crushing", category: "crushing", time: 5, inputs: ["Oxide Asteroid": 1], outputs: ["Ice": 12, "Calcite": 6, "Iron Ore": 6]),
    
    // Space Platform Processing
    Recipe(id: "asteroid-chunk-processing", name: "Asteroid Chunk Processing", category: "assembling", time: 1, inputs: ["Asteroid Chunk": 1], outputs: ["Iron Ore": 1, "Copper Ore": 1, "Stone": 1]),
    Recipe(id: "thruster-fuel", name: "Thruster Fuel", category: "chemistry", time: 10, inputs: ["Carbon": 2, "Water": 10], outputs: ["Thruster Fuel": 1]),
    Recipe(id: "thruster-oxidizer", name: "Thruster Oxidizer", category: "chemistry", time: 10, inputs: ["Water": 10, "Iron Ore": 2], outputs: ["Thruster Oxidizer": 1]),
    
    // Gleba / Biochamber Recipes
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
    
    // Biochamber Alternatives (ALT recipes)
    Recipe(id: "bioplastic", name: "Bioplastic", category: "biochamber", time: 5, inputs: ["Yumako Mash": 10, "Jellynut Paste": 10], outputs: ["Plastic Bar": 2]),
    Recipe(id: "biosulfur", name: "Biosulfur", category: "biochamber", time: 2, inputs: ["Yumako Mash": 5, "Bacteria": 5], outputs: ["Sulfur": 2]),
    Recipe(id: "biolubricant", name: "Biolubricant", category: "biochamber", time: 2, inputs: ["Jellynut Paste": 10], outputs: ["Lubricant": 10]),
    Recipe(id: "rocket-fuel-from-jelly", name: "Rocket Fuel from Jelly", category: "biochamber", time: 30, inputs: ["Jelly": 30], outputs: ["Rocket Fuel": 1]),
    Recipe(id: "iron-bacteria-cultivation", name: "Iron Bacteria Cultivation", category: "biochamber", time: 4, inputs: ["Iron Bacteria": 1, "Nutrients": 10], outputs: ["Iron Ore": 1]),
    Recipe(id: "copper-bacteria-cultivation", name: "Copper Bacteria Cultivation", category: "biochamber", time: 4, inputs: ["Copper Bacteria": 1, "Nutrients": 10], outputs: ["Copper Ore": 1]),
    
    // Aquilo / Cryogenic Recipes (NEW)
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
    
    // Aquilo Advanced (NEW)
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
    Recipe(id: "radar", name: "Radar", category: "assembling", time: 0.5, inputs: ["Electronic Circuit": 5, "Iron Gear Wheel": 5, "Iron Plate": 10], outputs: ["Radar": 1]),
]

// MARK: - Icon Assets (complete list)
let ICON_ASSETS: [String: String] = [
    // Basic Resources
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
    "concrete-from-molten",
    
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

// MARK: - Item mappings
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

// MARK: - Node Model
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
        return modules.compactMap { $0?.productivityBonus }.reduce(0, +)
    }
    
    var totalEfficiencyBonus: Double {
        return modules.compactMap { $0?.efficiencyBonus }.reduce(0, +)
    }
    
    var speed: Double {
        return getEffectiveSpeed(for: self)
    }
}

// MARK: - Edge Model
struct Edge: Identifiable, Codable, Hashable {
    var id = UUID()
    var fromNode: UUID
    var toNode: UUID
    var item: String
}

// MARK: - Port Key
struct PortKey: Hashable, Codable {
    var nodeID: UUID
    var item: String
    var side: IOSide
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
    
    if let prefs = preferences,
       let defaultTierID = prefs.getDefaultTier(for: recipe.category),
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
        // (Check if any output is a fluid - simplified check based on common fluids)
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
    default: return category.capitalized
    }
}

func machineCount(for node: Node) -> Double {
    guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
        return 0
    }
    
    let outputAmount = recipe.outputs.values.first ?? 1
    let actualOutput = outputAmount * (1 + node.totalProductivityBonus)
    let craftsPerMin = (node.targetPerMin ?? 0) / actualOutput
    let machines = (craftsPerMin * recipe.time) / 60.0 / max(Constants.minSpeed, node.speed)
    
    return machines
}

func isPortConnected(nodeID: UUID, item: String, side: IOSide, edges: [Edge]) -> Bool {
    return edges.contains { edge in
        switch side {
        case .output:
            return edge.fromNode == nodeID && edge.item == item
        case .input:
            return edge.toNode == nodeID && edge.item == item
        }
    }
}

func isAlternativeRecipe(_ recipe: Recipe) -> Bool {
    return ALTERNATIVE_RECIPE_IDS.contains(recipe.id)
}

// MARK: - Graph State
final class GraphState: ObservableObject, Codable {
    enum CodingKeys: CodingKey {
        case nodes, edges
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
    
    private var isComputing = false
    private var pendingCompute = false
    private var saveTimer: Timer?
    
    init() {
        loadAutoSave()
        loadPreferences()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nodeArray = try container.decode([Node].self, forKey: .nodes)
        self.nodes = Dictionary(uniqueKeysWithValues: nodeArray.map { ($0.id, $0) })
        self.edges = try container.decode([Edge].self, forKey: .edges)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Array(nodes.values), forKey: .nodes)
        try container.encode(edges, forKey: .edges)
    }
    
    // MARK: - Selection and Clipboard Methods
    
    func selectNode(_ nodeID: UUID?) {
        selectedNodeID = nodeID
    }
    
    func copyNode() {
        guard let selectedID = selectedNodeID,
              let node = nodes[selectedID] else { return }
        clipboard = node
        clipboardWasCut = false
        print("Copied node: \(node.recipeID)")
    }
    
    func cutNode() {
        guard let selectedID = selectedNodeID,
              let node = nodes[selectedID] else { return }
        clipboard = node
        clipboardWasCut = true
        removeNode(selectedID)
        selectedNodeID = nil
        print("Cut node: \(node.recipeID)")
    }
    
    func pasteNode() {
        guard let nodeToPaste = clipboard else { return }
        
        // Create a new node with offset position
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
        
        // Copy machine tier and modules
        newNode.selectedMachineTierID = nodeToPaste.selectedMachineTierID
        newNode.modules = nodeToPaste.modules
        
        nodes[newNode.id] = newNode
        selectedNodeID = newNode.id
        computeFlows()
        
        // If it was cut, clear the clipboard
        if clipboardWasCut {
            clipboard = nil
            clipboardWasCut = false
        }
        
        print("Pasted node at \(newPosition)")
    }
    
    func deleteSelectedNode() {
        guard let selectedID = selectedNodeID else { return }
        removeNode(selectedID)
        selectedNodeID = nil
    }
    
    // MARK: - Auto-Save Functions
    
    private func autoSave() {
        // Cancel any pending save
        saveTimer?.invalidate()
        
        // Schedule a new save after a short delay (to avoid saving on every single change)
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.performSave()
        }
    }
    
    private func performSave() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: "FactorioPlannerAutoSave")
            print("Auto-saved graph with \(nodes.count) nodes and \(edges.count) edges")
        } catch {
            print("Failed to auto-save: \(error)")
        }
    }
    
    private func loadAutoSave() {
        guard let data = UserDefaults.standard.data(forKey: "FactorioPlannerAutoSave") else {
            print("No auto-save found, starting fresh")
            return
        }
        
        do {
            let savedState = try JSONDecoder().decode(GraphState.self, from: data)
            self.nodes = savedState.nodes
            self.edges = savedState.edges
            print("Loaded auto-save with \(nodes.count) nodes and \(edges.count) edges")
            
            // Recompute flows after loading
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
    
    // MARK: - Manual Save/Load/Clear
    
    func clearGraph() {
        nodes.removeAll()
        edges.removeAll()
        selectedNodeID = nil
        computeFlows()
    }
    
    func hasAutoSave() -> Bool {
        return UserDefaults.standard.data(forKey: "FactorioPlannerAutoSave") != nil
    }
    
    // MARK: - Node Management
    
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
        selectedNodeID = node.id  // Auto-select newly added node
        computeFlows()
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
        
        computeFlows()
    }
    
    func addEdge(from: UUID, to: UUID, item: String) {
        guard from != to else { return }
        
        let edgeExists = edges.contains { edge in
            edge.fromNode == from && edge.toNode == to && edge.item == item
        }
        
        if !edgeExists {
            edges.append(Edge(fromNode: from, toNode: to, item: item))
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
        
        var newTargets: [UUID: Double] = [:]
        
        for (id, node) in nodes {
            newTargets[id] = node.targetPerMin ?? 0
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
                
                let outputAmount = recipe.outputs.values.first ?? 1
                let actualOutput = outputAmount * (1 + consumer.totalProductivityBonus)
                let craftsPerMin = (newTargets[consumer.id] ?? 0) / actualOutput
                let inputAmount = recipe.inputs[edge.item] ?? 0
                let totalNeed = craftsPerMin * inputAmount
                
                switch aggregate {
                case .sum:
                    needBySupplier[edge.fromNode, default: 0] += totalNeed
                case .max:
                    needBySupplier[edge.fromNode] = max(needBySupplier[edge.fromNode] ?? 0, totalNeed)
                }
            }
            
            for (supplierID, need) in needBySupplier {
                let currentTarget = newTargets[supplierID] ?? 0
                if abs(currentTarget - need) > Constants.computationTolerance {
                    newTargets[supplierID] = need
                    hasChanges = true
                }
            }
        }
        
        for (id, targetValue) in newTargets {
            guard var node = nodes[id] else { continue }
            let roundedTarget = abs(targetValue - round(targetValue)) < 0.01 ? round(targetValue) : round(targetValue * 10) / 10
            if abs((node.targetPerMin ?? 0) - roundedTarget) > Constants.computationTolerance {
                node.targetPerMin = roundedTarget
                nodes[id] = node
            }
        }
    }
    
    // MARK: - Import/Export
    
    func exportJSON(from window: NSWindow?) {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "factorio_cards_plan.json"
        
        let targetWindow = window ?? NSApp.keyWindow
        
        savePanel.beginSheetModal(for: targetWindow!) { response in
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
        
        let targetWindow = window ?? NSApp.keyWindow
        
        openPanel.beginSheetModal(for: targetWindow!) { response in
            guard response == .OK, let url = openPanel.url else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let graphState = try JSONDecoder().decode(GraphState.self, from: data)
                
                DispatchQueue.main.async {
                    self.nodes = graphState.nodes
                    self.edges = graphState.edges
                    self.selectedNodeID = nil
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
            // Edit menu commands
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
                
                Button("Select All") {
                    // Placeholder - you could implement select all functionality
                }
                .keyboardShortcut("a", modifiers: [.command])
                .disabled(true)  // Disabled for now
            }
            
            // File menu commands
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
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            CanvasView()
        }
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

// MARK: - Top Bar
struct TopBar: View {
    @EnvironmentObject var graph: GraphState
    @State private var showClearConfirmation = false
    
    var body: some View {
        HStack(spacing: 8) {
            Button("Add Recipe") {
                graph.generalPickerDropPoint = CGPoint(
                    x: 120 + .random(in: 0...80),
                    y: 160 + .random(in: 0...60)
                )
                graph.showGeneralPicker = true
            }
            .buttonStyle(TopButtonStyle(primary: true))
            
            Menu("Preferences") {
                Menu("Default Machines") {
                    ForEach(MACHINE_TIERS.keys.sorted(), id: \.self) { category in
                        if let tiers = MACHINE_TIERS[category], tiers.count > 1 {
                            Menu(machineName(for: category)) {
                                ForEach(tiers, id: \.id) { tier in
                                    Button(action: {
                                        let prefs = MachinePreferences.load()
                                        prefs.setDefaultTier(for: category, tierID: tier.id)
                                    }) {
                                        HStack {
                                            Text(tier.name)
                                            if MachinePreferences.load().getDefaultTier(for: category) == tier.id {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .buttonStyle(TopButtonStyle())
            
            Menu("Flow: \(graph.aggregate.rawValue)") {
                ForEach(GraphState.Aggregate.allCases, id: \.self) { mode in
                    Button(mode.rawValue) {
                        graph.aggregate = mode
                        graph.computeFlows()
                    }
                }
            }
            
            Spacer()
            
            // Auto-save indicator
            if graph.nodes.count > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .imageScale(.small)
                    Text("Auto-saved")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Button("Clear") {
                showClearConfirmation = true
            }
            .buttonStyle(TopButtonStyle())
            .disabled(graph.nodes.isEmpty)
            .confirmationDialog("Clear Graph", isPresented: $showClearConfirmation) {
                Button("Clear Everything", role: .destructive) {
                    graph.clearGraph()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove all nodes and connections. This action cannot be undone.")
            }
            
            Button("Export .json") {
                graph.exportJSON(from: NSApp.keyWindow)
            }
            .buttonStyle(TopButtonStyle())
            
            Button("Import .json") {
                graph.importJSON(from: NSApp.keyWindow)
            }
            .buttonStyle(TopButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .overlay(Divider(), alignment: .bottom)
    }
}

struct TopButtonStyle: ButtonStyle {
    var primary = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                if primary {
                    LinearGradient(
                        colors: [
                            Color(nsColor: NSColor(calibratedRed: 0.15, green: 0.19, blue: 0.28, alpha: 1)),
                            Color(nsColor: NSColor(calibratedRed: 0.11, green: 0.14, blue: 0.20, alpha: 1))
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    Color(nsColor: NSColor(calibratedWhite: 0.16, alpha: 1))
                }
            }
            .foregroundStyle(.primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.08))
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Canvas View
struct CanvasView: View {
    @EnvironmentObject var graph: GraphState
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                // Combined mouse tracking and right-click handling
                AdvancedMouseTrackingView(
                    onMouseMove: { position in
                        graph.lastMousePosition = position
                    },
                    onRightClick: { position in
                        graph.generalPickerDropPoint = position
                        graph.showGeneralPicker = true
                    },
                    onClick: { position in
                        // Click on empty canvas to deselect
                        graph.selectNode(nil)
                    }
                )
                
                GridBackground()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                
                WiresLayer(portFrames: graph.portFrames)
                    .allowsHitTesting(false)
                
                if let dragContext = graph.dragging {
                    WireTempPath(from: dragContext.startPoint, to: dragContext.currentPoint)
                }
                
                ForEach(Array(graph.nodes.values), id: \.id) { node in
                    NodeCard(node: node)
                        .position(x: node.x, y: node.y)
                }
            }
            .coordinateSpace(name: "canvas")
            .background(DragReceiver())
            .onDrop(of: [UTType.text], isTargeted: .constant(false)) { _, _ in false }
        }
    }
}

struct AdvancedMouseTrackingView: NSViewRepresentable {
    let onMouseMove: (CGPoint) -> Void
    let onRightClick: (CGPoint) -> Void
    let onClick: (CGPoint) -> Void
    
    func makeNSView(context: Context) -> AdvancedMouseNSView {
        let view = AdvancedMouseNSView()
        view.onMouseMove = onMouseMove
        view.onRightClick = onRightClick
        view.onClick = onClick
        return view
    }
    
    func updateNSView(_ nsView: AdvancedMouseNSView, context: Context) {}
    
    class AdvancedMouseNSView: NSView {
        var onMouseMove: ((CGPoint) -> Void)?
        var onRightClick: ((CGPoint) -> Void)?
        var onClick: ((CGPoint) -> Void)?
        var trackingArea: NSTrackingArea?
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            
            if let trackingArea = trackingArea {
                removeTrackingArea(trackingArea)
            }
            
            let options: NSTrackingArea.Options = [
                .activeInKeyWindow,
                .mouseMoved,
                .mouseEnteredAndExited
            ]
            
            trackingArea = NSTrackingArea(
                rect: bounds,
                options: options,
                owner: self,
                userInfo: nil
            )
            
            if let trackingArea = trackingArea {
                addTrackingArea(trackingArea)
            }
        }
        
        override func mouseMoved(with event: NSEvent) {
            let locationInWindow = convert(event.locationInWindow, from: nil)
            let flippedLocation = CGPoint(x: locationInWindow.x, y: bounds.height - locationInWindow.y)
            onMouseMove?(flippedLocation)
        }
        
        override func mouseDown(with event: NSEvent) {
            let locationInWindow = convert(event.locationInWindow, from: nil)
            let flippedLocation = CGPoint(x: locationInWindow.x, y: bounds.height - locationInWindow.y)
            onClick?(flippedLocation)
        }
        
        override func rightMouseDown(with event: NSEvent) {
            let locationInWindow = convert(event.locationInWindow, from: nil)
            let flippedLocation = CGPoint(x: locationInWindow.x, y: bounds.height - locationInWindow.y)
            onRightClick?(flippedLocation)
        }
        
        override var acceptsFirstResponder: Bool { true }
        override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
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

struct DragReceiver: View {
    var body: some View {
        Color.clear
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
    
    var body: some View {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
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
                    .fill(Color.black.opacity(isSelected ? 0.25 : 0.20))  // Slightly lighter when selected
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange.opacity(0.4) : Color.white.opacity(0.05), lineWidth: isSelected ? 1.5 : 1)
            )
            .opacity(isSelected ? 1.0 : 0.9)
            .shadow(color: isSelected ? Color.orange.opacity(0.15) : Color.clear, radius: 4)  // Subtle glow
            .frame(minWidth: Constants.nodeMinWidth, maxWidth: Constants.nodeMaxWidth, alignment: .leading)
            .offset(dragOffset)  // Apply visual offset for smooth dragging
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isDragging)
            .animation(.easeOut(duration: 0.15), value: isSelected)
            .onTapGesture {
                graph.selectNode(node.id)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            graph.selectNode(node.id)  // Select on drag start
                        }
                        // Only update visual position during drag (smooth, immediate feedback)
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        isDragging = false
                        
                        // Update the actual node position in state when drag ends
                        guard var updatedNode = graph.nodes[node.id] else { return }
                        updatedNode.x = node.x + value.translation.width
                        updatedNode.y = node.y + value.translation.height
                        
                        // Update state without animation to prevent bounce
                        withAnimation(nil) {
                            graph.nodes[node.id] = updatedNode
                        }
                        
                        // Reset visual offset since position is now in state
                        dragOffset = .zero
                        
                        // Compute flows after drag is complete
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
        
        // Update module slots when tier changes
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

// MARK: - Module UI Components
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
    
    private var hasRestrictions: Bool {
        guard let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return false
        }
        
        // Check if productivity modules are restricted
        let testProductivityModule = Module(
            id: "test", name: "Test", type: .productivity, level: 1,
            quality: .normal, speedBonus: 0, productivityBonus: 0.1,
            efficiencyBonus: 0, iconAsset: nil
        )
        
        return !canUseModule(testProductivityModule, forRecipe: recipe)
    }
    
    var body: some View {
        Button(action: {
            showModulePicker = true
        }) {
            Group {
                if slotIndex < node.modules.count, let module = node.modules[slotIndex] {
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
        .help(hasRestrictions ? "This recipe has module restrictions" : "Add module")
        .sheet(isPresented: $showModulePicker) {
            ModulePicker(node: node, slotIndex: slotIndex)
        }
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

struct ModulePicker: View {
    @EnvironmentObject var graph: GraphState
    var node: Node
    var slotIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: ModuleType = .speed
    @State private var selectedLevel: Int = 1
    @State private var selectedQuality: Quality = .normal
    
    private var nodeRecipe: Recipe? {
        RECIPES.first(where: { $0.id == node.recipeID })
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Choose Module")
                    .font(.headline)
                Spacer()
                Button("Close") {
                    dismiss()
                }
            }
            
            // Show recipe name for context
            if let recipe = nodeRecipe {
                Text("For: \(recipe.name)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Type picker
            Picker("Module Type", selection: $selectedType) {
                ForEach(ModuleType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            // Show warning if module type is restricted
            if let recipe = nodeRecipe, let testModule = currentModule {
                if !canUseModule(testModule, forRecipe: recipe) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        if selectedType == .productivity {
                            Text("Productivity modules can only be used on recipes that produce intermediate products")
                        } else if selectedType == .quality {
                            Text("Quality modules cannot be used on recipes that produce fluids")
                        } else {
                            Text("This module type cannot be used with this recipe")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            
            // Level picker
            HStack {
                Text("Level:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Level", selection: $selectedLevel) {
                    ForEach(availableLevels, id: \.self) { level in
                        Text("\(level)").tag(level)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 60)
                
                Spacer()
                
                Text("Quality:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Picker("Quality", selection: $selectedQuality) {
                    ForEach(Quality.allCases, id: \.self) { quality in
                        HStack {
                            Circle()
                                .fill(quality.color)
                                .frame(width: 8, height: 8)
                            Text(quality.rawValue)
                        }
                        .tag(quality)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
            }
            
            // Module preview
            if let selectedModule = currentModule {
                ModulePreview(module: selectedModule)
            }
            
            Spacer()
            
            // Action buttons
            HStack {
                Button("Remove Module") {
                    removeModule()
                }
                .disabled(slotIndex >= node.modules.count || node.modules[slotIndex] == nil)
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Install Module") {
                    if let module = currentModule {
                        installModule(module)
                    }
                }
                .disabled(!canInstallCurrentModule)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400, height: 380) // Slightly taller to accommodate warning
        .onAppear {
            // Load current module if exists
            if slotIndex < node.modules.count, let currentMod = node.modules[slotIndex] {
                selectedType = currentMod.type
                selectedLevel = currentMod.level
                selectedQuality = currentMod.quality
            }
        }
    }
    
    private var availableLevels: [Int] {
        let levels = MODULES
            .filter { $0.type == selectedType }
            .map { $0.level }
        return Array(Set(levels)).sorted()
    }
    
    private var currentModule: Module? {
        return MODULES.first { module in
            module.type == selectedType &&
            module.level == selectedLevel &&
            module.quality == selectedQuality
        }
    }
    
    private var canInstallCurrentModule: Bool {
        guard let module = currentModule,
              let recipe = nodeRecipe else {
            return false
        }
        return canUseModule(module, forRecipe: recipe)
    }
    
    private func installModule(_ module: Module) {
        guard let recipe = nodeRecipe,
              canUseModule(module, forRecipe: recipe) else {
            return
        }
        
        var updatedNode = node
        
        // Ensure modules array is large enough
        while updatedNode.modules.count <= slotIndex {
            updatedNode.modules.append(nil)
        }
        
        updatedNode.modules[slotIndex] = module
        graph.updateNode(updatedNode)
        dismiss()
    }
    
    private func removeModule() {
        var updatedNode = node
        if slotIndex < updatedNode.modules.count {
            updatedNode.modules[slotIndex] = nil
        }
        graph.updateNode(updatedNode)
        dismiss()
    }
}


struct ModulePreview: View {
    var module: Module
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ModuleIcon(module: module, size: 24)
                VStack(alignment: .leading) {
                    Text(module.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("\(module.quality.rawValue) Quality")
                        .font(.caption)
                        .foregroundStyle(module.quality.color)
                }
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                if module.speedBonus != 0 {
                    StatRow(label: "Speed", value: module.speedBonus)
                }
                if module.productivityBonus != 0 {
                    StatRow(label: "Productivity", value: module.productivityBonus)
                }
                if module.efficiencyBonus != 0 {
                    StatRow(label: "Efficiency", value: module.efficiencyBonus)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatRow: View {
    var label: String
    var value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(formatValue(value))
                .font(.caption)
                .foregroundStyle(value >= 0 ? .green : .red)
                .monospacedDigit()
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        let percentage = value * 100
        let sign = percentage >= 0 ? "+" : ""
        return String(format: "\(sign)%.1f%%", percentage)
    }
}
