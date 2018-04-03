//
//  RecentPlacesDeck.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-27.
//

import UIKit

class RecentPlacesDeck {
    private var recentplaces = [Place]()

    public func addPlace (newPlace:Place) {
        self.recentplaces.insert(newPlace, at: 0)
    }
    
    public func isEmpty() -> Bool {
        return self.recentplaces.count == 0;
    }
    
    public func size () -> Int {
        return self.recentplaces.count
    }
    
    public func getPlaceAt(i:Int) -> Place {
        return self.recentplaces[i]
    }
    
    func removePlaceAtIndex(index : Int) {
        self.recentplaces.remove(at: index)
    }
}
