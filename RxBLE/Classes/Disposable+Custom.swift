//
//  File.swift
//  BLETest
//
//  Created by Dmitriy Shulzhenko on 8/22/17.
//  Copyright © 2017 Dmitriy Shulzhenko. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

extension Disposable {
    @discardableResult func insertIntoComposite(_ composite: CompositeDisposable) -> CompositeDisposable.DisposeKey? {
        return composite.insert(self)
    }
}
