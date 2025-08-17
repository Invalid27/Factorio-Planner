// SupportingTypes.swift
// FIXED: Removed duplicate @main and FactorioPlannerApp declaration
import Foundation
import SwiftUI

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

// Add any other supporting types here that aren't defined elsewhere
