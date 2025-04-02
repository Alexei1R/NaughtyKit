import Foundation
import SwiftUI

enum ApplicationMode: String, CaseIterable, Identifiable {
    case object = "Obj"
    case scan = "Scan"
    case bone = "Bone"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .object: return "cube.fill"
        case .scan: return "compass.drawing"
        case .bone: return "skew"
        }
    }

    var title: String {
        switch self {
        case .object: return "Objects"
        case .scan: return "Scan"
        case .bone: return "Bone"
        }
    }

    @ViewBuilder
    func createView() -> some View {
        VStack {
            Spacer()
            Text("\(self.title) Mode View")
                .font(EditorConfiguration.primaryFont(size: 16, weight: .light))
                .foregroundColor(EditorConfiguration.primaryText)
            Text("(Content Placeholder)")
                .font(EditorConfiguration.secondaryFont())
                .foregroundColor(EditorConfiguration.secondaryText)
                .padding(.top, EditorConfiguration.compactPadding)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
