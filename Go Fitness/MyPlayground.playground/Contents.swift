//: Playground - noun: a place where people can play

import UIKit

let testArray = ["25 Jun, 2016", "30 Jun, 2016", "28 Jun, 2016", "02 Jul, 2016", "21 Jan, 2016", "31 Dec, 2019"]
var convertedArray: [Date] = []
var convertedString: [String] = []

var dateFormatter = DateFormatter()
dateFormatter.dateFormat = "dd MM, yyyy"// yyyy-MM-dd"

for dat in testArray {
    let date = dateFormatter.date(from: dat)
    if let date = date {
        convertedArray.append(date)
    }
}

var ready = convertedArray.sorted(by: { $0.compare($1) == .orderedAscending})

let dateFormatter1 = DateFormatter()


for i in ready{
    var string = String(describing: i)
    let tempLocale = dateFormatter1.locale // save locale temporarily
    dateFormatter1.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
    dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    let date = dateFormatter1.date(from: String(describing: i))!
    dateFormatter1.dateFormat = "dd MMM, yyyy"
    dateFormatter1.locale = tempLocale // reset the locale
    let dateString = dateFormatter1.string(from: date)
    convertedString.append(dateString)

}

print(convertedString)


