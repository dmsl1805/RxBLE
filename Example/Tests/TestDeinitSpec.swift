//
//  TestDeinit.swift
//  RxBLE_Example
//
//  Created by Dmitriy on 7/9/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Quick
import Nimble
import CoreBluetooth
import RxBLE
import RxSwift

extension Observable {
    var onCompleted: Observable<Void> {
        return Observable<Void>.create { observer in
            self.subscribe(onCompleted: {
                observer.onNext(())
            })
        }
    }
    
    var onDisposed: Observable<Void> {
        return Observable<Void>.create { observer in
            self.subscribe(onDisposed: {
                observer.onNext(())
            })
        }
    }
    
    var onCompletedAndDisposed: Observable<Void> {
        return Observable<Void>.zip(onCompleted, onDisposed) { _, _ in }
    }
}

class TestDeinitSpec: QuickSpec {
    override func spec() {
        describe("Test deinit") {
            it("didUpdateState") {
                waitUntil { done in
                    _ = CBCentralManager().rx.didUpdateState
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("willRestoreState") {
                waitUntil { done in
                    _ = CBCentralManager().rx.willRestoreState
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("didDiscover") {
                waitUntil { done in
                    _ = CBCentralManager().rx.didDiscover
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("didConnect") {
                waitUntil { done in
                    _ = CBCentralManager().rx.didConnect
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("didFailToConnect") {
                waitUntil { done in
                    _ = CBCentralManager().rx.didFailToConnect
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("didDisconnectPeripheral") {
                waitUntil { done in
                    _ = CBCentralManager().rx.didDisconnectPeripheral
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("state") {
                waitUntil { done in
                    _ = CBCentralManager().rx.state
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("scanForPeripherals") {
                waitUntil { done in
                    _ = CBCentralManager().rx.scanForPeripherals(withServices: nil)
                        .onCompletedAndDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("connect") {
                waitUntil { done in
                    _ = CBCentralManager().rx.connect(PeripheralMock.create())
                        .onDisposed
                        .subscribe(onNext: { _ in
                            done()
                        })
                }
            }
            
            it("cancelPeripheralConnection") {
                waitUntil { done in
                    _ = CBCentralManager().rx.cancelPeripheralConnection(PeripheralMock.create())
                        .onCompleted
                        .subscribe(onNext: { _ in
                            done()
                        })
                    
                }
            }
            
            it("retrieveOrScanPeripherals") {
                waitUntil { done in
                    _ = CBCentralManager().rx.retrieveOrScanPeripherals([])
                        .onCompleted
                        .subscribe(onNext: { _ in
                            done()
                        })
                    
                }
            }
        }
    }
}
