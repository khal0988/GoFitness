//
//  Steps.swift
//  Go Fitness
//
//  Created by Johnny on 2018-04-02.
//

import UIKit
import CoreMotion

class Steps {
    
    static let sharedSteps = Steps()
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    var cal = Calendar.current
    var activityType: String = ""
    var numStepsString: String = ""
    var midnightOfToday: Date = Date()
    
    func setUp(){
        let units: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        var comps = cal.dateComponents(units, from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        
        let timeZone = TimeZone.current
        cal.timeZone = timeZone
        
        midnightOfToday = cal.date(from:comps)!
    }
    
    func startUpdating(){
        if(CMMotionActivityManager.isActivityAvailable()){
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (data: CMMotionActivity!) -> Void in
                DispatchQueue.main.async{
                    if(data.stationary == true){
                        self.activityType = "Stationary"
                    } else if (data.walking == true){
                        self.activityType = "Walking"
                    } else if (data.running == true){
                        self.activityType = "Running"
                    } else if (data.automotive == true){
                        self.activityType = "Automotive"
                    }
                }
            })
        }
        
        if(CMPedometer.isStepCountingAvailable()){
            let fromDate = Date(timeIntervalSinceNow: -86400 * 7)
            self.pedometer.queryPedometerData(from: fromDate, to: Date()) { (data : CMPedometerData!, error) -> Void in
                DispatchQueue.main.async{
                    if(error == nil){
                        self.numStepsString = data.numberOfSteps.stringValue
                    }
                }
            }
        }
        
        self.pedometer.startUpdates(from: midnightOfToday) { (data: CMPedometerData!, error) -> Void in
            DispatchQueue.main.async{
                if(error == nil){
                    self.numStepsString = data.numberOfSteps.stringValue
                }
            }
        }
    }

    func getActivityType()->String{
        return self.activityType
    }
    
    func getNumOfSteps()->String{
        return self.numStepsString
    }
}
