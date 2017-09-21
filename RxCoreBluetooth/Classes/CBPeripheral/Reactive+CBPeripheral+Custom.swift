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

extension Reactive where Base: CBPeripheral {
    
    // MARK: RSSI
    
    func readRSSI() -> Observable<(peripheral: CBPeripheral, RSSI: NSNumber)> {
        return Observable<(peripheral: CBPeripheral, RSSI: NSNumber)>.create { observer in
            let didReadRSSI = self.didReadRSSI.subscribe(onNext: { (peripheral, error, rssi) in
                guard let error = error else {
                    observer.onNext((peripheral: peripheral, RSSI: rssi))
                    observer.onCompleted()
                    
                    return
                }
                
                observer.onError(error)
            })
            
            self.base.readRSSI()
            return Disposables.create([didReadRSSI])
        }
    }
    
    //MARK: Services
    
    func discoverServices(_ services: [CBUUID]?) -> Observable<CBPeripheral> {
        let knownServicesUUIDs = base.services?.map { $0.uuid }
        
        let allServicesAreAlreadyKnown = services?
            .flatMap { knownServicesUUIDs?.contains($0) }
            .reduce(true) { $0 && $1 }
            ?? false
        
        guard !allServicesAreAlreadyKnown else {
            return Observable.just(self.base)
        }

        return Observable<CBPeripheral>.create { observer in
            let didDiscover = self.didDiscoverServices.subscribe(onNext: {
                guard let error = $0.error else {
                        observer.onNext($0.peripheral)
                        observer.onCompleted()
                        
                        return
                    }
                    
                    observer.onError(error)
                })
            
            self.base.discoverServices(services)
            return Disposables.create([didDiscover])
        }
    }
    
    func discoverIncludedServices(_ services: [CBUUID]?, for service: CBService ) -> Observable<(peripheral: CBPeripheral, service: CBService)> {
        let knownServicesUUIDs = service.includedServices?.map { $0.uuid }
        
        let allServicesAreAlreadyKnown = services?
            .flatMap { knownServicesUUIDs?.contains($0) }
            .reduce(true) { $0 && $1 }
            ?? false
        
        guard !allServicesAreAlreadyKnown else {
            return Observable.just((peripheral: self.base, service: service))
        }
        
        return Observable<(peripheral: CBPeripheral, service: CBService)>.create { observer in
            let discoverIncludedServices = self.didDiscoverIncludedServices
                .filter { $0.service.uuid == service.uuid }
                .subscribe(onNext: {
                guard let error = $0.error else {
                    observer.onNext(peripheral: $0.peripheral, service: $0.service)
                    observer.onCompleted()
                    
                    return
                }
                
                observer.onError(error)
            })
            
            self.base.discoverIncludedServices(services, for: service)
            return Disposables.create([discoverIncludedServices])
        }
    }
    
    //MARK: Characteristics
    
    func discoverCharacteristics(_ characteristics: [CBUUID]?, for service: CBService) -> Observable<(peripheral: CBPeripheral, service: CBService)> {
        let knownCharacteristicsUUIDs = service.characteristics?.map { $0.uuid }
        
        let allServicesAreAlreadyKnown = characteristics?
            .flatMap { knownCharacteristicsUUIDs?.contains($0) }
            .reduce(true) { $0 && $1 }
            ?? false
        
        guard !allServicesAreAlreadyKnown else {
            return Observable.just((peripheral: self.base, service: service))
        }
        
        return Observable<(peripheral: CBPeripheral, service: CBService)>.create { observer in
            let didDiscover = self.didDiscoverCharacteristics
                .filter { $0.service.uuid == service.uuid }
                .subscribe(onNext: {
                guard let error = $0.error else {
                    observer.onNext(peripheral: $0.peripheral, service: $0.service)
                    observer.onCompleted()
                    
                    return
                }
                
                observer.onError(error)
            })
            
            self.base.discoverCharacteristics(characteristics, for: service)
            return Disposables.create([didDiscover])
        }
    }
    
    func readValueForCharacteristic(_ characteristic: CBCharacteristic) -> Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic)> {
        
        return Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic)>.create { observer in
            let didUpdateValue = self.didUpdateValueForCharacteristic
                .filter { $0.characteristic.uuid == characteristic.uuid }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        observer.onNext((peripheral: $0.peripheral, characteristic: characteristic))
                        observer.onCompleted()
                        
                        return
                    }
                    
                    observer.onError(error)
                })
            
            self.base.readValue(for: characteristic)
            return Disposables.create([didUpdateValue])
        }
    }
    
    func writeValue(data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) -> Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic, value: Data)> {
                
        guard type == .withResponse else {
            self.base.writeValue(data, for: characteristic, type: type)
            return Observable.just((peripheral: base, characteristic: characteristic, value: data))
        }
        
        return Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic, value: Data)>.create { observer in
            let didWrite = self.didWriteValueForCharacteristic
                .filter { $0.characteristic.uuid == characteristic.uuid }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        observer.onNext((peripheral: $0.peripheral, characteristic: $0.characteristic, value: data))
                        observer.onCompleted()
                        return
                    }
                    
                    observer.onError(error)
                })
            
            self.base.writeValue(data, for: characteristic, type: type)
            return Disposables.create([didWrite])
        }
    }
    
    func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) -> Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic)> {
        
        guard enabled else {
            return Observable.just((peripheral: self.base, characteristic: characteristic))
        }
        
        return Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic)>.create { observer in
            let didUpdateValue = self.didUpdateValueForCharacteristic
                .filter { $0.characteristic.uuid == characteristic.uuid }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        observer.onNext((peripheral: $0.peripheral, characteristic: characteristic))
                        observer.onCompleted()
                        
                        return
                    }
                    
                    observer.onError(error)
                })
            
            self.base.setNotifyValue(enabled, for: characteristic)
            return Disposables.create([didUpdateValue])
        }
    }
    
    // MARK: Descriptors
    
    func discoverDescriptors(for characteristic: CBCharacteristic) -> Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic)> {
        return Observable<(peripheral: CBPeripheral, characteristic: CBCharacteristic)>.create { observer in
            let didDiscoverDescriptors = self.didDiscoverDescriptors
                .filter { $0.characteristic.uuid == characteristic.uuid }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        observer.onNext((peripheral: $0.peripheral, characteristic: characteristic))
                        observer.onCompleted()
                        
                        return
                    }
                    
                    observer.onError(error)
                })
            
            self.base.discoverDescriptors(for: characteristic)
            return Disposables.create([didDiscoverDescriptors])
        }
    }
    
    func readValue(for descriptor: CBDescriptor) -> Observable<(peripheral: CBPeripheral, descriptor: CBDescriptor)> {
        return Observable<(peripheral: CBPeripheral, descriptor: CBDescriptor)>.create { observer in
            let didUpdateValue = self.didUpdateValueForDescriptor
                .filter { $0.descriptor.uuid == descriptor.uuid }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        observer.onNext((peripheral: $0.peripheral, descriptor: descriptor))
                        observer.onCompleted()
                        
                        return
                    }
                    
                    observer.onError(error)
                })
            
            self.base.readValue(for: descriptor)
            return Disposables.create([didUpdateValue])
        }
    }
    
    func writeValue(_ data: Data, for descriptor: CBDescriptor) -> Observable<(peripheral: CBPeripheral, descriptor: CBDescriptor, value: Data)> {
        return Observable<(peripheral: CBPeripheral, descriptor: CBDescriptor, value: Data)>.create { observer in
            let didWriteValue = self.didWriteValueForDescriptor
                .filter { $0.descriptor.uuid == descriptor.uuid }
                .subscribe(onNext: {
                    guard let error = $0.error else {
                        observer.onNext((peripheral: $0.peripheral, descriptor: descriptor, value: data))
                        observer.onCompleted()
                        
                        return
                    }
                    
                    observer.onError(error)
            })
            
            self.base.writeValue(data, for: descriptor)
            return Disposables.create([didWriteValue])
        }
    }
}
