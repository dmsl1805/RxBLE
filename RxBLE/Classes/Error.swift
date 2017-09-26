//
//  Error.swift
//  Pods
//
//  Created by Dmitriy Shulzhenko on 9/24/17.
//
//

enum RxCoreBluetoothError: Error {
    case serviceNotFound
    case characteristicNotFound
}

extension RxCoreBluetoothError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .serviceNotFound:          return "Service was not found after discover."
        case .characteristicNotFound:   return "Characteristic was not found after discover."
        }
    }
}
