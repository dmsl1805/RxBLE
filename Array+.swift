//
//  Array+.swift
//  Nimble
//
//  Created by Dmitriy on 5/30/18.
//

import Foundation

extension Array where Element: Equatable {
    func containsAllElementsFrom(_ other: Array<Element>) -> Bool {
        return other
            .map(contains)
            .reduce(true) { $0 && $1 }
    }
}
