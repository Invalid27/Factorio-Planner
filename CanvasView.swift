// MARK: - Fixed Canvas View with Smooth Zoom and Scroll
struct CanvasView: View {
    @EnvironmentObject var graph: GraphState
    @State private var dragStart: CGPoint? = nil
    @State private var isDraggingCanvas = false
    @State private var backgroundDragStart: CGPoint? = nil
    @State private var initialCanvasOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Canvas content with zoom and pan
                ZStack {
                    GridBackground()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    
                    // Wires need to be transformed correctly
                    WiresLayer(portFrames: graph.portFrames)
                        .allowsHitTesting(false)
                    
                    if let dragContext = graph.dragging {
                        WireTempPath(from: dragContext.startPoint, to: dragContext.currentPoint)
                            .allowsHitTesting(false)
                    }
                    
                    // Nodes layer
                    ForEach(Array(graph.nodes.values), id: \.id) { node in
                        NodeCard(node: node)
                            .position(x: node.x, y: node.y)
                    }
                    
                    SelectionOverlay()
                        .allowsHitTesting(false)
                }
                .scaleEffect(graph.canvasScale, anchor: .center)
                .offset(graph.canvasOffset)
                
                // Invisible background for canvas interactions
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .zIndex(-1)
                    .gesture(
                        DragGesture(minimumDistance: 5)
                            .onChanged { value in
                                handleBackgroundDragChanged(value, in: geometry)
                            }
                            .onEnded { value in
                                handleBackgroundDragEnded(value, in: geometry)
                            }
                    )
                    .onTapGesture { location in
                        graph.selectedNodeIDs.removeAll()
                    }
                
                // Scroll wheel handler overlay
                ScrollWheelHandler { delta, location in
                    handleScrollWheel(delta: delta, location: location, in: geometry)
                }
                
                // Mouse tracking overlay
                MouseTracker { position in
                    // Convert mouse position to canvas coordinates accounting for zoom/pan
                    let canvasX = (position.x - graph.canvasOffset.width) / graph.canvasScale
                    let canvasY = (position.y - graph.canvasOffset.height) / graph.canvasScale
                    graph.lastMousePosition = CGPoint(x: canvasX, y: canvasY)
                } onRightClick: { position in
                    // Convert click position to canvas coordinates
                    let canvasX = (position.x - graph.canvasOffset.width) / graph.canvasScale
                    let canvasY = (position.y - graph.canvasOffset.height) / graph.canvasScale
                    graph.generalPickerDropPoint = CGPoint(x: canvasX, y: canvasY)
                    graph.showGeneralPicker = true
                }
            }
            .coordinateSpace(name: "canvas")
            .focusable()
            .onKeyPress { press in
                handleKeyPress(press)
            }
        }
    }
    
    private func handleScrollWheel(delta: CGFloat, location: CGPoint, in geometry: GeometryProxy) {
        // Get the mouse position in canvas space before zoom
        let canvasPointBeforeZoom = CGPoint(
            x: (location.x - graph.canvasOffset.width) / graph.canvasScale,
            y: (location.y - graph.canvasOffset.height) / graph.canvasScale
        )
        
        // Calculate new scale
        let scaleDelta = delta * 0.001 // Adjust sensitivity
        let oldScale = graph.canvasScale
        let newScale = min(3.0, max(0.3, oldScale + scaleDelta))
        
        // Calculate the offset needed to keep the mouse position stable
        let scaleRatio = newScale / oldScale
        let newOffsetX = location.x - canvasPointBeforeZoom.x * newScale
        let newOffsetY = location.y - canvasPointBeforeZoom.y * newScale
        
        // Apply with animation for smoothness
        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
            graph.canvasScale = newScale
            graph.canvasOffset = CGSize(width: newOffsetX, height: newOffsetY)
        }
    }
    
    private func handleBackgroundDragChanged(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        // Check if holding Option key for canvas pan
        if NSEvent.modifierFlags.contains(.option) {
            if !isDraggingCanvas {
                isDraggingCanvas = true
                initialCanvasOffset = graph.canvasOffset
            }
            
            // Update canvas offset
            graph.canvasOffset = CGSize(
                width: initialCanvasOffset.width + value.translation.width,
                height: initialCanvasOffset.height + value.translation.height
            )
        } else {
            // Selection rectangle
            if backgroundDragStart == nil {
                backgroundDragStart = value.startLocation
                graph.isSelecting = true
            }
            
            if let start = backgroundDragStart {
                let rect = CGRect(
                    x: min(start.x, value.location.x),
                    y: min(start.y, value.location.y),
                    width: abs(value.location.x - start.x),
                    height: abs(value.location.y - start.y)
                )
                graph.selectionRect = rect
            }
        }
    }
    
    private func handleBackgroundDragEnded(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        if isDraggingCanvas {
            isDraggingCanvas = false
            initialCanvasOffset = .zero
        } else if let rect = graph.selectionRect {
            // Convert selection rect to canvas coordinates considering zoom
            let scaledRect = CGRect(
                x: (rect.origin.x - graph.canvasOffset.width) / graph.canvasScale,
                y: (rect.origin.y - graph.canvasOffset.height) / graph.canvasScale,
                width: rect.width / graph.canvasScale,
                height: rect.height / graph.canvasScale
            )
            graph.selectNodes(in: scaledRect)
            graph.selectionRect = nil
        }
        
        backgroundDragStart = nil
        graph.isSelecting = false
    }
    
    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        switch press.key {
        case "=", "+":
            // Zoom in at center
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                let oldScale = graph.canvasScale
                let newScale = min(3.0, oldScale + 0.1)
                
                // Adjust offset to keep center point stable
                let scaleFactor = newScale / oldScale
                graph.canvasScale = newScale
                graph.canvasOffset = CGSize(
                    width: graph.canvasOffset.width * scaleFactor,
                    height: graph.canvasOffset.height * scaleFactor
                )
            }
            return .handled
            
        case "-":
            // Zoom out at center
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                let oldScale = graph.canvasScale
                let newScale = max(0.3, oldScale - 0.1)
                
                // Adjust offset to keep center point stable
                let scaleFactor = newScale / oldScale
                graph.canvasScale = newScale
                graph.canvasOffset = CGSize(
                    width: graph.canvasOffset.width * scaleFactor,
                    height: graph.canvasOffset.height * scaleFactor
                )
            }
            return .handled
            
        case "0":
            // Reset zoom and center
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                graph.canvasScale = 1.0
                graph.canvasOffset = .zero
            }
            return .handled
            
        case "a":
            // Select all (if cmd is pressed)
            if NSEvent.modifierFlags.contains(.command) {
                graph.selectedNodeIDs = Set(graph.nodes.keys)
                return .handled
            }
            return .ignored
            
        default:
            return .ignored
        }
    }
}
