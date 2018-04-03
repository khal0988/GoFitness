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
        let a = Double(10 * weight)
        let b = Double(6.25 * height)
    
        if (gender == "Male"){
            let c = Double((5 * age + 5))
            result =  Int((a + b - c) * 1.3)
        }else{
            let c = Double(5 * age - 161)
            result = Int((a + b - c) * 1.3)
        }
    
        return result
    }
}
