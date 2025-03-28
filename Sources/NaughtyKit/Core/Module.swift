// Copyright (c) 2025 The Noughy Fox
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

public protocol Module: AnyObject {
    func start()
    func update()
    func stop()
}

//NOTE: Default implementations
extension Module {
    public func start() {}
    public func update() {}
    public func stop() {}
}

//NOTE: Modules
public final class ModuleStack {
    private var modules: [ObjectIdentifier: Module] = [:]

    public init() {}

    public func add<T: Module>(module: T) {
        let id = ObjectIdentifier(T.self)

        modules[id] = module
        module.start()
    }

    public func update() {
        modules.values.forEach { $0.update() }
    }

    public func remove<T: Module>(module: T) {
        let id = ObjectIdentifier(T.self)

        if let module = modules[id] {
            module.stop()
            modules.removeValue(forKey: id)
        }

    }

    public func get<T: Module>(_ type: T.Type) -> T? {
        guard let module = modules[ObjectIdentifier(T.self)] as? T else {
            return nil
        }
        return module
    }
}
