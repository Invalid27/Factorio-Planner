// MARK: - Selection Overlay
struct SelectionOverlay: View {
    @EnvironmentObject var graph: GraphState
    
    var body: some View {
        GeometryReader { geometry in
            if let rect = graph.selectionRect {
                Rectangle()
                    .fill(Color.orange.opacity(0.1))
                    .overlay(
                        Rectangle()
                            .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                            .background(
                                Rectangle()
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                    )
                    .frame(width: abs(rect.width), height: abs(rect.height))
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .allowsHitTesting(false)
    }
}
