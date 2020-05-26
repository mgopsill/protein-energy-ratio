//
//  World.swift
//  PERatio
//
//  Created by Mike Gopsill on 17/05/2020.
//  Copyright © 2020 mgopsill. All rights reserved.
//

import Foundation

let numberFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.allowsFloats = true
    numberFormatter.alwaysShowsDecimalSeparator = true
    numberFormatter.minimumFractionDigits = 1
    return numberFormatter
}()

extension NumberFormatter {
    func string(for float: Float) -> String {
        let number = NSNumber(value: float)
        let string = self.string(from: number)
        return string!
    }
}
