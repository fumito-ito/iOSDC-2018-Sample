//
//  UUID+IdentifiableType.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/31.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import Foundation
import RxDataSources

extension UUID: IdentifiableType {
    public typealias Identity = Int

    public var identity: Int {
        return self.hashValue
    }
}
