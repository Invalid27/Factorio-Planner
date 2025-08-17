// FactorioPlannerApp.swift
// FIXED: Using correct method names that match your GraphState extensions

import SwiftUI

@main  // This tells Swift "start the app here"
struct FactorioPlannerApp: App {
    // Create the main state objects
    @StateObject private var graph = GraphState()
    @StateObject private var machinePreferences = MachinePreferences.load()
    
    var body: some Scene {
        WindowGroup {
            // This is your main view
            PlannerRoot()
                .environmentObject(graph)  // Makes graph available to all child views
                .environmentObject(machinePreferences)  // Makes preferences available too
                .frame(minWidth: 1200, minHeight: 800)
                .preferredColorScheme(.dark)  // Optional: default to dark mode
        }
        .windowResizability(.contentSize)
        .commands {
            // File Menu Commands
            CommandGroup(replacing: .newItem) {
                Button("New") {
                    graph.clearGraph()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(replacing: .saveItem) {
                Button("Save...") {
                    graph.saveToFile()
                }
                .keyboardShortcut("s", modifiers: .command)
                
                Button("Quick Save") {
                    graph.quickSave()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            
            CommandGroup(after: .saveItem) {
                Button("Open...") {
                    graph.loadFromFile()
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Quick Load") {
                    graph.quickLoad()
                }
                .keyboardShortcut("l", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Import...") {
                    graph.importGraph()
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("Export...") {
                    graph.exportGraph()
                }
                .keyboardShortcut("e", modifiers: .command)
                
                Button("Import and Merge...") {
                    graph.importAndMerge()
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
                
                Button("Export Selected...") {
                    graph.exportSelectedNodes()
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
            
            // Edit Menu Commands
            CommandMenu("Edit") {
                Button("Undo") {
                    // TODO: Implement undo
                }
                .keyboardShortcut("z", modifiers: .command)
                .disabled(true)  // Disabled until implemented
                
                Button("Redo") {
                    // TODO: Implement redo
                }
                .keyboardShortcut("z", modifiers: [.command, .shift])
                .disabled(true)  // Disabled until implemented
                
                Divider()
                
                Button("Cut") {
                    graph.cutSelectedNodes()  // FIXED: correct method name
                }
                .keyboardShortcut("x", modifiers: .command)
                .disabled(graph.selectedNodeIDs.isEmpty)
                
                Button("Copy") {
                    graph.copySelectedNodes()  // FIXED: correct method name
                }
                .keyboardShortcut("c", modifiers: .command)
                .disabled(graph.selectedNodeIDs.isEmpty)
                
                Button("Paste") {
                    graph.pasteNodes(at: graph.lastMousePosition)  // This is correct
                }
                .keyboardShortcut("v", modifiers: .command)
                .disabled(!graph.canPaste())
                
                Divider()
                
                Button("Select All") {
                    graph.selectAll()
                }
                .keyboardShortcut("a", modifiers: .command)
                
                Button("Deselect All") {
                    graph.deselectAll()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Delete Selected") {
                    graph.deleteSelectedNodes()
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(graph.selectedNodeIDs.isEmpty)
                
                Button("Duplicate Selected") {
                    graph.duplicateSelectedNodes()
                }
                .keyboardShortcut("d", modifiers: .command)
                .disabled(graph.selectedNodeIDs.isEmpty)
            }
            
            // View Menu
            CommandMenu("View") {
                Button("Reset Zoom") {
                    withAnimation {
                        graph.canvasScale = 1.0
                        graph.canvasOffset = .zero
                    }
                }
                .keyboardShortcut("0", modifiers: .command)
                
                Button("Zoom In") {
                    withAnimation {
                        graph.canvasScale = min(3.0, graph.canvasScale + 0.2)
                    }
                }
                .keyboardShortcut("+", modifiers: .command)
                
                Button("Zoom Out") {
                    withAnimation {
                        graph.canvasScale = max(0.3, graph.canvasScale - 0.2)
                    }
                }
                .keyboardShortcut("-", modifiers: .command)
                
                Divider()
                
                Picker("Aggregate Mode", selection: $graph.aggregate) {
                    ForEach(GraphState.Aggregate.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
            }
            
            // Production Menu
            CommandMenu("Production") {
                Button("Auto-Balance All") {
                    graph.autoBalance()
                }
                .keyboardShortcut("b", modifiers: .command)
                
                Button("Clear All Targets") {
                    for nodeID in graph.nodes.keys {
                        graph.updateNodeTarget(nodeID, target: nil)
                    }
                }
                
                Divider()
                
                Button("Compute Flows") {
                    graph.computeFlows()
                }
                .keyboardShortcut("r", modifiers: .command)
            }
            
            // Help Menu
            CommandGroup(replacing: .help) {
                Button("Keyboard Shortcuts") {
                    // TODO: Show shortcuts window
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
    }
}
