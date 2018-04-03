//
//  ViewController.swift
//  Go Fitness
//
//  Created by Akanksha Malik on 2018-03-21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    let loginViewToProfileViewSegueIdentifier: String = "loginViewToProfileViewSegueIdentifier"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        // [START headless_email_auth]
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            // [START_EXCLUDE]
                if let error = error {
                    let message:String = error.localizedDescription
                    self.displayAlert(myTitle: "Error", myMessage: message)
                    return
                }
            print("successfully logged in")
            // jump to profile view
            self.performSegue(withIdentifier: self.loginViewToProfileViewSegueIdentifier, sender: self)
            // [END_EXCLUDE]
        }
        // [END headless_email_auth]
    }

    @IBAction func textFieldDoneEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap(_ sender: UIControl) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    private func displayAlert(myTitle: String, myMessage: String) {
        let myAlert = UIAlertController(title: myTitle, message: myMessage, preferredStyle: UIAlertControllerStyle.alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(myAlert,animated:true,completion: nil)
    }
}

