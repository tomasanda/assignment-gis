//
//  Double+.swift
//  FIIT-PDT-Project
//
//  Created by Tomáš Anda on 29/10/2018.
//  Copyright © 2018 FIIT-PDT. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
