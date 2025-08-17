// Manual Save-Load.swift
import Foundation
import AppKit
import UniformTypeIdentifiers

extension GraphState {
    // MARK: - Manual Save/Load
    
    func saveToFile() {
        let savePanel = NSSavePanel()
        savePanel.title = "Save Factorio Plan"
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "FactorioPlan.json"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    let data = try encoder.encode(self)
                    try data.write(to: url)
                    print("Saved graph to \(url.path)")
                    self.showSaveSuccess(url: url)
                } catch {
                    print("Failed to save: \(error)")
                    self.showSaveError(error)
                }
            }
        }
    }
    
    func loadFromFile() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Load Factorio Plan"
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        
        openPanel.begin { response in
            if response == .OK, let url = openPanel.url {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let loadedState = try decoder.decode(GraphState.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.nodes = loadedState.nodes
                        self.edges = loadedState.edges
                        self.selectedNodeIDs.removeAll()
                        self.computeFlows()
                        print("Loaded graph from \(url.path)")
                        self.showLoadSuccess(url: url)
                    }
                } catch {
                    print("Failed to load: \(error)")
                    self.showLoadError(error)
                }
            }
        }
    }
    
    func quickSave() {
        // Save to a default location in Documents
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                         in: .userDomainMask).first else {
            print("Could not find Documents directory")
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent("FactorioPlannerQuickSave.json")
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            try data.write(to: fileURL)
            print("Quick saved to \(fileURL.path)")
            showQuickSaveSuccess()
        } catch {
            print("Quick save failed: \(error)")
            showSaveError(error)
        }
    }
    
    func quickLoad() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                         in: .userDomainMask).first else {
            print("Could not find Documents directory")
            return
        }
        
        let fileURL = documentsURL.appendingPathComponent("FactorioPlannerQuickSave.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let loadedState = try decoder.decode(GraphState.self, from: data)
            
            DispatchQueue.main.async {
                self.nodes = loadedState.nodes
                self.edges = loadedState.edges
                self.selectedNodeIDs.removeAll()
                self.computeFlows()
                print("Quick loaded from \(fileURL.path)")
                self.showQuickLoadSuccess()
            }
        } catch {
            print("Quick load failed: \(error)")
            if (error as NSError).code == NSFileReadNoSuchFileError {
                showNoQuickSaveError()
            } else {
                showLoadError(error)
            }
        }
    }
    
    // MARK: - User Feedback
    
    private func showSaveSuccess(url: URL) {
        // You could show a toast notification here
        print("✅ Saved successfully to \(url.lastPathComponent)")
    }
    
    private func showLoadSuccess(url: URL) {
        print("✅ Loaded successfully from \(url.lastPathComponent)")
    }
    
    private func showQuickSaveSuccess() {
        print("✅ Quick save successful")
    }
    
    private func showQuickLoadSuccess() {
        print("✅ Quick load successful")
    }
    
    private func showSaveError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Save Failed"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func showLoadError(_ error: Error) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Load Failed"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func showNoQuickSaveError() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "No Quick Save Found"
            alert.informativeText = "You haven't created a quick save yet. Use Cmd+S to create one."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
