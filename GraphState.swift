// GraphState.swift
// CLEANED: Removed duplicate type definitions (they're in SupportingTypes.swift)
import Foundation
import SwiftUI

final class GraphState: ObservableObject, Codable {
    enum CodingKeys: CodingKey {
        case nodes, edges
    }
    
    enum Aggregate: String, CaseIterable {
        case max = "Max"
        case sum = "Sum"
    }
    
    // MARK: - Published Properties
    @Published var nodes: [UUID: Node] = [:] {
        didSet {
            scheduleAutoSave()
        }
    }
    
    @Published var edges: [Edge] = [] {
        didSet {
            scheduleAutoSave()
        }
    }
    
    // UI State - these should NOT trigger auto-save
    @Published var dragging: DragContext? = nil
    @Published var showPicker = false
    @Published var pickerContext: PickerContext? = nil
    @Published var showGeneralPicker = false
    @Published var generalPickerDropPoint: CGPoint = .zero
    @Published var portFrames: [PortKey: CGRect] = [:]
    @Published var lastMousePosition: CGPoint = CGPoint(x: 400, y: 300)
    
    // Selection and clipboard
    @Published var selectedNodeIDs: Set<UUID> = []
    @Published var clipboard: [Node] = []
    @Published var clipboardWasCut: Bool = false
    
    // Canvas controls
    @Published var canvasScale: CGFloat = 1.0
    @Published var canvasOffset: CGSize = .zero
    @Published var selectionRect: CGRect? = nil
    @Published var isSelecting: Bool = false
    
    // Aggregate mode
    @Published var aggregate: Aggregate = .max {
        didSet {
            savePreferences()
        }
    }
    
    // MARK: - Internal Properties
    internal var isComputing = false
    internal var pendingCompute = false
    internal var saveTimer: Timer?
    internal let saveQueue = DispatchQueue(label: "graphstate.save", qos: .utility)
    
    // MARK: - Initialization
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
}

// Note: DragContext, PickerContext, PortFrame, and PortFramesKey
// are defined in SupportingTypes.swift
