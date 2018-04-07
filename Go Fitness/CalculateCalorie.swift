//
//  CalculateCalorie.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-26.
//

import UIKit

class CalculateCalorie: NSObject {
    let weight: Double
    let height: Double
    let age: Int
    let gender: String
    
    init(weight: String, height: String, age: String, gender: String) {
        self.weight = Double(weight) ?? 0.0
        self.height = Double(height) ?? 0.0
        self.age = Int(age) ?? 0
        self.gender = gender
    }
    
    func calcCal() -> Int {

        var result: Int
        var a: Double
        var b: Double
        var c: Double

        if (gender == "Male"){
            a = (13.7516 * weight)
            b = (5.0033 * height)
            c = (6.7550 * Double(age))
            result = Int((66.4730 + a + b - c))
        }else{
            a = (9.5634 * weight)
            b = (1.8496 * height)
            c = (4.6756 * Double(age))
            result = Int((655.0955 + a + b - c))
        }
    
        return result
    }
}
