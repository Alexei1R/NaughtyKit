import Combine
import Foundation
import SwiftUI

class ToolViewModel: ObservableObject {
    @Published var selectedTool: ApplicationTool?
    @Published var currentMode: ApplicationMode = .object
    @Published var showLayers: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let toolService = ToolService.shared

    var availableTools: [ApplicationTool] {
        return toolService.toolsForMode(currentMode)
    }

    private var toolSelectionCallbacks: [(ApplicationTool?) -> Void] = []
    private var layersVisibilityCallbacks: [(Bool) -> Void] = []
    private var modeChangeCallbacks: [(ApplicationMode) -> Void] = []

    init(initialMode: ApplicationMode = .object, defaultToolName: String = "Control") {
        self.currentMode = initialMode
        if let defaultTool = toolService.toolsForMode(initialMode).first(where: { $0.name == defaultToolName }) ?? toolService.toolsForMode(initialMode).first {
            self.selectedTool = defaultTool
            toolService.selectTool(defaultTool)
        } else {
            self.selectedTool = nil
        }
        setupSubscribers()
    }

    func setupToolSelectionHandler(_ handler: @escaping ToolSelectionHandler) {
        toolService.setToolSelectionHandler(handler)
        if let tool = selectedTool {
            handler(tool.engineTool)
        }
    }

    func selectTool(_ tool: ApplicationTool) {
        selectedTool = tool
    }

    func setMode(_ mode: ApplicationMode) {
        guard currentMode != mode else { return }
        currentMode = mode

        if let currentSelectedTool = selectedTool, !currentSelectedTool.supportedModes.contains(mode) {
             if let firstAvailableTool = availableTools.first {
                 selectedTool = firstAvailableTool
             } else {
                 selectedTool = nil
             }
        } else if selectedTool == nil {
             selectedTool = availableTools.first
        }
    }

    func toggleLayers() {
        showLayers.toggle()
    }

    func onToolSelection(_ callback: @escaping (ApplicationTool?) -> Void) {
        toolSelectionCallbacks.append(callback)
        callback(selectedTool)
    }

    func onLayersVisibilityChange(_ callback: @escaping (Bool) -> Void) {
        layersVisibilityCallbacks.append(callback)
        callback(showLayers)
    }

    func onModeChange(_ callback: @escaping (ApplicationMode) -> Void) {
        modeChangeCallbacks.append(callback)
        callback(currentMode)
    }

    func removeToolSelectionCallback(_ callback: @escaping (ApplicationTool?) -> Void) {
        toolSelectionCallbacks.removeAll(where: { $0 as AnyObject === callback as AnyObject })
    }

    func removeLayersVisibilityCallback(_ callback: @escaping (Bool) -> Void) {
        layersVisibilityCallbacks.removeAll(where: { $0 as AnyObject === callback as AnyObject })
    }

    func removeModeChangeCallback(_ callback: @escaping (ApplicationMode) -> Void) {
        modeChangeCallbacks.removeAll(where: { $0 as AnyObject === callback as AnyObject })
    }

    private func setupSubscribers() {
        $selectedTool
            .sink { [weak self] tool in
                guard let self = self else { return }
                if let selected = tool {
                    self.toolService.selectTool(selected)
                }
                self.notifyToolSelectionCallbacks()
            }
            .store(in: &cancellables)

        $showLayers
             .sink { [weak self] show in
                 guard let self = self else { return }
                 self.toolService.layersVisibilityChanged.send(show)
                 self.notifyLayersVisibilityCallbacks()
             }
             .store(in: &cancellables)

        $currentMode
             .sink { [weak self] mode in
                 guard let self = self else { return }
                 self.toolService.modeChanged.send(mode)
                 self.notifyModeChangeCallbacks()
             }
             .store(in: &cancellables)
    }

    private func notifyToolSelectionCallbacks() {
        toolSelectionCallbacks.forEach { $0(selectedTool) }
    }

    private func notifyLayersVisibilityCallbacks() {
        layersVisibilityCallbacks.forEach { $0(showLayers) }
    }

    private func notifyModeChangeCallbacks() {
        modeChangeCallbacks.forEach { $0(currentMode) }
    }
}

typealias ToolSelector = ToolViewModel
typealias Tool = ApplicationTool
typealias Mode = ApplicationMode
