//
//  ViewController.swift
//  RxBLE
//
//  Created by dmsl1805 on 09/25/2017.
//  Copyright (c) 2017 dmsl1805. All rights reserved.
//

import UIKit

import RxBLE
import CoreBluetooth
import RxSwift

struct BLEConfig {
    let peripheralIdentifier: UUID
    let services: [CBUUID]
    let scanOpptions: [String: Any]
    let connectOpptions: [String: Any]
    
    let peripheralService: CBUUID
    let peripheralCharacteristic: CBUUID
}

enum CustomBLEError: Error {
    case serviceNotFound
    case characteristicNotFound
}

class ViewController: UIViewController {
    @IBOutlet private var executeButton: UIButton!

    let central = CBCentralManager()
    let disposeBag = DisposeBag()
    
    var peripheral: CBPeripheral!
    let config = BLEConfig(peripheralIdentifier: UUID(uuidString: "Replace with your peripheral identifier")!,
                           services: ["Replace with your services"].map { CBUUID(string: $0) },
                           scanOpptions: [:],
                           connectOpptions: [:],
                           peripheralService: CBUUID(string: "Replace with your service"),
                           peripheralCharacteristic: CBUUID(string: "Replace with service's characteristic"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        executeButton.rx.tap
            .withLatestFrom(central.rx.state)
            .filter { $0 == .poweredOn }
            .subscribe(onNext: { [unowned self] _ in self.executeOnUpdateState(self.config) })
            .disposed(by: disposeBag)
        
    }
    
    private func executeOnUpdateState(_ config: BLEConfig) {
        central.rx.retrieveOrScanPeripherals([config.peripheralIdentifier],
                                             withServices: config.services,
                                             options: config.scanOpptions)
            .take(1)
            
            .flatMap { [unowned self] in self.saveAndConnect($0.central, $0.peripheral) }
            .flatMap { $0.peripheral.rx.discoverService(config.peripheralService) }
            .flatMap { $0.peripheral.rx.discoverCharacteristic(config.peripheralCharacteristic, for: $0.service) }
            .flatMap { $0.peripheral.rx.readValue(for: $0.characteristic) }
            
            .subscribe(onNext: { (peripheral: CBPeripheral, characteristic: CBCharacteristic) in
                guard let value = characteristic.value else {
                    print("Empty")
                    return
                }
                let version = String(data: value, encoding: .utf8)
                print(version ?? "fail")
            }, onError: {
                print($0)
            })
            
            .addDisposableTo(disposeBag)
    }
    
    private func saveAndConnect(_ central: CBCentralManager, _ peripheral: CBPeripheral) -> Observable<(central: CBCentralManager, peripheral: CBPeripheral)> {
        self.peripheral = peripheral
        return central.rx.connect(peripheral, options: config.connectOpptions)
    }
}


