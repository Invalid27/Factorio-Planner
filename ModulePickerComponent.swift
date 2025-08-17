// MARK: - Fixed Module Picker Component

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
        .frame(width: 400, height: 380)
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
        
        // FIXED: Use graph's updateNode method
        graph.updateNode(updatedNode)
        dismiss()
    }
    
    private func removeModule() {
        var updatedNode = node
        if slotIndex < updatedNode.modules.count {
            updatedNode.modules[slotIndex] = nil
        }
        
        // FIXED: Use graph's updateNode method
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
