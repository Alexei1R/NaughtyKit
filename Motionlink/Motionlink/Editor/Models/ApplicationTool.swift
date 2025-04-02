import Foundation
import SwiftUI

public enum EngineTools {
    case none
    case control  // Core movement/control tool
    case select  // Selection tool
    case add  // Add new geometry
    case transform  // Move/rotate/scale
    case extrude  // Extrude surfaces
    case cut  // Boolean cut operation
    case fillet  // Round edges
    case align  // Align objects
    case pattern  // Create patterns/arrays
    case measure  // Measurement tool

    public func toString() -> String {
        switch self {
        case .none: return "None"
        case .control: return "Control"
        case .select: return "Select"
        case .add: return "Add"
        case .transform: return "Transform"
        case .extrude: return "Extrude"
        case .cut: return "Cut"
        case .fillet: return "Fillet"
        case .align: return "Align"
        case .pattern: return "Pattern"
        case .measure: return "Measure"
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

    init(
        name: String, icon: String, group: ToolGroup, engineTool: EngineTools,
        supportedModes: [ApplicationMode] = ApplicationMode.allCases
    ) {
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
