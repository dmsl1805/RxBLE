//
//  CBCentralManagerSpec.swift
//  RxBLE_Tests
//
//  Created by Dmitriy Shulzhenko on 2/21/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth
import RxBLE
import Quick
import Nimble


class CBCentralManagerSpec: QuickSpec {
    override func spec() {
        describe("Test delegate observables") {
                let central = CBCentralManager()
        
            it("Shold update state") {
                waitUntil { done in
//                    central.rx.didUpdateState.subscribe(onNext: { central in
//                        done()
//                    })
                    
                    central.delegate?.centralManagerDidUpdateState(central)
                }
            }
        }
    }
}

