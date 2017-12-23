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

extension Reactive where Base: CBCentralManager {
    
    public var state: Observable<CBManagerState> {
        return Observable.create { observer in
            observer.onNext(self.base.state)
            let didUpdateState = self.base.rx.didUpdateState.subscribe(onNext: { central in
                observer.onNext(central.state)
            })
            return Disposables.create([didUpdateState])
        }
    }
    
    public func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) -> Observable<(central: CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber)> {
        
        base.scanForPeripherals(withServices: serviceUUIDs, options: options)
        return base.rx.didDiscover
    }
    
    public func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) -> Observable<(central: CBCentralManager, peripheral: CBPeripheral)> {
        
        return Observable<(central: CBCentralManager, peripheral: CBPeripheral)>.create { observer in
    
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
            return Disposables.create(didConnect, didFail)
        }
    }
    
    public func cancelPeripheralConnection(_ peripheral : CBPeripheral) -> Observable<(central: CBCentralManager, peripheral: CBPeripheral)> {
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
    
    public func retrieveOrScanPeripherals(_ identifiers: [UUID], withServices services: [CBUUID]?, options: [String : Any]? = nil) -> Observable<(central: CBCentralManager, peripheral: CBPeripheral)>  {
        
        var retrievedPeripherals = base.retrievePeripherals(withIdentifiers: identifiers)
        
        if let services = services {
            let connectedPeripherals = base.retrieveConnectedPeripherals(withServices: services)
            retrievedPeripherals.append(contentsOf: connectedPeripherals)
        }
        
        let allPeripheralsAreAlreadyRetrieved = retrievedPeripherals
            .flatMap { identifiers.contains($0.identifier) }
            .reduce(true) { $0 && $1 }
        
        guard !allPeripheralsAreAlreadyRetrieved else {
            let observableObects = retrievedPeripherals.map { peripheral -> (central: CBCentralManager, peripheral: CBPeripheral) in
                (central: base, peripheral: peripheral)
            }
            return Observable<(central: CBCentralManager, peripheral: CBPeripheral)>.from(observableObects)
        }
        
        return scanForPeripherals(withServices: services, options: options)
            .map { (central: $0.central, peripheral: $0.peripheral) }
    }
}
