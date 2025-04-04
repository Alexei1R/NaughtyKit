// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import SwiftUI
import NaughtyKit

struct EditorView: View {
    @StateObject var toolSelector = ToolSelector()
    @State private var layersPanelWidth: CGFloat = 300
    @State private var engine = NaughtyEngine()
    @State private var viewport: Viewport?
    @State private var isEngineRunning: Bool = false

    private var rightPanelWidthBinding: Binding<CGFloat> {
        Binding(get: { self.layersPanelWidth }, set: { self.layersPanelWidth = $0 })
    }
    let layersWidthPercentageRange: ClosedRange<CGFloat> = EditorConfiguration
        .layersPanelWidthPercentageRange

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: 0) {
                    viewportAreaContainer(geometry: geometry)

                    if toolSelector.showLayers {
                        LayersView(
                            viewModel: toolSelector,
                            panelWidth: rightPanelWidthBinding,
                            geometryProxy: geometry
                        )
                        .frame(height: geometry.size.height)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: toolSelector.showLayers)

                HStack {
                    VStack {
                        Spacer()

                        ToolsPanelView(toolSelector: toolSelector)
                            .frame(maxHeight: geometry.size.height * 0.75)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: EditorConfiguration.largeCornerRadius
                                )
                                .fill(EditorConfiguration.panelBg.opacity(0.95))
                                .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 3)
                                .overlay(
                                    RoundedRectangle(
                                        cornerRadius: EditorConfiguration.largeCornerRadius
                                    )
                                    .stroke(
                                        EditorConfiguration.border,
                                        lineWidth: EditorConfiguration.borderWidth))
                            )

                        Spacer()
                    }
                    .padding(.leading, EditorConfiguration.toolsPanelContainerPadding)

                    Spacer()
                }
            }
            .background(EditorConfiguration.primaryBg)
            .environmentObject(toolSelector)
            .preferredColorScheme(.dark)
            .onAppear {
                layersPanelWidth = calculateClampedWidth(
                    for: geometry.size,
                    currentWidth: geometry.size.width
                        * EditorConfiguration.layersPanelDefaultWidthPercentage
                )

                // Initialize engine and create viewport
                setupEngine()
                
                // Setup tool selection handler
                ToolService.shared.setToolSelectionHandler { engineTool in
                    handleToolSelection(engineTool)
                }
            }
            .onChange(of: geometry.size) { newSize in
                layersPanelWidth = calculateClampedWidth(
                    for: newSize,
                    currentWidth: layersPanelWidth
                )
            }
        }
    }

    private func viewportAreaContainer(geometry: GeometryProxy) -> some View {
        ZStack {
            if let viewportView = engine.getActiveViewportView() {
                // Render the actual viewport from NaughtyEngine
                viewportView
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Fallback if viewport isn't available yet
                Rectangle()
                    .fill(.black)
                    .overlay(
                        Text("Engine Viewport")
                            .font(EditorConfiguration.secondaryFont(size: 24, weight: .thin))
                            .foregroundColor(EditorConfiguration.secondaryText.opacity(0.2))
                    )
            }

            VStack {
                HStack {
                    Spacer()
                    debugButton
                        .padding(EditorConfiguration.toolsPanelContainerPadding)
                }

                Spacer()

                HStack {
                    Spacer()
                    ModeSelectorView(toolSelector: toolSelector)
                        .padding(.bottom, EditorConfiguration.toolsPanelContainerPadding * 1.5)
                        .padding(.trailing, EditorConfiguration.toolsPanelContainerPadding * 1.5)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var debugButton: some View {
        Button(action: {
            toggleEngineRunning()
        }) {
            HStack(spacing: EditorConfiguration.defaultPadding) {
                Image(systemName: isEngineRunning ? "pause" : "play")
                    .font(EditorConfiguration.iconFont(size: 14))
                Text("Debug")
                    .font(EditorConfiguration.buttonFont(size: 13))
            }
            .foregroundColor(EditorConfiguration.primaryText)
            .padding(.horizontal, EditorConfiguration.defaultPadding)
            .padding(.vertical, EditorConfiguration.defaultPadding)
            .background(
                RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius)
                    .fill(EditorConfiguration.panelBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: EditorConfiguration.cornerRadius)
                    .stroke(EditorConfiguration.border, lineWidth: EditorConfiguration.borderWidth)
            )
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .transition(.scale(scale: 0.9, anchor: .topTrailing).combined(with: .opacity))
    }

    private func calculateClampedWidth(for size: CGSize, currentWidth: CGFloat) -> CGFloat {
        guard size.width > 0 else { return currentWidth }
        let minW = size.width * layersWidthPercentageRange.lowerBound
        let maxW = size.width * layersWidthPercentageRange.upperBound
        return max(minW, min(currentWidth, maxW))
    }
    
    //NOTE: Engine integration methods
    private func setupEngine() {
        engine.start()
        isEngineRunning = true
        
        // Create a viewport with NaughtyEngine
        let config = ViewportConfig(
            clearColor: MTLClearColor(
                red: 0.05,
                green: 0.05,
                blue: 0.08,
                alpha: 1.0
            ),
            isEnabled: true
        )
        
        viewport = engine.createViewport(name: "EditorViewport", config: config)
    }
    
    private func toggleEngineRunning() {
        if isEngineRunning {
            engine.stop()
            isEngineRunning = false
        } else {
            engine.start()
            isEngineRunning = true
        }
    }
    
    private func handleToolSelection(_ engineTool: EngineTools) {
        Log.info("Selected tool: \(engineTool.toString())")
        
        // Example action based on tool selection
        switch engineTool {
        case .select:
            // Enable selection mode in the engine
            break
        case .add:
            // Prepare to add new geometry
            break
        case .transform:
            // Enable transform controls
            break
        default:
            break
        }
    }
}
