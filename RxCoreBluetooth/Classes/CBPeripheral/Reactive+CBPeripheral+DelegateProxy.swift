//
//  CBP.swift
//  BLETest
//
//  Created by Dmitriy Shulzhenko on 8/2/17.
//  Copyright © 2017 Dmitriy Shulzhenko. All rights reserved.
//

import CoreBluetooth

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif


extension Reactive where Base: CBPeripheral {
    
    typealias PeripheralUpdates = (peripheral: CBPeripheral, error: Error?)
    typealias CharacteristicUpdates = (peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)
    typealias RSSIUpdates = (peripheral: CBPeripheral, error: Error?, RSSI: NSNumber)
    typealias ServiceUpdates = (peripheral: CBPeripheral, error: Error?, service: CBService)
    typealias DescriptorUpdates = (peripheral: CBPeripheral, error: Error?, descriptor: CBDescriptor)

    var delegate: DelegateProxy {
        return RxCBPeripheralDelegateProxy.proxyForObject(base)
    }
    
    var proxy: RxCBPeripheralDelegateProxy {
        return delegate as! RxCBPeripheralDelegateProxy
    }
    
    public var didUpdateName: Observable<CBPeripheral> {
        return proxy.didUpdateNameSubject.asObservable()
    }
    
    public var didModifyServices: Observable<(peripheral: CBPeripheral, invalidatedServices: [CBService])> {
        return proxy.didModifyServicesSubject.asObservable()
    }
    
    public var didReadRSSI: Observable<(peripheral: CBPeripheral, error: Error?, RSSI: NSNumber)> {
        return proxy.didReadRSSISubject.asObservable()
    }
    
    public var didDiscoverServices: Observable<(peripheral: CBPeripheral, error: Error?)> {
        return proxy.didDiscoverServicesSubject.asObservable()
    }
    
    public var didDiscoverIncludedServices: Observable<(peripheral: CBPeripheral, error: Error?, service: CBService)> {
        return proxy.didDiscoverIncludedServicesSubject.asObservable()
    }
    
    public var didDiscoverCharacteristics: Observable<(peripheral: CBPeripheral, error: Error?, service: CBService)> {
        return proxy.didDiscoverCharacteristicsSubject.asObservable()
    }
    
    public var didUpdateValueForCharacteristic: Observable<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)> {
        return proxy.didUpdateValueForCharacteristicSubject.asObservable()
    }
    
    public var didWriteValueForCharacteristic: Observable<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)> {
        return proxy.didWriteValueForCharacteristicSubject.asObservable()
    }
    
    public var didUpdateNotificationState: Observable<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)> {
        return proxy.didUpdateNotificationStateSubject.asObservable()
    }
    
    public var didDiscoverDescriptors: Observable<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)> {
        return proxy.didDiscoverDescriptorsSubject.asObservable()
    }
    
    public var didUpdateValueForDescriptor: Observable<(peripheral: CBPeripheral, error: Error?, descriptor: CBDescriptor)> {
        return proxy.didUpdateValueForDescriptorSubject.asObservable()
    }
    
    public var didWriteValueForDescriptor: Observable<(peripheral: CBPeripheral, error: Error?, descriptor: CBDescriptor)> {
        return proxy.didWriteValueForDescriptorSubject.asObservable()
    }
}

class RxCBPeripheralDelegateProxy: DelegateProxy, DelegateProxyType, CBPeripheralDelegate {
    
    internal lazy var didUpdateNameSubject = PublishSubject<CBPeripheral>()
    internal lazy var didModifyServicesSubject = PublishSubject<(peripheral: CBPeripheral, invalidatedServices: [CBService])>()
    internal lazy var didReadRSSISubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, RSSI: NSNumber)>()
    internal lazy var didDiscoverServicesSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?)>()
    internal lazy var didDiscoverIncludedServicesSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, service: CBService)>()
    internal lazy var didDiscoverCharacteristicsSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, service: CBService)>()
    internal lazy var didUpdateValueForCharacteristicSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)>()
    internal lazy var didWriteValueForCharacteristicSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)>()
    internal lazy var didUpdateNotificationStateSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)>()
    internal lazy var didDiscoverDescriptorsSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, characteristic: CBCharacteristic)>()
    internal lazy var didUpdateValueForDescriptorSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, descriptor: CBDescriptor)>()
    internal lazy var didWriteValueForDescriptorSubject = PublishSubject<(peripheral: CBPeripheral, error: Error?, descriptor: CBDescriptor)>()

    deinit {
        didUpdateNameSubject.on(.completed)
        didModifyServicesSubject.on(.completed)
        didReadRSSISubject.on(.completed)
        didDiscoverServicesSubject.on(.completed)
        didDiscoverIncludedServicesSubject.on(.completed)
        didDiscoverCharacteristicsSubject.on(.completed)
        didUpdateValueForCharacteristicSubject.on(.completed)
        didWriteValueForCharacteristicSubject.on(.completed)
        didUpdateNotificationStateSubject.on(.completed)
        didDiscoverDescriptorsSubject.on(.completed)
        didUpdateValueForDescriptorSubject.on(.completed)
        didWriteValueForDescriptorSubject.on(.completed)
    }
    
    //MARK: DelegateProxyType
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let peripheral = object as! CBPeripheral
        return peripheral.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let peripheral = object as! CBPeripheral
        if let delegate = delegate {
            peripheral.delegate = (delegate as! CBPeripheralDelegate)
        } else {
            peripheral.delegate = nil
        }
    }
    
    //MARK: CBPeripheralDelegate
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        _forwardToDelegate?.peripheralDidUpdateName?(peripheral)
        didUpdateNameSubject.onNext(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        _forwardToDelegate?.peripheral?(peripheral, didModifyServices: invalidatedServices)
        didModifyServicesSubject.onNext((peripheral: peripheral, invalidatedServices: invalidatedServices))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didReadRSSI: RSSI, error: error)
        didReadRSSISubject.onNext((peripheral: peripheral, error: error, RSSI: RSSI))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didDiscoverServices: error)
        didDiscoverServicesSubject.onNext((peripheral: peripheral, error: error))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didDiscoverIncludedServicesFor: service, error: error)
        didDiscoverIncludedServicesSubject.onNext((peripheral: peripheral, error: error, service: service))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        didDiscoverCharacteristicsSubject.onNext((peripheral: peripheral, error: error, service: service))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didUpdateValueFor: characteristic, error: error)
        didUpdateValueForCharacteristicSubject.onNext((peripheral: peripheral, error: error, characteristic: characteristic))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didWriteValueFor: characteristic, error: error)
        didWriteValueForCharacteristicSubject.onNext((peripheral: peripheral, error: error, characteristic: characteristic))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didUpdateNotificationStateFor: characteristic, error: error)
        didUpdateNotificationStateSubject.onNext((peripheral: peripheral, error: error, characteristic: characteristic))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didDiscoverDescriptorsFor: characteristic, error: error)
        didDiscoverDescriptorsSubject.onNext((peripheral: peripheral, error: error, characteristic: characteristic))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didUpdateValueFor: descriptor, error: error)
        didUpdateValueForDescriptorSubject.onNext((peripheral: peripheral, error: error, descriptor: descriptor))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        _forwardToDelegate?.peripheral?(peripheral, didWriteValueFor: descriptor, error: error)
        didWriteValueForDescriptorSubject.onNext((peripheral: peripheral, error: error, descriptor: descriptor))
    }
}
