//
//  Place.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-27.
//

import UIKit

class Place {
    private let id:String
    private let name:String
    private let address:String
    private let lat:String
    private let lng:String

    init(myId:String, myName:String, myAddress:String, myLat:String, myLng:String) {
        self.id = myId
        self.name = myName
        self.address = myAddress
        self.lat = myLat
        self.lng = myLng
    }
    
    func getID() -> String {
        return self.id
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getAddress() -> String {
        return self.address
    }
    
    func getLat() -> String {
        return self.lat
    }
    
    func getLng() -> String {
        return self.lng
    }
    
}
