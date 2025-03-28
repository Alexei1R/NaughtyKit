import SwiftUI

struct LayersView: View {
    @ObservedObject var toolSelector: ToolSelector
    @Binding var panelWidth: CGFloat
    var geometryProxy: GeometryProxy
    var widthPercentageRange: ClosedRange<CGFloat> = EditorConfiguration
        .layersPanelWidthPercentageRange

    init(
        toolSelector: ToolSelector, rightPanelWidth: Binding<CGFloat>, geometry: GeometryProxy,
        widthPercentageRange: ClosedRange<CGFloat>
    ) {
        self.toolSelector = toolSelector
        self._panelWidth = rightPanelWidth
        self.geometryProxy = geometry
        self.widthPercentageRange = widthPercentageRange
    }

    init(viewModel: ToolSelector, panelWidth: Binding<CGFloat>, geometryProxy: GeometryProxy) {
        self.toolSelector = viewModel
        self._panelWidth = panelWidth
        self.geometryProxy = geometryProxy
        self.widthPercentageRange = EditorConfiguration.layersPanelWidthPercentageRange
    }

    private let handleGrabWidth: CGFloat = EditorConfiguration.layersPanelResizeHandleWidth
    private let autoCloseThreshold: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(EditorConfiguration.divider)
            content
        }
        .frame(width: panelWidth)
        .background(EditorConfiguration.panelBg)
        .overlay(resizeBorder, alignment: .leading)
        .overlay(gestureOverlay, alignment: .leading)
    }

    private var header: some View {
        HStack {
            Text(toolSelector.currentMode.title)
                .foregroundColor(EditorConfiguration.primaryText)
                .font(EditorConfiguration.headerFont())

            Spacer()

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) { toolSelector.toggleLayers() }
            }) {
                Image(systemName: "xmark")
                    .font(EditorConfiguration.iconFont(size: 12))
                    .foregroundColor(EditorConfiguration.primaryIcon)
                    .padding(EditorConfiguration.defaultPadding * 0.8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, EditorConfiguration.defaultPadding * 1.2)
        .padding(.vertical, EditorConfiguration.compactPadding * 1.5)
    }

    private var content: some View {
        toolSelector.currentMode.createView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }

    private var resizeBorder: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(EditorConfiguration.border)
                .frame(width: EditorConfiguration.borderWidth)
                .frame(maxHeight: .infinity)
                .overlay(
                    ModernResizeHandle()
                        .offset(x: EditorConfiguration.borderWidth / 2)
                )
            Spacer()
        }
    }

    private var gestureOverlay: some View {
        Color.clear
            .frame(width: handleGrabWidth)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            #if os(macOS)
                .onHover { inside in
                    if inside { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() }
                }
            #endif
            .offset(x: -(handleGrabWidth - EditorConfiguration.borderWidth) / 2)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                let currentWidth = panelWidth
                let dragAmount = value.translation.width
                let availableWidth = geometryProxy.size.width

                let potentialNewWidth = currentWidth - dragAmount

                let minWidth = availableWidth * widthPercentageRange.lowerBound
                let maxWidth = availableWidth * widthPercentageRange.upperBound

                panelWidth = max(minWidth, min(potentialNewWidth, maxWidth))
            }
            .onEnded { value in
                #if os(macOS)
                    NSCursor.pop()
                #endif

                let availableWidth = geometryProxy.size.width
                let minWidth = availableWidth * widthPercentageRange.lowerBound

                if panelWidth <= minWidth + autoCloseThreshold {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        toolSelector.toggleLayers()
                    }
                }
            }
    }
}

struct ModernResizeHandle: View {
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 4, height: 36)
                .overlay(
                    Capsule()
                        .fill(
                            isHovered
                                ? EditorConfiguration.resizeHandle.opacity(1)
                                : EditorConfiguration.resizeHandle
                        )
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 12)
                )
                .contentShape(Rectangle())
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isHovered = hovering
                    }
                }
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

