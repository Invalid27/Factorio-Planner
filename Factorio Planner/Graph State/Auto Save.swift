// Auto Save.swift
import Foundation

extension GraphState {
    // MARK: - FIXED Auto-Save System
    
    func scheduleAutoSave() {
        // Cancel any pending save
        saveTimer?.invalidate()
        
        // Schedule a new save after a delay (debouncing)
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.performSave()
        }
    }
    
    private func performSave() {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let data = try JSONEncoder().encode(self)
                DispatchQueue.main.async {
                    UserDefaults.standard.set(data, forKey: "FactorioPlannerAutoSave")
                    print("Auto-saved graph with \(self.nodes.count) nodes and \(self.edges.count) edges")
                }
            } catch {
                DispatchQueue.main.async {
                    print("Failed to auto-save: \(error)")
                }
            }
        }
    }
    
    func loadAutoSave() {
        guard let data = UserDefaults.standard.data(forKey: "FactorioPlannerAutoSave") else {
            print("No auto-save found, starting fresh")
            return
        }
        
        do {
            let savedState = try JSONDecoder().decode(GraphState.self, from: data)
            self.nodes = savedState.nodes
            self.edges = savedState.edges
            print("Loaded auto-save with \(nodes.count) nodes and \(edges.count) edges")
            
            // FIXED: Compute flows after a brief delay to let UI settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.computeFlows()
            }
        } catch {
            print("Failed to load auto-save: \(error)")
        }
    }
    
    func savePreferences() {
        UserDefaults.standard.set(aggregate.rawValue, forKey: "FactorioPlannerAggregate")
    }
    
    func loadPreferences() {
        if let aggregateRaw = UserDefaults.standard.string(forKey: "FactorioPlannerAggregate"),
           let loadedAggregate = Aggregate(rawValue: aggregateRaw) {
            self.aggregate = loadedAggregate
        }
    }
}
