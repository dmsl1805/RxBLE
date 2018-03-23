//
//  RxCBCentralManager.swift
//  RxBLE_Tests
//
//  Created by Dmitriy Shulzhenko on 3/19/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import CoreBluetooth
import RxBLE
import Quick
import Nimble

private class CentralManagerMock: CBCentralManager {
    override func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) { }
}

class RxCBCentralManager: QuickSpec {
    override func spec() {
        
        enum ConectionError: Error {
            case error
        }

        var central = CentralManagerMock()

        beforeEach {
            central = CentralManagerMock()
        }
        
        it("state") {
            var state: CBManagerState?
            
            _ = central.rx.state.subscribe(onNext: { state = $0 })
            expect(state).to(equal(central.state))
            
            state = nil
            central.delegate?.centralManagerDidUpdateState(central)
            expect(state).to(equal(central.state))
        }
        
        describe("scan for peripherals") {
            var scannedPeripherals: [CBPeripheral] = []
            
            beforeEach {
                scannedPeripherals = []
            }
            
            it("One scan") {
                _ = central.rx
                    .scanForPeripherals(withServices: [])
                    .subscribe(onNext: {
                    scannedPeripherals.append($0.peripheral)
                })
                
                let mockForScan: [CBPeripheral] = [PeripheralMock.create()]
                    .map { peripheral in
                        central.delegate?.centralManager?(central,
                                                          didDiscover: peripheral,
                                                          advertisementData: [:],
                                                          rssi: 0)
                        return peripheral
                }
                
                expect(scannedPeripherals).to(equal(mockForScan))
            }
            
            it("Two scans simultaneously") {
                var secondScannedPeripherals: [CBPeripheral] = []

                let firstServices: [CBService] = [
                    CBMutableService(type: CBUUID(string: "68753A44-4D6F-1226-9C60-0050E4C00000"),
                                     primary: false),
                    CBMutableService(type: CBUUID(string: "68753A44-4D6F-1226-9C60-0050E4C00001"),
                                     primary: false)
                ]
                
                let secondServices: [CBService] = [
                    CBMutableService(type: CBUUID(string: "68753A44-4D6F-1226-9C60-0050E4C00002"),
                                     primary: false),
                    CBMutableService(type: CBUUID(string: "68753A44-4D6F-1226-9C60-0050E4C00003"),
                                     primary: false)
                ]
                
                let firstUUIDs = firstServices.map { $0.uuid }
                let secondUUIDs = secondServices.map { $0.uuid }

                _ = central.rx
                    .scanForPeripherals(withServices: firstUUIDs)
                    .subscribe(onNext: {
                        scannedPeripherals.append($0.peripheral)
                    })
                
                _ = central.rx
                    .scanForPeripherals(withServices: secondUUIDs)
                    .subscribe(onNext: {
                        secondScannedPeripherals.append($0.peripheral)
                    })
                
                let mockForFirstScan: [CBPeripheral] = [PeripheralMock.create()]
                let mockForSecondScan: [CBPeripheral] = [PeripheralMock.create(), PeripheralMock.create()]
                
                func callDidDiscover(for peripherals: [CBPeripheral]) {
                    peripherals.forEach { peripheral in
                        central.delegate?.centralManager?(central,
                                                          didDiscover: peripheral,
                                                          advertisementData: [:],
                                                          rssi: 0)
                    }
                }
                
                callDidDiscover(for: mockForFirstScan)
                callDidDiscover(for: mockForSecondScan)
                
                let merged = [mockForFirstScan, mockForSecondScan].flatMap { $0 }
                expect(scannedPeripherals).to(equal(merged))
                expect(secondScannedPeripherals).to(equal(merged))
            }
        }
        
        describe("connect") {
            it("shold success") {
                let peripheral = PeripheralMock.create()
                var didConnectCalled = false
                
                _ = central.rx.connect(peripheral).subscribe(onNext: { central, connectedPeripheral in
                    didConnectCalled = true
                    expect(connectedPeripheral.identifier).to(equal(peripheral.identifier))
                }, onError: { error in
                    fatalError("shold not be called")
                })
                
                central.delegate?.centralManager?(central, didConnect: peripheral)
                expect(didConnectCalled).to(beTrue())
            }
            
            it("shold fail") {
                let peripheral = PeripheralMock.create()
                var didFailCalled = false
                
                _ = central.rx.connect(peripheral).subscribe(onNext: { central, connectedPeripheral in
                    fatalError("shold not be called")
                }, onError: { error in
                    didFailCalled = true
                    guard let error = error as? ConectionError else { fatalError("unexpected error") }
                    expect(error).to(equal(ConectionError.error))
                })
                
                central.delegate?.centralManager?(central, didFailToConnect: peripheral, error: ConectionError.error)
                expect(didFailCalled).to(beTrue())
            }
            
            it("shold not be called") {
                _ = central.rx.connect(PeripheralMock.create()).subscribe(onNext: { _ in
                    fatalError("shold not be called")
                }, onError: { error in
                    fatalError("shold not be called")
                })
                
                let peripheral = PeripheralMock.create()
                (peripheral as? PeripheralMock)?.peripheralIdentifier = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E55")
                central.delegate?.centralManager?(central, didConnect: peripheral)
                central.delegate?.centralManager?(central, didFailToConnect: peripheral, error: ConectionError.error)
            }
        }
        
        describe("cancel connection") {
            it("shold cancel without error") {
                let peripheral = PeripheralMock.create()
                (peripheral as? PeripheralMock)?.peripheralIdentifier = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E55")
                
                var cancelPeripheralConnectionCalled = false
                
                _ = central.rx.cancelPeripheralConnection(peripheral).subscribe(onNext: { central, disconnectedPeripheral in
                    expect(disconnectedPeripheral.identifier).to(equal(peripheral.identifier))
                    cancelPeripheralConnectionCalled = true
                }, onError: { _ in
                    fatalError("shold not be called")
                })
                
                central.delegate?.centralManager?(central, didDisconnectPeripheral: peripheral, error: nil)
                expect(cancelPeripheralConnectionCalled).to(beTrue())
            }
            
            it("shold cancel with error") {
                var cancelFailedCalled = false
                
                _ = central.rx.cancelPeripheralConnection(PeripheralMock.create()).subscribe(onNext: { _ in
                    fatalError("shold not be called")
                }, onError: { error in
                    cancelFailedCalled = true
                    guard let error = error as? ConectionError else { fatalError("unexpected error") }
                    expect(error).to(equal(ConectionError.error))
                })
                
                central.delegate?.centralManager?(central, didDisconnectPeripheral: PeripheralMock.create(), error: ConectionError.error)
                expect(cancelFailedCalled).to(beTrue())
            }
        }
    }
}
