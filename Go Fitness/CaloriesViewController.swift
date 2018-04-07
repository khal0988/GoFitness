//
//  CaloriesViewController.swift
//  Go Fitness
//
//  Created by Johnny on 2018-04-03.
//

import UIKit
import Firebase

class CaloriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var remainingTextField: UITextField!
    @IBOutlet weak var currentTextField: UITextField!
    @IBOutlet weak var goalTextField: UITextField!
    
    let LoginControllerIdentifier = "LoginControllerIdentifier"
    
    @IBOutlet weak var breakfastTableView: UITableView!
    @IBOutlet weak var lunchTableView: UITableView!
    @IBOutlet weak var dinnerTableView: UITableView!
    @IBOutlet weak var snackTableView: UITableView!
    
    @IBOutlet weak var breakfastLabelTotal: UILabel!
    @IBOutlet weak var lunchLabelTotal: UILabel!
    @IBOutlet weak var dinnerLabelTotal: UILabel!
    @IBOutlet weak var snackLabelTotal: UILabel!
    
    @IBOutlet weak var breakfastView: UIView!
    @IBOutlet weak var lunchView: UIView!
    @IBOutlet weak var dinnerView: UIView!
    @IBOutlet weak var snackView: UIView!
    
    @IBOutlet weak var remainingCaloriesView: UIView!
    
    var breakfast : [String] = []
    var lunch : [String] = []
    var dinner : [String] = []
    var snack : [String] = []
    
    var breakfastCalories : [Int] = []
    var lunchCalories : [Int] = []
    var dinnerCalories : [Int] = []
    var snackCalories : [Int] = []
    
    var dailyCalories:String = ""
    var totalCalories:Int = 0
    
    var breakfastTotal:Int = 0
    var lunchTotal:Int = 0
    var dinnerTotal:Int = 0
    var snackTotal:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let akankshasColor = UIColor(red: CGFloat(0.053), green: CGFloat(0.069), blue: CGFloat(0.095), alpha: 1);
        let cyan = UIColor(red: CGFloat(0), green: CGFloat(0.6), blue: CGFloat(0.4), alpha: 1);
        let teal = UIColor(red: CGFloat(0), green: CGFloat(0.4), blue: CGFloat(0.5), alpha: 1);
        
        self.navigationController?.navigationBar.backgroundColor = akankshasColor
        
        self.remainingCaloriesView.applyGradient(colours: [cyan, teal])
        self.breakfastView.applyGradient(colours: [cyan, teal])
        self.lunchView.applyGradient(colours: [cyan, teal])
        self.dinnerView.applyGradient(colours: [cyan, teal])
        self.snackView.applyGradient(colours: [cyan, teal])

        getDailyCalories()
        
        breakfastTableView.dataSource = self
        breakfastTableView.delegate = self
        breakfastTableView.register(UITableViewCell.self, forCellReuseIdentifier: "breakfastCell")
        
        lunchTableView.dataSource = self
        lunchTableView.delegate = self
        lunchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "lunchCell")
        
        dinnerTableView.dataSource = self
        dinnerTableView.delegate = self
        dinnerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "dinnerCell")
        
        snackTableView.dataSource = self
        snackTableView.delegate = self
        snackTableView.register(UITableViewCell.self, forCellReuseIdentifier: "snackCell")
        
        populateData()
        
        breakfastTableView.allowsSelection = false
        lunchTableView.allowsSelection = false
        dinnerTableView.allowsSelection = false
        snackTableView.allowsSelection = false
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getDailyCalories()
        
    }
    
    private func populateData(){
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMM, yyyy"
        let date = Date()
        dateFormatterGet.date(from: String(describing: date))
        
        let key: String = dateFormatterPrint.string(from: date)
        
        // get logged in user
        let userID = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("calorieCounter").child(userID!).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            
            if let calories = snapshot.value as? NSDictionary{
                for meal in calories{
                    if(meal.key as? String == "Breakfast"){
                        let myMeal = meal.value as? NSDictionary
                        self.breakfast = (myMeal?.allKeys as? [String])!
                        self.breakfastCalories = myMeal?.allValues as! [Int]
                        self.breakfastTotal = self.breakfastCalories.reduce(0, +)
                        self.breakfastLabelTotal.text = String(describing: self.breakfastTotal)
                        self.totalCalories += self.breakfastTotal
                        
                    }
                    if(meal.key as? String == "Lunch"){
                        let myMeal = meal.value as? NSDictionary
                        self.lunch = (myMeal?.allKeys as? [String])!
                        self.lunchCalories = myMeal?.allValues as! [Int]
                        self.lunchTotal = self.lunchCalories.reduce(0, +)
                        self.lunchLabelTotal.text = String(describing: self.lunchTotal)
                        self.totalCalories += self.lunchTotal
                        
                    }
                    if(meal.key as? String == "Dinner"){
                        let myMeal = meal.value as? NSDictionary
                        self.dinner = (myMeal?.allKeys as? [String])!
                        self.dinnerCalories = myMeal?.allValues as! [Int]
                        self.dinnerTotal = self.dinnerCalories.reduce(0, +)
                        self.dinnerLabelTotal.text = String(describing: self.dinnerTotal)
                        self.totalCalories += self.dinnerTotal
                        
                    }
                    if(meal.key as? String == "Snack"){
                        let myMeal = meal.value as? NSDictionary
                        self.snack = (myMeal?.allKeys as? [String])!
                        self.snackCalories = myMeal?.allValues as! [Int]
                        self.snackTotal = self.snackCalories.reduce(0, +)
                        self.snackLabelTotal.text = String(describing: self.snackTotal)
                        self.totalCalories += self.snackTotal
                        
                    }
                }
                
                self.currentTextField.text = String(describing: self.totalCalories)
                self.remainingTextField.text = String(describing: Int(self.dailyCalories)! - self.totalCalories)
                
            }
            
            // update table view
            self.breakfastTableView.reloadData()
            self.lunchTableView.reloadData()
            self.dinnerTableView.reloadData()
            self.snackTableView.reloadData()
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
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
    
    private func getDailyCalories(){
        let userID = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.dailyCalories = value?["calories"] as? String ?? ""
            self.goalTextField.text = value?["calories"] as? String ?? ""
            print("--------")
            print(self.dailyCalories)
            self.remainingTextField.text = String(describing: Int(self.dailyCalories)!  - self.totalCalories)
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        
        if tableView == self.breakfastTableView {
            count = breakfast.count
        }
        
        if tableView == self.lunchTableView {
            count =  lunch.count
        }
        
        if tableView == self.dinnerTableView {
            count =  dinner.count
        }
        
        if tableView == self.snackTableView {
            count =  snack.count
        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell?
        
        if tableView == self.breakfastTableView {
            cell = breakfastTableView?.dequeueReusableCell(withIdentifier: "breakfastCell", for: indexPath)
            
            // Configure the cell...
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "breakfastCell")
            }
            let foodName = breakfast[indexPath.row]
            cell!.textLabel?.text = foodName
            let label = UILabel.init(frame: CGRect(x:50,y:0,width:50,height:20))
            label.text = String(describing: breakfastCalories[indexPath.row])
            cell!.accessoryView = label
//            
//            cell!.layer.frame.size.height = 5
//            cell!.layer.cornerRadius = 10 //set corner radius here
//            cell!.layer.borderColor = UIColor.black.cgColor  // set cell border color here
//            cell!.layer.borderWidth = 1 // set border width here

        }
        
        if tableView == self.lunchTableView {
            cell = lunchTableView?.dequeueReusableCell(withIdentifier: "lunchCell", for: indexPath)
            // Configure the cell...
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "lunchCell")
            }
            
            let foodName = lunch[indexPath.row]
            cell!.textLabel?.text = foodName
            let label = UILabel.init(frame: CGRect(x:50,y:0,width:50,height:20))
            label.text = String(describing: lunchCalories[indexPath.row])
            cell!.accessoryView = label

        }
        
        if tableView == self.dinnerTableView {
            cell = dinnerTableView?.dequeueReusableCell(withIdentifier: "dinnerCell", for: indexPath)
            // Configure the cell...
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "dinnerCell")
            }
            let foodName = dinner[indexPath.row]
            cell!.textLabel?.text = foodName
            let label = UILabel.init(frame: CGRect(x:50,y:0,width:50,height:20))
            label.text = String(describing: dinnerCalories[indexPath.row])
            cell!.accessoryView = label

            
        }
        
        if tableView == self.snackTableView {
            cell = snackTableView?.dequeueReusableCell(withIdentifier: "snackCell", for: indexPath)
            // Configure the cell...
            if (cell == nil) {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "snackCell")
            }
            let foodName = snack[indexPath.row]
            cell!.textLabel?.text = foodName
            let label = UILabel.init(frame: CGRect(x:50,y:0,width:50,height:20))
            label.text = String(describing: snackCalories[indexPath.row])
            cell!.accessoryView = label
            
            
        }
        
        return cell!
    }
    
    @IBAction func unwindToCalorieList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddCaloriesViewController, let food = sourceViewController.getFood() {
            let foodType = food.getType()
            totalCalories += food.getCalorie()
            currentTextField.text = String(describing: totalCalories)
            remainingTextField.text = String(describing: Int(dailyCalories)! - totalCalories)
            switch (foodType) {
            case "Breakfast":
                let newIndexPath = IndexPath(row: breakfast.count, section: 0)
                breakfast.append(food.getName())
                breakfastCalories.append(food.getCalorie())
                breakfastTableView.insertRows(at: [newIndexPath], with: .automatic)
                breakfastTotal += food.getCalorie()
                breakfastLabelTotal.text = String(describing: breakfastTotal)
            case "Lunch":
                let newIndexPath = IndexPath(row: lunch.count, section: 0)
                lunch.append(food.getName())
                lunchCalories.append(food.getCalorie())
                lunchTableView.insertRows(at: [newIndexPath], with: .automatic)
                lunchTotal += food.getCalorie()
                lunchLabelTotal.text = String(describing: lunchTotal)
            case "Dinner":
                let newIndexPath = IndexPath(row: dinner.count, section: 0)
                dinner.append(food.getName())
                dinnerCalories.append(food.getCalorie())
                dinnerTableView.insertRows(at: [newIndexPath], with: .automatic)
                dinnerTotal += food.getCalorie()
                dinnerLabelTotal.text = String(describing: dinnerTotal)
            case "Snack":
                let newIndexPath = IndexPath(row: snack.count, section: 0)
                snack.append(food.getName())
                snackCalories.append(food.getCalorie())
                snackTableView.insertRows(at: [newIndexPath], with: .automatic)
                snackTotal += food.getCalorie()
                snackLabelTotal.text = String(describing: snackTotal)
                
            default:
                print("Error in unwindToCalorieList")
            }
            
            let userId = Auth.auth().currentUser?.uid
            Database.database().reference().child("calorieCounter").child(userId!).child(food.getDate()).child(foodType).child(food.getName()).setValue(food.getCalorie())
        }
    }
}
