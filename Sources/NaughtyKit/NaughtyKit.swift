// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation

public struct DebugMessage: EventProtocol {
    public var message: String
    public static var eventType: EventType { return .mouse }

    public init(
        message: String
    ) {
        self.message = message
    }
}

public final class NaughtyEngine {
    private var isRunning: Bool = false

    //NOTE: Modules
    private let moduleStack: ModuleStack = ModuleStack()
    private let eventBus: Events
    private var viewportManager: ViewportManager?
    public let world: World

    public init() {
        self.world = World()
        self.viewportManager = ViewportManager(world: world)
        self.eventBus = Events()

        //NOTE: Module
        moduleStack.add(module: world)
        moduleStack.add(module: eventBus)

        //NOTE: Debug message log
        eventBus.subscribe(to: DebugMessage.self) { message in
            print("Debug: \(message.message)")
        }

    }

    //NOTE: Functions to create viewport ...
    public func createViewport(name: String) -> Viewport? {
        return viewportManager?.createViewport(name: name)
    }

    // Add a global module to the engine
    public func addModule(_ module: Module) {
        moduleStack.add(module: module)
    }

    public func getModule<T: Module>(_ type: T.Type) -> T? {
        return moduleStack.get(type)
    }

    //NOTE: Start the engine
    public func run() {
        isRunning = true
        while isRunning {
            //NOTE: Update modules
            moduleStack.update()
        }
    }

    //NOTE: Stop the engine
    public func stop() {
        isRunning = false
    }
}
