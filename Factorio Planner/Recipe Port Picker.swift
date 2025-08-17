// MARK: - Updated Recipe Picker (for port connections) with Arrow Key Navigation

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
