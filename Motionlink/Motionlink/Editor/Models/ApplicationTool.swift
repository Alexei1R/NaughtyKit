import Foundation
import SwiftUI

public enum EngineTools {
    case none
    case select
    case control
    case add
    case transform

    public func toString() -> String {
        switch self {
        case .none: return "none"
        case .select: return "Select"
        case .control: return "Control"
        case .add: return "Add"
        case .transform: return "Transform"
        }
    }
}

struct ApplicationTool: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let icon: String
    let group: ToolGroup
    let supportedModes: [ApplicationMode]
    let engineTool: EngineTools

    init(name: String, icon: String, group: ToolGroup, engineTool: EngineTools, supportedModes: [ApplicationMode] = ApplicationMode.allCases) {
        self.name = name
        self.icon = icon
        self.group = group
        self.engineTool = engineTool
        self.supportedModes = supportedModes
    }

    static func == (lhs: ApplicationTool, rhs: ApplicationTool) -> Bool {
        lhs.id == rhs.id
    }
}

enum ToolGroup {
    case selection, manipulation, creation
}
