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
