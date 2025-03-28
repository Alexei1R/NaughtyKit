import SwiftUI

struct ToolButton: View {
    let tool: ApplicationTool
    let isSelected: Bool
    let action: () -> Void

    #if os(macOS)
    @State private var isHovering = false
    #endif

    var body: some View {
        Button(action: action) {
            Image(systemName: tool.icon)
                .font(EditorConfiguration.iconFont())
                .foregroundColor(isSelected ? EditorConfiguration.accentColor : EditorConfiguration.primaryIcon)
                .frame(width: EditorConfiguration.toolButtonSize, height: EditorConfiguration.toolButtonSize)
                .background(backgroundView)
                .clipShape(RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius))
                .overlay(borderOverlay)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.05)) {
                isHovering = hovering
            }
        }
        #endif
    }

    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
             EditorConfiguration.accentColor.opacity(0.25)
        } else {
            #if os(macOS)
            if isHovering {
                 EditorConfiguration.panelBgHover.opacity(0.8)
            } else {
                 EditorConfiguration.panelBg.opacity(0.6)
            }
            #else
             EditorConfiguration.panelBg.opacity(0.6)
            #endif
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        #if os(macOS)
        let showBorder = isSelected || isHovering
        #else
        let showBorder = isSelected
        #endif

        RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius)
             .stroke(EditorConfiguration.border.opacity(0.5), lineWidth: EditorConfiguration.borderWidth)
             .opacity(showBorder ? 0.8 : 0)
    }
}
