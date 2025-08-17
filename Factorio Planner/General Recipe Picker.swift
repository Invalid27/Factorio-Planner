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
