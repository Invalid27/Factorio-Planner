// MARK: - Fixed PlannerRoot with proper return type

struct PlannerRoot: View {
    @EnvironmentObject var graph: GraphState
    @State private var window: NSWindow?
    
    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            CanvasView()
        }
        .background(WindowAccessor(window: $window))
        .sheet(isPresented: $graph.showPicker) {
            if let context = graph.pickerContext {
                RecipePicker(context: context)
            }
        }
        .sheet(isPresented: $graph.showGeneralPicker) {
            GeneralRecipePicker()
        }
        .onPreferenceChange(PortFramesKey.self) { frames in
            var frameDict: [PortKey: CGRect] = [:]
            for portFrame in frames {
                frameDict[portFrame.key] = portFrame.frame
            }
            graph.portFrames = frameDict
        }
    }
}
