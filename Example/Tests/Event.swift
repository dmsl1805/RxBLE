//
//  Event.swift
//  RxBLE_Example
//
//  Created by Dmitriy Shulzhenko on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct Event {
    var count: Int = 0
    mutating func called() { count += 1 }
}
