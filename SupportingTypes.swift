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
                    graph.cutNodes()
                }
                .keyboardShortcut("x", modifiers: [.command])
                .disabled(graph.selectedNodeIDs.isEmpty)
                
                Button("Copy") {
                    graph.copyNodes()
                }
                .keyboardShortcut("c", modifiers: [.command])
                .disabled(graph.selectedNodeIDs.isEmpty)
                
                Button("Paste") {
                    graph.pasteNodes()
                }
                .keyboardShortcut("v", modifiers: [.command])
                .disabled(graph.clipboard.isEmpty)
                
                Divider()
                
                Button("Delete") {
                    graph.deleteSelectedNodes()
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(graph.selectedNodeIDs.isEmpty)
                
                Button("Select All") {
                    graph.selectedNodeIDs = Set(graph.nodes.keys)
                }
                .keyboardShortcut("a", modifiers: [.command])
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
} // FIXED: Added missing closing brace
