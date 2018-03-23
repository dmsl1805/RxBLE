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
    
    var peripheralIdentifier: UUID?
    
    override var identifier: UUID {
        return peripheralIdentifier ?? UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    }
    
    static func create() -> CBPeripheral {
        let peripheral = PeripheralMock(())
        peripheral.addObserver(peripheral, forKeyPath: #keyPath(delegate), options: .new, context: nil)
        return peripheral
    }
}
