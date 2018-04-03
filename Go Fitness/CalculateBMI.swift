//
//  CalculateBMI.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-26.
//

import UIKit

class CalculateBMI: NSObject {
    let weight: Double
    let height: Double
    
    init(weight: String, height: String) {
        self.weight = Double(weight) ?? 0.0
        self.height = Double(height) ?? 0.0
    }
    
    func calcBmi() -> Double {
        return weight / ((height / 100) * (height / 100))
    }
}
