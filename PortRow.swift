// MARK: - Fixed Port Row with Transform-Aware Position
struct PortRow: View {
    @EnvironmentObject var graph: GraphState
    var nodeID: UUID
    var side: IOSide
    var item: String
    var amount: Double
    
    @State private var centerInCanvas: CGPoint = .zero
    
    private var flowRate: Double {
        guard let node = graph.nodes[nodeID],
              let targetPerMin = node.targetPerMin,
              let recipe = RECIPES.first(where: { $0.id == node.recipeID }) else {
            return 0
        }
        
        if side == .output {
            let totalOutput = recipe.outputs.values.reduce(0, +)
            let actualOutput = totalOutput * (1 + node.totalProductivityBonus)
            let thisOutputRatio = amount / totalOutput
            return targetPerMin * thisOutputRatio * (1 + node.totalProductivityBonus)
        } else {
            let outputAmount = recipe.outputs.values.first ?? 1
            let actualOutput = outputAmount * (1 + node.totalProductivityBonus)
            let craftsPerMin = targetPerMin / actualOutput
            return craftsPerMin * amount
        }
    }
    
    private var flowRateText: String {
        if flowRate == 0 {
            return "×\(amount.formatted())"
        } else if flowRate == floor(flowRate) {
            return String(format: "%.0f", flowRate)
        } else {
            return String(format: "%.1f", flowRate)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if side == .input {
                portContent
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                portContent
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    @ViewBuilder
    private var portContent: some View {
        HStack(spacing: 4) {
            if side == .input {
                HStack(spacing: 4) {
                    IconOrMonogram(item: item, size: 16)
                        .hoverTooltip(item)
                    
                    Text(flowRateText)
                        .foregroundStyle(flowRate > 0 ? .primary : .secondary)
                        .font(.caption2)
                        .monospacedDigit()
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(1)
                }
            } else {
                HStack(spacing: 4) {
                    Text(flowRateText)
                        .foregroundStyle(flowRate > 0 ? .primary : .secondary)
                        .font(.caption2)
                        .monospacedDigit()
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(1)
                    
                    IconOrMonogram(item: item, size: 16)
                        .hoverTooltip(item)
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .frame(minWidth: 0)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isPortConnected(nodeID: nodeID, item: item, side: side, edges: graph.edges)
                      ? Color.clear
                      : Color.orange.opacity(0.3))
                .animation(.easeInOut(duration: 0.2), value: isPortConnected(nodeID: nodeID, item: item, side: side, edges: graph.edges))
        )
        .background(
            GeometryReader { geometry in
                let frame = geometry.frame(in: .named("canvas"))
                Color.clear
                    .onAppear {
                        updatePortFrame(frame)
                    }
                    .onChange(of: frame) { _, newFrame in
                        updatePortFrame(newFrame)
                    }
                // Also update when zoom/pan changes
                    .onChange(of: graph.canvasScale) { _, _ in
                        let currentFrame = geometry.frame(in: .named("canvas"))
                        updatePortFrame(currentFrame)
                    }
                    .onChange(of: graph.canvasOffset) { _, _ in
                        let currentFrame = geometry.frame(in: .named("canvas"))
                        updatePortFrame(currentFrame)
                    }
                    .preference(
                        key: PortFramesKey.self,
                        value: [PortFrame(key: PortKey(nodeID: nodeID, item: item, side: side), frame: frame)]
                    )
            }
        )
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { _ in
                    handleDragEnd()
                }
        )
    }
    
    private func updatePortFrame(_ frame: CGRect) {
        // Transform the frame to account for canvas scale and offset
        let transformedFrame = CGRect(
            x: frame.origin.x * graph.canvasScale + graph.canvasOffset.width,
            y: frame.origin.y * graph.canvasScale + graph.canvasOffset.height,
            width: frame.width * graph.canvasScale,
            height: frame.height * graph.canvasScale
        )
        
        centerInCanvas = CGPoint(
            x: transformedFrame.midX,
            y: transformedFrame.midY
        )
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        // Transform drag coordinates to canvas space
        let startPoint = CGPoint(
            x: (centerInCanvas.x - graph.canvasOffset.width) / graph.canvasScale,
            y: (centerInCanvas.y - graph.canvasOffset.height) / graph.canvasScale
        )
        
        let currentPoint = CGPoint(
            x: startPoint.x + value.translation.width / graph.canvasScale,
            y: startPoint.y + value.translation.height / graph.canvasScale
        )
        
        // Now transform back to screen space for drawing
        let screenStart = CGPoint(
            x: startPoint.x * graph.canvasScale + graph.canvasOffset.width,
            y: startPoint.y * graph.canvasScale + graph.canvasOffset.height
        )
        
        let screenCurrent = CGPoint(
            x: currentPoint.x * graph.canvasScale + graph.canvasOffset.width,
            y: currentPoint.y * graph.canvasScale + graph.canvasOffset.height
        )
        
        if graph.dragging == nil {
            graph.dragging = DragContext(
                fromPort: PortKey(nodeID: nodeID, item: item, side: side),
                startPoint: screenStart,
                currentPoint: screenCurrent
            )
        } else {
            graph.dragging?.currentPoint = screenCurrent
        }
    }
    
    private func handleDragEnd() {
        guard let dragContext = graph.dragging else { return }
        
        let currentPoint = dragContext.currentPoint
        let oppositeSide = side.opposite
        
        // Transform the current point to check against port frames
        let hitPort = graph.portFrames.first { portKey, rect in
            // Transform rect to screen space
            let screenRect = CGRect(
                x: rect.origin.x * graph.canvasScale + graph.canvasOffset.width,
                y: rect.origin.y * graph.canvasScale + graph.canvasOffset.height,
                width: rect.width * graph.canvasScale,
                height: rect.height * graph.canvasScale
            )
            
            return portKey.item == item &&
            portKey.side == oppositeSide &&
            screenRect.insetBy(dx: -8, dy: -8).contains(currentPoint)
        }?.key
        
        if let targetPort = hitPort {
            if side == .output {
                graph.addEdge(from: nodeID, to: targetPort.nodeID, item: item)
            } else {
                graph.addEdge(from: targetPort.nodeID, to: nodeID, item: item)
            }
        } else {
            // Convert drop point to canvas coordinates
            let canvasDropPoint = CGPoint(
                x: (currentPoint.x - graph.canvasOffset.width) / graph.canvasScale,
                y: (currentPoint.y - graph.canvasOffset.height) / graph.canvasScale
            )
            
            graph.pickerContext = PickerContext(
                fromPort: PortKey(nodeID: nodeID, item: item, side: side),
                dropPoint: canvasDropPoint
            )
            graph.showPicker = true
        }
        
        graph.dragging = nil
    }
}
