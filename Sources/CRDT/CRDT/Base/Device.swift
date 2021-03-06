//
//  Device.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 01.05.2020.
//

#if os(iOS)
import UIKit
#endif

public enum Device {
    public typealias ID = String

    public static var id: ID {
        return Dependency.generateDeviceID()
    }

    static func generateID() -> ID {
        #if os(iOS)
        return UIDevice.current.identifierForVendor!.uuidString
        #else
        return "server"
        #endif
    }
}

// MARK: - Dependency

extension Device {
    struct Dependency {
        static var generateDeviceID: () -> Device.ID = {
            return Device.generateID()
        }
    }
}
