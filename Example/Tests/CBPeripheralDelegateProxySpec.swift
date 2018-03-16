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

class PeripheralDelegateCounter: NSObject, CBPeripheralDelegate {
    var didUpdateName = Event()
    var didModifyServices = Event()
    var didReadRSSI = Event()
    var didDiscoverServices = Event()
    var didDiscoverIncludedServicesForService = Event()
    var didDiscoverCharacteristicsForService = Event()
    var didUpdateValueForCharacteristic = Event()
    var didWriteValueForCharacteristic = Event()
    var didUpdateNotificationStateForCharacteristic = Event()
    var didDiscoverDescriptorsForCharacteristic = Event()
    var didUpdateValueForDescriptor = Event()
    var didWriteValueForDescriptor = Event()
    var peripheralIsReadyToSendWriteWithoutResponse = Event()
    var didOpenL2CAPChannel = Event()
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        didUpdateName.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        didModifyServices.called()
    }

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        didReadRSSI.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        didDiscoverServices.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        didDiscoverIncludedServicesForService.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        didDiscoverCharacteristicsForService.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        didUpdateValueForCharacteristic.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        didWriteValueForCharacteristic.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        didUpdateNotificationStateForCharacteristic.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        didDiscoverDescriptorsForCharacteristic.called()
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        didUpdateValueForDescriptor.called()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        didWriteValueForDescriptor.called()
    }
 
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        peripheralIsReadyToSendWriteWithoutResponse.called()
    }
    
    @available(iOS 11.0, *)
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        didOpenL2CAPChannel.called()
    }
}

class CBPeripheralDelegateProxySpec: QuickSpec {
    override func spec() {
        describe("Test delegate and observalbles calls") {
            var peripheral = PeripheralMock.create()
            var delegate = PeripheralDelegateCounter()
            var observableEventsCount = 0
            var serviceStub = CBMutableService(type: CBUUID(), primary: false)
            var characteristicStub = CBMutableCharacteristic(type: CBUUID(), properties: .read, value: nil, permissions: .readable)
            var descriptorStub = CBMutableDescriptor(type: CBUUID(string: "68753A44-4D6F-1226-9C60-0050E4C00067"), value: NSData())
            
            beforeEach {
                peripheral = PeripheralMock.create()
                delegate = PeripheralDelegateCounter()
                peripheral.delegate = delegate
                observableEventsCount = 0
                serviceStub = CBMutableService(type: CBUUID(), primary: false)
                characteristicStub = CBMutableCharacteristic(type: CBUUID(), properties: .read, value: nil, permissions: .readable)
                descriptorStub = CBMutableDescriptor(type: CBUUID(string: "68753A44-4D6F-1226-9C60-0050E4C00067"), value: NSData())
            }
            
            afterEach {
                expect(observableEventsCount).to(equal(1))
            }
            
            it("Shold update name") {
                _ = peripheral.rx.didUpdateName.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheralDidUpdateName?(peripheral)
                expect(delegate.didUpdateName.count).to(equal(1))
            }
            
            it("Shold modify services") {
                _ = peripheral.rx.didModifyServices.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didModifyServices: [])
                expect(delegate.didModifyServices.count).to(equal(1))
            }
            
            it("Shold read RSSI") {
                _ = peripheral.rx.didReadRSSI.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didReadRSSI: 0, error: nil)
                expect(delegate.didReadRSSI.count).to(equal(1))
            }
            
            it("Shold discover services") {
                _ = peripheral.rx.didDiscoverServices.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didDiscoverServices: nil)
                expect(delegate.didDiscoverServices.count).to(equal(1))
            }
            
            it("Shold discover included services") {
                _ = peripheral.rx.didDiscoverIncludedServices.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didDiscoverIncludedServicesFor: serviceStub, error: nil)
                expect(delegate.didDiscoverIncludedServicesForService.count).to(equal(1))
            }
            
            it("Shold discover characteristic for service") {
                _ = peripheral.rx.didDiscoverCharacteristics.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didDiscoverCharacteristicsFor: serviceStub, error: nil)
                expect(delegate.didDiscoverCharacteristicsForService.count).to(equal(1))
            }
            
            it("Shold discover update value for characteristic") {
                _ = peripheral.rx.didUpdateValueForCharacteristic.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didUpdateValueFor: characteristicStub, error: nil)
                expect(delegate.didUpdateValueForCharacteristic.count).to(equal(1))
            }
            
            it("Shold write value for characteristic") {
                _ = peripheral.rx.didWriteValueForCharacteristic.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didWriteValueFor: characteristicStub, error: nil)
                expect(delegate.didWriteValueForCharacteristic.count).to(equal(1))
            }
            
            it("Shold update notifications state for characteristic") {
                _ = peripheral.rx.didUpdateNotificationState.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didUpdateNotificationStateFor: characteristicStub, error: nil)
                expect(delegate.didUpdateNotificationStateForCharacteristic.count).to(equal(1))
            }
            
            it("Shold discover descriptors for characteristic") {
                _ = peripheral.rx.didDiscoverDescriptors.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didDiscoverDescriptorsFor: characteristicStub, error: nil)
                expect(delegate.didDiscoverDescriptorsForCharacteristic.count).to(equal(1))
            }
            
            it("Shold update value for descriptor") {
                _ = peripheral.rx.didUpdateValueForDescriptor.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didUpdateValueFor: descriptorStub, error: nil)
                expect(delegate.didUpdateValueForDescriptor.count).to(equal(1))
            }
            
            it("Shold write value for descriptor") {
                _ = peripheral.rx.didWriteValueForDescriptor.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheral?(peripheral, didWriteValueFor: descriptorStub, error: nil)
                expect(delegate.didWriteValueForDescriptor.count).to(equal(1))
            }
            
            it("Shold ready to send write without response") {
                _ = peripheral.rx.isReadyToSendWriteWithoutResponse.subscribe(onNext: { _ in observableEventsCount += 1 })
                peripheral.delegate?.peripheralIsReady?(toSendWriteWithoutResponse: peripheral)
                expect(delegate.peripheralIsReadyToSendWriteWithoutResponse.count).to(equal(1))
            }
            
            if #available(iOS 11.0, *) {
                it("Shold open L2CAP channel") {
                    _ = peripheral.rx.didOpenL2CAPChannel.subscribe(onNext: { _ in observableEventsCount += 1 })
                    peripheral.delegate?.peripheral?(peripheral, didOpen: nil, error: nil)
                    expect(delegate.didOpenL2CAPChannel.count).to(equal(1))
                }
            }
        }
    }
}



