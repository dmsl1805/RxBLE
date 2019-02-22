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

class CentralManagerDelegateCounter: NSObject, CBCentralManagerDelegate {
    var didUpdateState = Event()
    var willRestoreState = Event()
    var didDiscover = Event()
    var didConnect = Event()
    var didFailToConnect = Event()
    var didDisconnectPeripheral = Event()

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        didUpdateState.called()
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        willRestoreState.called()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        didDiscover.called()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        didConnect.called()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        didFailToConnect.called()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        didDisconnectPeripheral.called()
    }
}

class CBCentralManagerDelegateProxySpec: QuickSpec {
    override func spec() {
        var central = CBCentralManager()

        describe("Test delegate and observalbles calls") {
            var delegate = CentralManagerDelegateCounter()
            var observableEventsCount = 0

            beforeEach {
                central = CBCentralManager()
                delegate = CentralManagerDelegateCounter()
                central.delegate = delegate
                observableEventsCount = 0
            }

            it("Shold update state") {
                _ = central.rx.didUpdateState.subscribe(onNext: { _ in observableEventsCount += 1 })

                central.delegate?.centralManagerDidUpdateState(central)

                expect(delegate.didUpdateState.count).to(equal(1))
                expect(observableEventsCount).to(equal(1))
            }

            it("Shold restore state") {
                _ = central.rx.willRestoreState.subscribe(onNext: { _ in observableEventsCount += 1 })

                central.delegate?.centralManager?(central, willRestoreState: [:])

                expect(delegate.willRestoreState.count).to(equal(1))
                expect(observableEventsCount).to(equal(1))
            }

            it("Shold discover peripheral") {
                _ = central.rx.didDiscover.subscribe(onNext: { _ in observableEventsCount += 1 })

                central.delegate?.centralManager?(central, didDiscover: PeripheralMock.create(), advertisementData: [:], rssi: 0)

                expect(delegate.didDiscover.count).to(equal(1))
                expect(observableEventsCount).to(equal(1))
            }

            it("Shold connect peripheral") {
                _ = central.rx.didConnect.subscribe(onNext: { _ in observableEventsCount += 1 })

                central.delegate?.centralManager?(central, didConnect: PeripheralMock.create())

                expect(delegate.didConnect.count).to(equal(1))
                expect(observableEventsCount).to(equal(1))
            }

            it("Shold fail to connect peripheral") {
                _ = central.rx.didFailToConnect.subscribe(onNext: { _ in observableEventsCount += 1 })

                central.delegate?.centralManager?(central, didFailToConnect: PeripheralMock.create(), error: nil)

                expect(delegate.didFailToConnect.count).to(equal(1))
                expect(observableEventsCount).to(equal(1))
            }

            it("Shold disconnect peripheral") {
                _ = central.rx.didDisconnectPeripheral.subscribe(onNext: { _ in observableEventsCount += 1 })

                central.delegate?.centralManager?(central, didDisconnectPeripheral: PeripheralMock.create(), error: nil)

                expect(delegate.didDisconnectPeripheral.count).to(equal(1))
                expect(observableEventsCount).to(equal(1))
            }
        }
    }
}


