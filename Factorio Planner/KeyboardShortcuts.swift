// Add to your project as KeyboardShortcuts.swift

import SwiftUI

struct KeyboardShortcutsView: View {
    @Environment(\.dismiss) var dismiss
    
    let shortcuts = [
        ShortcutCategory(name: "Navigation", shortcuts: [
            Shortcut(key: "Option + Drag", description: "Pan canvas"),
            Shortcut(key: "Scroll", description: "Zoom in/out at cursor"),
            Shortcut(key: "+/-", description: "Zoom in/out at center"),
            Shortcut(key: "0", description: "Reset zoom and center"),
            Shortcut(key: "Space", description: "Pan mode (hold)")
        ]),
        ShortcutCategory(name: "Selection", shortcuts: [
            Shortcut(key: "Click", description: "Select node"),
            Shortcut(key: "Cmd + Click", description: "Add to selection"),
            Shortcut(key: "Drag", description: "Rectangle select"),
            Shortcut(key: "Cmd + A", description: "Select all"),
            Shortcut(key: "Escape", description: "Deselect all")
        ]),
        ShortcutCategory(name: "Editing", shortcuts: [
            Shortcut(key: "Delete", description: "Delete selected"),
            Shortcut(key: "Cmd + C", description: "Copy selected"),
            Shortcut(key: "Cmd + X", description: "Cut selected"),
            Shortcut(key: "Cmd + V", description: "Paste"),
            Shortcut(key: "Cmd + D", description: "Duplicate selected"),
            Shortcut(key: "Cmd + Z", description: "Undo"),
            Shortcut(key: "Cmd + Shift + Z", description: "Redo")
        ]),
        ShortcutCategory(name: "Nodes", shortcuts: [
            Shortcut(key: "Right Click", description: "Add new node"),
            Shortcut(key: "Drag Port", description: "Connect nodes"),
            Shortcut(key: "Double Click", description: "Edit node properties"),
            Shortcut(key: "M", description: "Open module selector"),
            Shortcut(key: "T", description: "Set target production")
        ]),
        ShortcutCategory(name: "File", shortcuts: [
            Shortcut(key: "Cmd + S", description: "Save"),
            Shortcut(key: "Cmd + O", description: "Open"),
            Shortcut(key: "Cmd + N", description: "New"),
            Shortcut(key: "Cmd + E", description: "Export"),
            Shortcut(key: "Cmd + I", description: "Import")
        ])
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Shortcuts list
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(shortcuts) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            VStack(spacing: 8) {
                                ForEach(category.shortcuts) { shortcut in
                                    HStack {
                                        Text(shortcut.key)
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.blue)
                                            .frame(width: 180, alignment: .leading)
                                        
                                        Text(shortcut.description)
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        if category.id != shortcuts.last?.id {
                            Divider()
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(width: 600, height: 700)
        .background(.regularMaterial)
    }
}

struct ShortcutCategory: Identifiable {
    let id = UUID()
    let name: String
    let shortcuts: [Shortcut]
}

struct Shortcut: Identifiable {
    let id = UUID()
    let key: String
    let description: String
}

// Extension to handle keyboard shortcuts in GraphState
extension GraphState {
    func handleKeyboardShortcut(_ key: KeyPress.Key, modifiers: EventModifiers) -> KeyPress.Result {
        // File operations
        if modifiers.contains(.command) {
            switch key {
            case "s":
                saveToFile()
                return .handled
            case "o":
                loadFromFile()
                return .handled
            case "n":
                clearGraph()
                return .handled
            case "e":
                exportGraph()
                return .handled
            case "i":
                importGraph()
                return .handled
            case "z":
                if modifiers.contains(.shift) {
                    redo()
                } else {
                    undo()
                }
                return .handled
            case "c":
                copySelectedNodes()
                return .handled
            case "x":
                cutSelectedNodes()
                return .handled
            case "v":
                pasteNodes(at: lastMousePosition)
                return .handled
            case "d":
                duplicateSelectedNodes()
                return .handled
            case "a":
                selectAll()
                return .handled
            default:
                break
            }
        }
        
        // Single key shortcuts
        switch key {
        case .delete:
            deleteSelectedNodes()
            return .handled
        case .escape:
            selectedNodeIDs.removeAll()
            return .handled
        case "m":
            if selectedNodeIDs.count == 1 {
                // Open module selector for selected node
                // You'd need to add this functionality
            }
            return .handled
        case "t":
            if selectedNodeIDs.count == 1 {
                // Open target setter for selected node
                // You'd need to add this functionality
            }
            return .handled
        default:
            return .ignored
        }
    }
    
    private func selectAll() {
        selectedNodeIDs = Set(nodes.keys)
    }
    
    private func duplicateSelectedNodes() {
        var newNodes: [Node] = []
        let offset: CGFloat = 50
        
        for nodeID in selectedNodeIDs {
            guard var node = nodes[nodeID] else { continue }
            node.id = UUID()
            node.x += offset
            node.y += offset
            newNodes.append(node)
            nodes[node.id] = node
        }
        
        // Update selection to new nodes
        selectedNodeIDs = Set(newNodes.map { $0.id })
    }
    
    private func clearGraph() {
        nodes.removeAll()
        edges.removeAll()
        selectedNodeIDs.removeAll()
    }
    
    // Stub functions for undo/redo - you'd need to implement these
    private func undo() {
        // Implement undo functionality
    }
    
    private func redo() {
        // Implement redo functionality
    }
}
