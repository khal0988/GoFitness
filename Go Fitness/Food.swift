//
//  Food.swift
//  Go Fitness
//
//  Created by Johnny on 2018-04-03.
//

import UIKit

class Food {
    
    private let type:String
    private let name:String
    private let calorie:Int
    private let date:String
    
    init(myType:String, myName:String, myCalorie:Int, myDate:String) {
        self.type = myType
        self.name = myName
        self.calorie = myCalorie
        self.date = myDate

    }
    
    func getType() -> String {
        return self.type
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getCalorie() ->Int{
        return self.calorie
    }
    
    func getDate() ->String{
        return self.date
    }
}
