//
//  ViewController.swift
//  RxCoreBluetooth
//
//  Created by dmsl1805 on 09/21/2017.
//  Copyright (c) 2017 dmsl1805. All rights reserved.
//

import UIKit
import RxCoreBluetooth

class ViewController: UIViewController {
    let central = CBCentralManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        central.rx
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

