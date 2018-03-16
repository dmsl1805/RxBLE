//
//  CBPeripheralMock.swift
//  RxBLE_Example
//
//  Created by Dmitriy Shulzhenko on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth

class PeripheralMock: CBPeripheral {
    init(_ any: Any = ()) { }
    
    static func create() -> CBPeripheral {
        let peripheral = PeripheralMock(())
        peripheral.addObserver(peripheral, forKeyPath: #keyPath(delegate), options: .new, context: nil)
        return peripheral
    }
}
