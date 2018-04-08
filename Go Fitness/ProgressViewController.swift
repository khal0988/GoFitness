//
//  ViewController.swift
//  Go Fitness
//
//  Created by Johnny on 2018-03-30.
//

import UIKit
import CoreMotion
import Firebase
import Charts

class ProgressViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var steps: UILabel!
    let LoginControllerIdentifier = "LoginControllerIdentifier"
    private var shouldStartUpdating: Bool = true

    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var todaysDate: UILabel!
    
    let testArray: [String] = []
    var convertedArray: [Date] = []
    var days = [String]()
    var userWeights = [Double]()
    var xAxix = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let akankshasColor = UIColor(red: CGFloat(0.053), green: CGFloat(0.069), blue: CGFloat(0.095), alpha: 1);
        self.navigationController?.navigationBar.backgroundColor = akankshasColor
        
        let calender = Calendar.current
        let month = calender.shortMonthSymbols[calender.component(.month, from: Date())-1]
        let day = String(describing: calender.component(.day, from: Date()))
        let date = month + " " + day
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MM, yyyy"// yyyy-MM-dd"
        
        todaysDate.text = date
        
        progressView.layer.borderWidth = 3.0
        progressView.layer.cornerRadius = 10.0
        let teal = UIColor(red: CGFloat(0), green: CGFloat(0.4), blue: CGFloat(0.5), alpha: 1);
        progressView.layer.borderColor = teal.cgColor

        _ = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.updateSteps), userInfo: nil, repeats: true)

        let userId = Auth.auth().currentUser?.uid
        Database.database().reference().child("weights").child(userId!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let weights = snapshot.value as? NSDictionary{
                let testArray = weights.allKeys
                for dat in testArray {
                    if let date = dateFormatter.date(from: dat as! String) {
                        self.convertedArray.append(date)
                    }
                }
                
                let ready = self.convertedArray.sorted(by: { $0.compare($1) == .orderedAscending})
                let dateFormatter1 = DateFormatter()
                
                for i in ready{
                    _ = String(describing: i)
                    let tempLocale = dateFormatter1.locale // save locale temporarily
                    dateFormatter1.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
                    let date = dateFormatter1.date(from: String(describing: i))!
                    dateFormatter1.dateFormat = "dd MMM, yyyy"
                    dateFormatter1.locale = tempLocale // reset the locale
                    let dateString = dateFormatter1.string(from: date)
                    self.days.append(dateString)
                    self.xAxix.append(String(dateString.split(separator: ",")[0]))
                }
                
                for j in self.days{
                    self.userWeights.append(weights.value(forKey: j) as! Double)
                }
            }
            
            self.lineChartView.delegate = self
            self.lineChartView.xAxis.labelPosition = .bottom
            self.lineChartView.xAxis.setLabelCount(self.days.count, force: true)
            self.lineChartView.chartDescription?.text = "Weight loss update"
            self.lineChartView.gridBackgroundColor = teal
            self.lineChartView.noDataText = "No data provided"
            self.lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:self.xAxix)
            self.setChartData(days: self.days)

        }) { (error) in
            print(error.localizedDescription)
        }

    }

    @objc private func updateSteps(){
        _ = Steps()
        state.text = Steps.sharedSteps.getActivityType()
        steps.text = Steps.sharedSteps.getNumOfSteps()
    }
    
    func setChartData(days : [String]) {
        let teal = UIColor(red: CGFloat(0), green: CGFloat(0.4), blue: CGFloat(0.5), alpha: 1);
        
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0..<days.count{
            yVals1.append(ChartDataEntry(x:Double(i) , y:userWeights[i]))
        }

        // 2 - create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(values: yVals1, label: "Weights")
        set1.axisDependency = .left // Line will correlate with left axis values
        set1.setColor(teal.withAlphaComponent(0.5)) // our line's opacity is 50%
        set1.setCircleColor(teal) // our circle will be dark red
        set1.circleRadius = 6.0 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = teal
        set1.highlightColor = UIColor.white
        set1.drawCircleHoleEnabled = true
        
        var dataSets = [IChartDataSet]()
        dataSets.append(set1)
        
        let lineChartData = LineChartData(dataSets: dataSets)
        lineChartView.data = lineChartData
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Logout", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.handleLogout()
        }))
        
        alert.addAction(UIAlertAction.init(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            print("logged out successfully")
            // jump to login view
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: LoginControllerIdentifier)
            present(loginViewController!, animated: true, completion: nil)
            
        } catch let logoutError {
            print(logoutError)
        }
    }

}
