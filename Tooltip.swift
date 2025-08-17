// MARK: - Tooltip
extension View {
    func hoverTooltip(_ text: String) -> some View {
        modifier(HoverTooltip(text: text))
    }
}

struct HoverTooltip: ViewModifier {
    var text: String
    @State private var hovering = false
    
    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                hovering = isHovering
            }
            .overlay(alignment: .top) {
                if hovering {
                    Tooltip(text: text)
                        .fixedSize(horizontal: true, vertical: true)
                        .offset(y: -26)
                        .zIndex(999)
                        .allowsHitTesting(false)
                }
            }
            .animation(.easeInOut(duration: 0.12), value: hovering)
    }
}

struct Tooltip: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.ultraThinMaterial)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.15))
            )
    }
}
