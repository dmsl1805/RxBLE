//
//  CBCentalMock.swift
//  RxBLE_Example
//
//  Created by Dmitriy Shulzhenko on 3/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth

class CentralMock: CBCentral {
    init(_ any: Any = ()) { }
    
    static func create() -> CBCentral {
        let central = CentralMock(())
        return central
    }
}
