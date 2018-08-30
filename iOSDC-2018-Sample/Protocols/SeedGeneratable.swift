//
//  SeedGeneratable.swift
//  iOSDC-2018-Sample
//
//  Created by svpcadmin on 2018/08/30.
//  Copyright © 2018年 Fumito Ito. All rights reserved.
//

import Foundation

protocol SeedGeneratable {
    var source: [UUID] { get set }
}

extension SeedGeneratable {
    mutating func prepareSeed() {
        self.source = (1...1000).map({ _ in UUID() })
    }
}

protocol MegaSeedGeneratable: SeedGeneratable {
}

extension MegaSeedGeneratable {
    mutating func prepareSeed() {
        self.source = (1...10000).map({ _ in UUID() })
    }
}

protocol SeedUpdatable {
    var insertionRatio: Double { get set }

    var deletionRatio: Double { get set }
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

extension SeedUpdatable where Self: SeedGeneratable {
    func getNewValue() -> [UUID] {
        return self.update(self.source, insertionRatio: self.insertionRatio, deletionRatio: self.deletionRatio)
    }
}
