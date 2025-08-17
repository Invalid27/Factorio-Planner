// MARK: - Scroll Wheel Handler
struct ScrollWheelHandler: NSViewRepresentable {
    let onScroll: (CGFloat, CGPoint) -> Void
    
    func makeNSView(context: Context) -> ScrollWheelNSView {
        let view = ScrollWheelNSView()
        view.onScroll = onScroll
        return view
    }
    
    func updateNSView(_ nsView: ScrollWheelNSView, context: Context) {}
    
    class ScrollWheelNSView: NSView {
        var onScroll: ((CGFloat, CGPoint) -> Void)?
        
        override var acceptsFirstResponder: Bool { true }
        
        override func scrollWheel(with event: NSEvent) {
            let location = convert(event.locationInWindow, from: nil)
            let flippedLocation = CGPoint(x: location.x, y: bounds.height - location.y)
            
            // Use precise scrolling delta if available, otherwise use regular delta
            let delta = event.hasPreciseScrollingDeltas ? event.scrollingDeltaY : event.deltaY * 10
            
            onScroll?(delta, flippedLocation)
        }
        
        // Don't consume hit tests - just handle scroll events
        override func hitTest(_ point: NSPoint) -> NSView? {
            return nil
        }
    }
}

