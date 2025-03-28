import SwiftUI

struct ModeSelectorView: View {
    @ObservedObject var toolSelector: ToolSelector
    @State private var showMenu = false
    @State private var isPressed = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if showMenu {
                menuPanel
                    .transition(.scale(scale: 0.95, anchor: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }

            modeButton
        }
         .background(TapToCloseBackground(showMenu: $showMenu).opacity(showMenu ? 0.001 : 0))
    }

    private var menuPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Mode.allCases) { mode in
                ModeSelectorOption(
                    icon: mode.icon,
                    title: mode.rawValue,
                    isSelected: toolSelector.currentMode == mode
                ) {
                    toolSelector.setMode(mode)
                    closeMenu()
                }
                 if mode != Mode.allCases.last {
                     Divider()
                         .background(EditorConfiguration.divider.opacity(0.7))
                         .padding(.horizontal, EditorConfiguration.compactPadding)
                 }
            }
        }
        .padding(.vertical, EditorConfiguration.compactPadding)
        .frame(width: EditorConfiguration.modeSelectorWidth)
        .background(EditorConfiguration.panelBg)
        .clipShape(RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius)
                .stroke(EditorConfiguration.border, lineWidth: EditorConfiguration.borderWidth)
        )
        .shadow(color: .black.opacity(0.5), radius: 5, y: 2)
        .offset(y: -(EditorConfiguration.toolButtonSize + EditorConfiguration.defaultPadding * 2))
    }

    private var modeButton: some View {
        Button(action: toggleMenu) {
            HStack(spacing: EditorConfiguration.defaultPadding * 0.8) {
                Image(systemName: toolSelector.currentMode.icon)
                    .font(EditorConfiguration.buttonFont(size: 12))
                    .foregroundColor(EditorConfiguration.primaryIcon)

                Text(toolSelector.currentMode.rawValue)
                    .font(EditorConfiguration.buttonFont(size: 12))
                    .foregroundColor(EditorConfiguration.primaryText)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "chevron.up")
                    .font(EditorConfiguration.smallIconFont())
                    .rotationEffect(.degrees(showMenu ? 180 : 0))
                    .foregroundStyle(EditorConfiguration.secondaryIcon)
            }
            .padding(.horizontal, EditorConfiguration.defaultPadding * 1.5)
            .padding(.vertical, EditorConfiguration.defaultPadding)
            .frame(width: EditorConfiguration.modeSelectorWidth, height: EditorConfiguration.toolButtonSize)
            .background(EditorConfiguration.panelBgHover)
            .clipShape(RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius)
                    .stroke(EditorConfiguration.border, lineWidth: EditorConfiguration.borderWidth)
            )
            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
            .scaleEffect(isPressed ? 0.96 : 1.0)
             .animation(.easeInOut(duration: 0.15), value: showMenu)
             .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isPressed { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
    }

    private func toggleMenu() { withAnimation(.easeInOut(duration: 0.2)) { showMenu.toggle() } }
    private func closeMenu() { withAnimation(.easeInOut(duration: 0.15)) { showMenu = false } }

    struct TapToCloseBackground: View {
        @Binding var showMenu: Bool
        var body: some View { Color.clear.contentShape(Rectangle()).frame(maxWidth: .infinity, maxHeight: .infinity).onTapGesture { closeMenu() }.ignoresSafeArea() }
        private func closeMenu() { withAnimation(.easeInOut(duration: 0.15)) { showMenu = false } }
    }
}

struct ModeSelectorOption: View {
    var icon: String
    var title: String
    var isSelected: Bool
    var action: () -> Void

    #if os(macOS)
    @State private var isHovering = false
    #endif

    var body: some View {
        Button(action: action) {
            HStack(spacing: EditorConfiguration.defaultPadding * 0.8) {
                Image(systemName: icon)
                    .font(EditorConfiguration.buttonFont(size: 12, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? EditorConfiguration.accentColor : EditorConfiguration.primaryIcon)
                    .frame(width: 18, alignment: .center)

                Text(title)
                    .font(EditorConfiguration.buttonFont(size: 12, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(EditorConfiguration.primaryText)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(EditorConfiguration.buttonFont(size: 10, weight: .bold))
                        .foregroundColor(EditorConfiguration.accentColor)
                }
            }
            .padding(.horizontal, EditorConfiguration.defaultPadding * 1.2)
            .padding(.vertical, EditorConfiguration.defaultPadding * 0.8)
            .background(backgroundView)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .onHover { hovering in withAnimation(.easeInOut(duration: 0.05)) { isHovering = hovering } }
        #endif
    }

     @ViewBuilder
     private var backgroundView: some View {
        #if os(macOS)
        if isHovering { EditorConfiguration.panelBgHover.opacity(0.8) } else { Color.clear }
        #else
        Color.clear
        #endif
    }
}
