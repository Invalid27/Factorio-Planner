// MARK: - Simple Mouse Tracker
struct MouseTracker: NSViewRepresentable {
    let onMouseMove: (CGPoint) -> Void
    let onRightClick: (CGPoint) -> Void
    
    func makeNSView(context: Context) -> MouseTrackerView {
        let view = MouseTrackerView()
        view.onMouseMove = onMouseMove
        view.onRightClick = onRightClick
        return view
    }
    
    func updateNSView(_ nsView: MouseTrackerView, context: Context) {}
}

class MouseTrackerView: NSView {
    var onMouseMove: ((CGPoint) -> Void)?
    var onRightClick: ((CGPoint) -> Void)?
    private var trackingArea: NSTrackingArea?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .mouseMoved],
            owner: self,
            userInfo: nil
        )
        
        if let trackingArea = trackingArea {
            addTrackingArea(trackingArea)
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let flippedPoint = CGPoint(x: point.x, y: bounds.height - point.y)
        onMouseMove?(flippedPoint)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        let flippedPoint = CGPoint(x: point.x, y: bounds.height - point.y)
        onRightClick?(flippedPoint)
    }
    
    // CRITICAL: Don't consume any events - just track
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil // Never consume hits
    }
}


// FIXED: Advanced Mouse Tracking - make it non-blocking
struct AdvancedMouseTrackingView: NSViewRepresentable {
    let onMouseMove: (CGPoint) -> Void
    let onRightClick: (CGPoint) -> Void
    let onClick: (CGPoint) -> Void
    
    func makeNSView(context: Context) -> AdvancedMouseNSView {
        let view = AdvancedMouseNSView()
        view.onMouseMove = onMouseMove
        view.onRightClick = onRightClick
        view.onClick = onClick
        return view
    }
    
    func updateNSView(_ nsView: AdvancedMouseNSView, context: Context) {}
    
    class AdvancedMouseNSView: NSView {
        var onMouseMove: ((CGPoint) -> Void)?
        var onRightClick: ((CGPoint) -> Void)?
        var onClick: ((CGPoint) -> Void)?
        var trackingArea: NSTrackingArea?
        
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            
            if let trackingArea = trackingArea {
                removeTrackingArea(trackingArea)
            }
            
            let options: NSTrackingArea.Options = [
                .activeInKeyWindow,
                .mouseMoved,
                .mouseEnteredAndExited
            ]
            
            trackingArea = NSTrackingArea(
                rect: bounds,
                options: options,
                owner: self,
                userInfo: nil
            )
            
            if let trackingArea = trackingArea {
                addTrackingArea(trackingArea)
            }
        }
        
        override func mouseMoved(with event: NSEvent) {
            let locationInWindow = convert(event.locationInWindow, from: nil)
            let flippedLocation = CGPoint(x: locationInWindow.x, y: bounds.height - locationInWindow.y)
            onMouseMove?(flippedLocation)
        }
        
        // REMOVED: mouseDown handling to not interfere with SwiftUI gestures
        
        override func rightMouseDown(with event: NSEvent) {
            let locationInWindow = convert(event.locationInWindow, from: nil)
            let flippedLocation = CGPoint(x: locationInWindow.x, y: bounds.height - locationInWindow.y)
            onRightClick?(flippedLocation)
        }
        
        override var acceptsFirstResponder: Bool { true }
        override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
        
        // CRITICAL: Don't intercept hit testing
        override func hitTest(_ point: NSPoint) -> NSView? {
            // Only handle mouse tracking, don't consume clicks
            return nil
        }
    }
}

struct GridBackground: View {
    var body: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(white: 0.12), location: 0),
                        .init(color: Color(white: 0.10), location: 1)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 1
                )
            )
            .overlay(
                Canvas { context, size in
                    let dotPath = Path(CGRect(x: 0, y: 0, width: Constants.dotSize, height: Constants.dotSize))
                    
                    for x in stride(from: 25.0, through: size.width, by: Constants.gridSpacing) {
                        for y in stride(from: 25.0, through: size.height, by: Constants.gridSpacing) {
                            context.translateBy(x: x, y: y)
                            context.fill(dotPath, with: .color(Color.white.opacity(0.05)))
                            context.translateBy(x: -x, y: -y)
                        }
                    }
                }
            )
    }
}

struct DragReceiver: View {
    var body: some View {
        Color.clear
    }
}
