
//
//  File.swift
//  BLETest
//
//  Created by Dmitriy Shulzhenko on 8/22/17.
//  Copyright © 2017 Dmitriy Shulzhenko. All rights reserved.
//

import CoreBluetooth

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

extension Array where Element: Equatable {
    func containsAllElementsFrom(_ other: Array<Element>) -> Bool {
        return other
            .map(contains)
            .reduce(true) { $0 && $1 }
    }
}

extension Reactive where Base: CBCentralManager {
    
    public typealias ScanInfo = (central: CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber)
    public typealias CentralPeripheral = (central: CBCentralManager, peripheral: CBPeripheral)

    public var state: Observable<CBManagerState> {
        let subject = BehaviorSubject(value: base.state)
        _ = base.rx.didUpdateState.map { $0.state }.subscribe(subject)
        return subject
    }
    
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?,
                                   options: [String : Any]? = nil) -> Observable<ScanInfo> {
        base.scanForPeripherals(withServices: serviceUUIDs, options: options)
        return base.rx.didDiscover
    }
    
    public func connect(_ peripheral: CBPeripheral,
                        options: [String : Any]? = nil,
                        timeout: (dueTime: RxTimeInterval, scheduler: SchedulerType)? = nil) -> Observable<CentralPeripheral> {
        let observable = Observable<(central: CBCentralManager, peripheral: CBPeripheral)>.create { observer in
            let didConnect = self.didConnect
                .filter { $0.peripheral.identifier == peripheral.identifier }
                .subscribe (onNext: {
                    observer.onNext((central: $0.central, peripheral: $0.peripheral))
                    observer.onCompleted()
                })
            
            let didFail = self.didFailToConnect
                .filter { $0.peripheral.identifier == peripheral.identifier }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        return
                    }
                    observer.onError(error)
                })
            
            self.base.connect(peripheral, options: options)
            return Disposables.create()
        }
          
        guard let timeout = timeout else {
            return observable
        }
        
        return observable.timeout(timeout.dueTime, scheduler: timeout.scheduler)
    }
    
    public func cancelPeripheralConnection(_ peripheral : CBPeripheral) -> Observable<CentralPeripheral> {
        return Observable<(central: CBCentralManager, peripheral: CBPeripheral)>.create { observer in
            let didDisconnect = self.didDisconnectPeripheral
                .filter { $0.peripheral.identifier == peripheral.identifier }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        observer.onNext((central: $0.central, peripheral: $0.peripheral))
                        observer.onCompleted()
                        
                        return
                    }
                    
                    observer.onError(error)
                })
            
            self.base.cancelPeripheralConnection(peripheral)
            return Disposables.create([didDisconnect])
        }
    }
    
    public func retrieveOrScanPeripherals(_ identifiers: [UUID],
                                          withServices services: [CBUUID]? = nil,
                                          options: [String : Any]? = nil) -> Observable<CentralPeripheral>  {
        
        var retrievedPeripherals = base.retrievePeripherals(withIdentifiers: identifiers)
        var retrievedIdentifiers = retrievedPeripherals.map { $0.identifier }
        
        guard !retrievedIdentifiers.containsAllElementsFrom(identifiers) else {
            return observableFrom(peripherals: retrievedPeripherals)
        }
        
        if let services = services {
            let connectedPeripherals = base.retrieveConnectedPeripherals(withServices: services)
            retrievedPeripherals.append(contentsOf: connectedPeripherals)
        }
        
        retrievedIdentifiers = retrievedPeripherals.map { $0.identifier }
        
        guard !retrievedIdentifiers.containsAllElementsFrom(identifiers) else {
            return observableFrom(peripherals: retrievedPeripherals)
        }
        
        return scanForPeripherals(withServices: services, options: options)
            .map { (central: $0.central, peripheral: $0.peripheral) }
            .filter { identifiers.contains($0.peripheral.identifier) }
    }
    
    private func observableFrom(peripherals: [CBPeripheral]) -> Observable<(central: CBCentralManager, peripheral: CBPeripheral)> {
        let observableObects = peripherals.map { (central: base, peripheral: $0) } as [(central: CBCentralManager, peripheral: CBPeripheral)]
        return Observable<(central: CBCentralManager, peripheral: CBPeripheral)>.from(observableObects)
    }
}
