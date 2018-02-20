//
//  CBPeripheralManagerDelegate+Rx.swift
//  BLETest
//
//  Created by Dmitriy Shulzhenko on 8/4/17.
//  Copyright © 2017 Dmitriy Shulzhenko. All rights reserved.
//

import CoreBluetooth

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

extension Reactive where Base: CBPeripheralManager {
    
    var delegate: DelegateProxy<CBPeripheralManager, CBPeripheralManagerDelegate> {
        return RxCBPeripheralManagerDelegateProxy.proxy(for: base)
    }
    
    var proxy: RxCBPeripheralManagerDelegateProxy {
        return RxCBPeripheralManagerDelegateProxy.proxy(for: base)
    }
    
    public var didUpdateState: Observable<CBPeripheralManager> {
        return proxy.didUpdateStateSubject.asObservable()
    }
    
    public var willRestoreState: Observable<(peripheral:CBPeripheralManager, dict: [String : Any])> {
        return proxy.willRestoreStateSubject.asObservable()
    }
    
    public var didStartAdvertising: Observable<(peripheral: CBPeripheralManager, error: Error?)> {
        return proxy.didStartAdvertisingSubject.asObservable()
    }
    
    public var didAddService: Observable<(peripheral: CBPeripheralManager, service: CBService, error: Error?)> {
        return proxy.didAddServiceSubject.asObservable()
    }
    
    public var didSubscribeToCharacteristic: Observable<(peripheral: CBPeripheralManager, central: CBCentral, characteristic: CBCharacteristic)> {
        return proxy.didSubscribeToCharacteristicSubject.asObservable()
    }
    
    public var didUnsubscribeFromCharacteristic: Observable<(peripheral: CBPeripheralManager, central: CBCentral, characteristic: CBCharacteristic)> {
        return proxy.didUnsubscribeFromCharacteristicSubject.asObservable()
    }
    
    public var didReceiveReadRequest: Observable<(peripheral: CBPeripheralManager, request: CBATTRequest)> {
        return proxy.didReceiveReadRequestSubject.asObservable()
    }
    
    public var didReceiveWriteRequests: Observable<(peripheral: CBPeripheralManager, requests: [CBATTRequest])> {
        return proxy.didReceiveWriteRequestsSubject.asObservable()
    }
    
    public var isReadyToUpdateSubscribers: Observable<CBPeripheralManager> {
        return proxy.isReadyToUpdateSubscribersSubject.asObservable()
    }
}

extension CBPeripheralManager: HasDelegate {
    public typealias Delegate = CBPeripheralManagerDelegate
}

class RxCBPeripheralManagerDelegateProxy: DelegateProxy<CBPeripheralManager, CBPeripheralManagerDelegate>, DelegateProxyType, CBPeripheralManagerDelegate {
    
    internal lazy var didUpdateStateSubject = PublishSubject<CBPeripheralManager>()
    internal lazy var willRestoreStateSubject = PublishSubject<(peripheral:CBPeripheralManager, dict: [String : Any])>()
    internal lazy var didStartAdvertisingSubject = PublishSubject<(peripheral: CBPeripheralManager, error: Error?)>()
    internal lazy var didAddServiceSubject = PublishSubject<(peripheral: CBPeripheralManager, service: CBService, error: Error?)>()
    internal lazy var didSubscribeToCharacteristicSubject = PublishSubject<(peripheral: CBPeripheralManager, central: CBCentral, characteristic: CBCharacteristic)>()
    internal lazy var didUnsubscribeFromCharacteristicSubject = PublishSubject<(peripheral: CBPeripheralManager, central: CBCentral, characteristic: CBCharacteristic)>()
    internal lazy var didReceiveReadRequestSubject = PublishSubject<(peripheral: CBPeripheralManager, request: CBATTRequest)>()
    internal lazy var didReceiveWriteRequestsSubject = PublishSubject<(peripheral: CBPeripheralManager, requests: [CBATTRequest])>()
    internal lazy var isReadyToUpdateSubscribersSubject = PublishSubject<CBPeripheralManager>()
    
    init(_ peripheralManager: CBPeripheralManager) {
        super.init(parentObject: peripheralManager, delegateProxy: RxCBPeripheralManagerDelegateProxy.self)
    }
    
    deinit {
        didUpdateStateSubject.on(.completed)
        willRestoreStateSubject.on(.completed)
        didStartAdvertisingSubject.on(.completed)
        didAddServiceSubject.on(.completed)
        didSubscribeToCharacteristicSubject.on(.completed)
        didUnsubscribeFromCharacteristicSubject.on(.completed)
        didReceiveReadRequestSubject.on(.completed)
        didReceiveWriteRequestsSubject.on(.completed)
        isReadyToUpdateSubscribersSubject.on(.completed)
    }
    
    //MARK: DelegateProxyType

    static func registerKnownImplementations() {
        register { RxCBPeripheralManagerDelegateProxy($0) }
    }
    
    //MARK: CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        _forwardToDelegate?.peripheralManagerDidUpdateState?(peripheral)
        didUpdateStateSubject.onNext(peripheral)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        _forwardToDelegate?.peripheralManager?(peripheral, willRestoreState: dict)
        willRestoreStateSubject.onNext((peripheral: peripheral, dict: dict))
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        _forwardToDelegate?.peripheralManagerDidStartAdvertising?(peripheral, error: error)
        didStartAdvertisingSubject.onNext((peripheral: peripheral, error: error))
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        _forwardToDelegate?.peripheralManager?(peripheral, didAdd: service, error: error)
        didAddServiceSubject.onNext((peripheral: peripheral, service: service, error: error))
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        _forwardToDelegate?.peripheralManager?(peripheral, central: central, didSubscribeTo: characteristic)
        didSubscribeToCharacteristicSubject.onNext((peripheral: peripheral, central: central, characteristic: characteristic))
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        _forwardToDelegate?.peripheralManager?(peripheral, central: central, didUnsubscribeFrom: characteristic)
        didUnsubscribeFromCharacteristicSubject.onNext((peripheral: peripheral, central: central, characteristic: characteristic))
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        _forwardToDelegate?.peripheralManager?(peripheral, didReceiveRead: request)
        didReceiveReadRequestSubject.onNext((peripheral: peripheral, request: request))
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        _forwardToDelegate?.peripheralManager?(peripheral, didReceiveWrite: requests)
        didReceiveWriteRequestsSubject.onNext((peripheral: peripheral, requests: requests))
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        _forwardToDelegate?.peripheralManagerIsReady?(toUpdateSubscribers: peripheral)
        isReadyToUpdateSubscribersSubject.onNext(peripheral)
    }
}
