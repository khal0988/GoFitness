//
//  CaloriesViewController.swift
//  Go Fitness
//
//  Created by Johnny on 2018-04-03.
//

import UIKit
import Firebase

class CaloriesViewController: UIViewController {

    @IBOutlet weak var remainingTextField: UITextField!
    @IBOutlet weak var currentTextField: UITextField!
    @IBOutlet weak var goalTextField: UITextField!
    let LoginControllerIdentifier = "LoginControllerIdentifier"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDailyCalories()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getDailyCalories()

        
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
            
            self.goalTextField.text = value?["calories"] as? String ?? ""
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

}
