//
//  SeedGeneratable.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/30.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import Foundation

protocol SeedGeneratable {
}

extension SeedGeneratable {
    var seed: [UUID] {
        return (1...1000).map({ _ in UUID() })
    }
}

protocol MegaSeedGeneratable {
}

extension MegaSeedGeneratable {
    var megaSeed: [UUID] {
        return (1...1000000).map({ _ in UUID() })
    }
}

protocol SeedUpdatable {
}

extension SeedUpdatable {
    func update(_ seed: [UUID], insertionRatio: Double, deletionRatio: Double) -> [UUID] {
        guard 1.0 > insertionRatio && 1.0 > deletionRatio && insertionRatio + deletionRatio < 1.0 else {
            return seed
        }

        let countOfSeed = Double(seed.count)
        let numberOfInsertion = Int(floor(countOfSeed * insertionRatio))
        let numberOfDeletion = Int(floor(countOfSeed * deletionRatio))

        let insertion = (1...numberOfInsertion).map({ _ in UUID() })

        if numberOfDeletion > 0 {
            let deleted = seed.dropLast(numberOfDeletion)
            return insertion + deleted.map({ $0 })
        }

        return insertion + seed
    }
}
