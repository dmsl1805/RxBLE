//
//  Test.swift
//  BLETest
//
//  Created by Dmitriy Shulzhenko on 7/28/17.
//  Copyright © 2017 Dmitriy Shulzhenko. All rights reserved.
//

import CoreBluetooth

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

extension Reactive where Base: CBCentralManager {
    
    
    public var delegate: DelegateProxy {
        return RxCBCentralManagerDelegateProxy.proxyForObject(base)
    }
    
    var proxy: RxCBCentralManagerDelegateProxy {
        return delegate as! RxCBCentralManagerDelegateProxy
    }
    
    //MARK: Reactive delegate
    
    public var didUpdateState: Observable<CBCentralManager> {
        return proxy.didUpdateStateSubject.asObservable()
    }
    
    public var willRestoreState: Observable<(central: CBCentralManager, dict: [String : Any])> {
        return proxy.willRestoreStateSubject.asObservable()
    }
    
    public var didDiscover: Observable<(central: CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber)> {
        return proxy.didDiscoverSubject.asObservable()
    }
    
    public var didConnect: Observable<(central: CBCentralManager, peripheral: CBPeripheral)> {
        return proxy.didConnectSubject.asObservable()
    }
 
    public var didFailToConnect: Observable<(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)> {
        return proxy.didFailToConnectSubject.asObservable()
    }
    
    public var didDisconnectPeripheral: Observable<(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)> {
        return proxy.didDisconnectPeripheralSubject.asObservable()
    }
}

class RxCBCentralManagerDelegateProxy : DelegateProxy
    , CBCentralManagerDelegate
    , DelegateProxyType {
    
    internal lazy var didUpdateStateSubject = PublishSubject<CBCentralManager>()
    internal lazy var willRestoreStateSubject = PublishSubject<(central: CBCentralManager, dict: [String : Any])>()
    internal lazy var didDiscoverSubject = PublishSubject<(central: CBCentralManager,peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber)>()
    internal lazy var didConnectSubject = PublishSubject<(central: CBCentralManager, peripheral: CBPeripheral)>()
    internal lazy var didFailToConnectSubject = PublishSubject<(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)>()
    internal lazy var didDisconnectPeripheralSubject = PublishSubject<(central: CBCentralManager, peripheral: CBPeripheral, error: Error?)>()

    //MARK: DelegateProxyType

    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let centralManager: CBCentralManager = object as! CBCentralManager
        return centralManager.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let centralManager: CBCentralManager = object as! CBCentralManager
        if let delegate = delegate {
            centralManager.delegate = (delegate as! CBCentralManagerDelegate)
        } else {
            centralManager.delegate = nil
        }
    }
    
    //MARK: CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        _forwardToDelegate?.centralManagerDidUpdateState?(central)
        didUpdateStateSubject.onNext(central)
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        _forwardToDelegate?.centralManager?(central, willRestoreState: dict)
        willRestoreStateSubject.onNext(central: central, dict: dict)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        _forwardToDelegate?.centralManager?(central, didDiscover: peripheral, advertisementData: advertisementData, rssi: RSSI)
        didDiscoverSubject.onNext((central: central, peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        _forwardToDelegate?.centralManager?(central, didConnect: peripheral)
        didConnectSubject.onNext((central: central, peripheral: peripheral))
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        _forwardToDelegate?.centralManager?(central, didFailToConnect: peripheral, error: error)
        didFailToConnectSubject.onNext((central: central, peripheral: peripheral, error: error))
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        _forwardToDelegate?.centralManager?(central, didDisconnectPeripheral: peripheral, error: error)
        didDisconnectPeripheralSubject.onNext((central: central, peripheral: peripheral, error: error))
    }
    
    deinit {
        didUpdateStateSubject.on(.completed)
        didDiscoverSubject.on(.completed)
        didConnectSubject.on(.completed)
        didFailToConnectSubject.on(.completed)
        didDisconnectPeripheralSubject.on(.completed)
    }
}

