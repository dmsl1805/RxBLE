//
//  CBPeripheralManagerDelegateProxySpec.swift
//  RxBLE_Example
//
//  Created by Dmitriy Shulzhenko on 3/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth
import RxBLE
import Quick
import Nimble

class PeripheralManagerDelegateCounter: NSObject, CBPeripheralManagerDelegate {
    var didUpdateState = Event()
    var willRestoreState = Event()
    var didStartAdvertising = Event()
    var didAddService = Event()
    var didSubscribeTo = Event()
    var didUnsubscribeFrom = Event()
    var didReceiveRead = Event()
    var didReceiveWrite = Event()
    var isReadyToUpdateSubscribers = Event()

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        didUpdateState.called()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        willRestoreState.called()
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        didStartAdvertising.called()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        didAddService.called()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        didSubscribeTo.called()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        didUnsubscribeFrom.called()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        didReceiveRead.called()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        didReceiveWrite.called()
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        isReadyToUpdateSubscribers.called()
    }
}

class CBPeripheralManagerDelegateProxySpec: QuickSpec {
    override func spec() {
        describe("Test delegate and observalbles calls") {
            var manager = CBPeripheralManager()
            var delegate = PeripheralManagerDelegateCounter()
            var observableEventsCount = 0
            var serviceStub: CBService { return CBMutableService(type: CBUUID(), primary: false) }
            var characteristicStub: CBCharacteristic { return CBMutableCharacteristic(type: CBUUID(), properties: .read, value: nil, permissions: .readable) }

            beforeEach {
                delegate = PeripheralManagerDelegateCounter()
                manager = CBPeripheralManager(delegate: delegate, queue: nil)
                observableEventsCount = 0
            }
            
            afterEach {
                expect(observableEventsCount).to(equal(1))
            }
            
            it("Shold update state") {
                _ = manager.rx.didUpdateState.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManagerDidUpdateState(manager)
                expect(delegate.didUpdateState.count).to(equal(1))
            }
            
            it("Shold restore state") {
                _ = manager.rx.willRestoreState.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManager?(manager, willRestoreState: [:])
                expect(delegate.willRestoreState.count).to(equal(1))
            }
            
            it("Shold start advertising") {
                _ = manager.rx.didStartAdvertising.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManagerDidStartAdvertising?(manager, error: nil)
                expect(delegate.didStartAdvertising.count).to(equal(1))
            }
            
            it("Shold add service") {
                _ = manager.rx.didAddService.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManager?(manager, didAdd: serviceStub, error: nil)
                expect(delegate.didAddService.count).to(equal(1))
            }
            
            it("Shold subscribe") {
                _ = manager.rx.didSubscribeToCharacteristic.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManager?(manager, central: CentralMock.create(), didSubscribeTo: characteristicStub)
                expect(delegate.didSubscribeTo.count).to(equal(1))
            }
            
            it("Shold unsubscribe") {
                _ = manager.rx.didUnsubscribeFromCharacteristic.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManager?(manager, central: CentralMock.create(), didUnsubscribeFrom: characteristicStub)
                expect(delegate.didUnsubscribeFrom.count).to(equal(1))
            }
            
            it("Shold receive read") {
                _ = manager.rx.didReceiveReadRequest.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManager?(manager, didReceiveRead: CBATTRequestMock.create())
                expect(delegate.didReceiveRead.count).to(equal(1))
            }
            
            it("Shold receive read") {
                _ = manager.rx.didReceiveWriteRequests.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManager?(manager, didReceiveWrite: [])
                expect(delegate.didReceiveWrite.count).to(equal(1))
            }
            
            it("Shold receive read") {
                _ = manager.rx.isReadyToUpdateSubscribers.subscribe(onNext: { _ in observableEventsCount += 1 })
                manager.delegate?.peripheralManagerIsReady?(toUpdateSubscribers: manager)
                expect(delegate.isReadyToUpdateSubscribers.count).to(equal(1))
            }
        }
    }
}
