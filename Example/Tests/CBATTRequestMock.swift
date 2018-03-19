//
//  CBATTRequestMock.swift
//  RxBLE_Example
//
//  Created by Dmitriy Shulzhenko on 3/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth

class CBATTRequestMock: CBATTRequest {
    init(_ any: Any = ()) { }
    
    static func create() -> CBATTRequestMock {
        let request = CBATTRequestMock(())
        return request
    }
}

