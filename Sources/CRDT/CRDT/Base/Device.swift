//
//  Device.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 01.05.2020.
//

#if os(iOS)
import UIKit
#endif

enum Device {
    typealias ID = String
    static var id: ID {
        #if os(iOS)
        return UIDevice.current.identifierForVendor!.uuidString
        #else
        return "server"
        #endif
    }
}
