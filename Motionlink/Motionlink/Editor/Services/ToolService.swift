import Combine
import Foundation
import SwiftUI

typealias ToolSelectionHandler = (EngineTools) -> Void

class ToolService {
    static let shared = ToolService()
    private(set) var tools: [ApplicationTool] = []

    let toolChanged = PassthroughSubject<ApplicationTool?, Never>()
    let modeChanged = PassthroughSubject<ApplicationMode, Never>()
    let layersVisibilityChanged = PassthroughSubject<Bool, Never>()

    private var toolSelectionHandler: ToolSelectionHandler?

    private init() {
        registerDefaultTools()
    }

    func setToolSelectionHandler(_ handler: @escaping ToolSelectionHandler) {
        toolSelectionHandler = handler
    }

    func registerTool(_ tool: ApplicationTool) {
        if !tools.contains(where: { $0.name == tool.name }) {
            tools.append(tool)
        }
    }

    func selectTool(_ tool: ApplicationTool) {
        if let handler = toolSelectionHandler {
            handler(tool.engineTool)
        } else {
            print("Warning: ToolService - Tool selection handler not set.")
        }
    }

    func toolsForMode(_ mode: ApplicationMode) -> [ApplicationTool] {
        return tools.filter { $0.supportedModes.contains(mode) }
    }

    func findTool(byName name: String) -> ApplicationTool? {
        return tools.first { $0.name == name }
    }

    func findEngineTool(byName name: String) -> EngineTools? {
        findTool(byName: name)?.engineTool
    }

    private func registerDefaultTools() {
        // Primary tools
        registerTool(
            ApplicationTool(
                name: "Control", icon: "move.3d", group: .manipulation, engineTool: .control,
                supportedModes: [.object, .bone]))
        registerTool(
            ApplicationTool(
                name: "Select", icon: "lasso", group: .selection, engineTool: .select,
                supportedModes: [.object, .bone]))

        // Creation tools
        registerTool(
            ApplicationTool(
                name: "Add", icon: "plus.square", group: .creation, engineTool: .add,
                supportedModes: [.object]))

        // Manipulation tools
        registerTool(
            ApplicationTool(
                name: "Transform", icon: "arrow.up.and.down.and.arrow.left.and.right",
                group: .manipulation, engineTool: .transform, supportedModes: [.object, .bone]))
        registerTool(
            ApplicationTool(
                name: "Extrude", icon: "arrow.up.square", group: .manipulation,
                engineTool: .extrude, supportedModes: [.object]))
        registerTool(
            ApplicationTool(
                name: "Cut", icon: "scissors", group: .manipulation, engineTool: .cut,
                supportedModes: [.object]))
        registerTool(
            ApplicationTool(
                name: "Fillet", icon: "cursorarrow.rays", group: .manipulation, engineTool: .fillet,
                supportedModes: [.object]))

        // Utility tools
        registerTool(
            ApplicationTool(
                name: "Align", icon: "align.horizontal.left", group: .manipulation,
                engineTool: .align, supportedModes: [.object]))
        registerTool(
            ApplicationTool(
                name: "Pattern", icon: "square.grid.3x3", group: .creation, engineTool: .pattern,
                supportedModes: [.object]))
        registerTool(
            ApplicationTool(
                name: "Measure", icon: "ruler", group: .selection, engineTool: .measure,
                supportedModes: [.object]))

        // Mode-specific tools
        registerTool(
            ApplicationTool(
                name: "Scan Area", icon: "viewfinder", group: .creation, engineTool: .none,
                supportedModes: [.scan]))
        registerTool(
            ApplicationTool(
                name: "Create Bone", icon: "link.badge.plus", group: .creation, engineTool: .none,
                supportedModes: [.bone]))
        registerTool(
            ApplicationTool(
                name: "Edit Weights", icon: "paintbrush.pointed.fill", group: .manipulation,
                engineTool: .none, supportedModes: [.bone]))
    }

}
