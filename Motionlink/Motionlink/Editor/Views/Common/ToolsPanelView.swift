import SwiftUI

struct ToolsPanelView: View {
    @ObservedObject var toolSelector: ToolSelector

     private var groupedTools: [ToolGroup: [ApplicationTool]] {
         Dictionary(grouping: toolSelector.availableTools, by: { $0.group })
     }
     private let groupOrder: [ToolGroup] = [.selection, .manipulation, .creation]


    var body: some View {
        VStack(spacing: EditorConfiguration.defaultPadding) {
            ScrollView(.vertical, showsIndicators: false) {
                 VStack(spacing: EditorConfiguration.compactPadding) {
                     ForEach(toolSelector.availableTools) { tool in
                         ToolButton(
                             tool: tool,
                             isSelected: toolSelector.selectedTool?.id == tool.id
                         ) {
                             toolSelector.selectTool(tool)
                         }
                     }
                 }
                 .padding(.vertical, EditorConfiguration.defaultPadding)
            }

            Spacer()

            layersToggleButton
        }
        .padding(EditorConfiguration.defaultPadding)
    }

    private var layersToggleButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                toolSelector.toggleLayers()
            }
        }) {
            Image(systemName: "sidebar.right")
                .font(EditorConfiguration.iconFont())
                .foregroundColor(toolSelector.showLayers ? EditorConfiguration.accentColor : EditorConfiguration.primaryIcon)
                .frame(width: EditorConfiguration.toolButtonSize, height: EditorConfiguration.toolButtonSize)
                .background(
                    toolSelector.showLayers ? EditorConfiguration.accentColor.opacity(0.25) : EditorConfiguration.panelBgHover.opacity(0.6)
                )
                .clipShape(RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius))
                 .overlay(
                     RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius)
                         .stroke(EditorConfiguration.border.opacity(toolSelector.showLayers ? 0.8 : 0.5), lineWidth: EditorConfiguration.borderWidth)
                 )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
