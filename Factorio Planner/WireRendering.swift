// MARK: - Wire Rendering
struct WiresLayer: View {
    @EnvironmentObject var graph: GraphState
    var portFrames: [PortKey: CGRect]
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                for edge in graph.edges {
                    let outputPortKey = PortKey(nodeID: edge.fromNode, item: edge.item, side: .output)
                    let inputPortKey = PortKey(nodeID: edge.toNode, item: edge.item, side: .input)
                    
                    guard let fromRect = portFrames[outputPortKey],
                          let toRect = portFrames[inputPortKey] else {
                        continue
                    }
                    
                    let startPoint = CGPoint(x: fromRect.midX, y: fromRect.midY)
                    let endPoint = CGPoint(x: toRect.midX, y: toRect.midY)
                    let path = createCubicPath(from: startPoint, to: endPoint)
                    
                    context.stroke(
                        path,
                        with: .color(.orange.opacity(0.9)),
                        lineWidth: Constants.wireLineWidth
                    )
                }
            }
            .allowsHitTesting(false)
            
            ForEach(graph.edges, id: \.id) { edge in
                WireFlowLabel(edge: edge, portFrames: portFrames)
            }
        }
    }
}

struct WireFlowLabel: View {
    @EnvironmentObject var graph: GraphState
    var edge: Edge
    var portFrames: [PortKey: CGRect]
    
    var body: some View {
        let outputPortKey = PortKey(nodeID: edge.fromNode, item: edge.item, side: .output)
        let inputPortKey = PortKey(nodeID: edge.toNode, item: edge.item, side: .input)
        
        guard let fromRect = portFrames[outputPortKey],
              let toRect = portFrames[inputPortKey],
              let consumerNode = graph.nodes[edge.toNode],
              let consumerRecipe = RECIPES.first(where: { $0.id == consumerNode.recipeID }),
              let targetPerMin = consumerNode.targetPerMin,
              targetPerMin > 0 else {
            return AnyView(EmptyView())
        }
        
        let outputAmount = consumerRecipe.outputs.values.first ?? 1
        let actualOutput = outputAmount * (1 + consumerNode.totalProductivityBonus)
        let craftsPerMin = targetPerMin / actualOutput
        let inputAmount = consumerRecipe.inputs[edge.item] ?? 0
        let flowRate = craftsPerMin * inputAmount
        
        let startPoint = CGPoint(x: fromRect.midX, y: fromRect.midY)
        let endPoint = CGPoint(x: toRect.midX, y: toRect.midY)
        let midPoint = CGPoint(
            x: (startPoint.x + endPoint.x) / 2,
            y: (startPoint.y + endPoint.y) / 2
        )
        
        let flowText: String
        if flowRate == floor(flowRate) {
            flowText = String(format: "%.0f", flowRate)
        } else {
            flowText = String(format: "%.1f", flowRate)
        }
        
        return AnyView(
            Text(flowText)
                .font(.body)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.orange.opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.orange.opacity(0.6))
                )
                .position(midPoint)
                .allowsHitTesting(false)
        )
    }
}

struct WireTempPath: View {
    var from: CGPoint
    var to: CGPoint
    
    var body: some View {
        Canvas { context, size in
            let path = createCubicPath(from: from, to: to)
            let dashedPath = path.strokedPath(.init(lineWidth: Constants.wireLineWidth, dash: [6, 6]))
            
            context.stroke(
                dashedPath,
                with: .color(.blue.opacity(0.8))
            )
        }
        .allowsHitTesting(false)
    }
}

func createCubicPath(from startPoint: CGPoint, to endPoint: CGPoint) -> Path {
    var path = Path()
    let deltaX = max(abs(endPoint.x - startPoint.x) * 0.5, Constants.curveTension)
    
    path.move(to: startPoint)
    path.addCurve(
        to: endPoint,
        control1: CGPoint(x: startPoint.x + deltaX, y: startPoint.y),
        control2: CGPoint(x: endPoint.x - deltaX, y: endPoint.y)
    )
    return path
}
