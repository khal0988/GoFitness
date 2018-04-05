//
//  SignUpViewController.swift
//  Go Fitness
//
//  Created by Akanksha Malik on 2018-03-21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    let profileSegueIdentifier: String = "profileSegueIdentifier"

    var dbReference: DatabaseReference?
    var dbHandle: DatabaseHandle?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self;
        self.emailTextField.delegate = self;
        self.passwordTextField.delegate = self;
        self.rePasswordTextField.delegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonDidTap(_ sender: UIButton) {
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let rePassword = rePasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if(name == ""){
            let message:String = "Please provide name"
            displayAlert(myTitle: "Error", myMessage: message)
            return
        }
        
        if(password != rePassword){
            let message:String = "Passwords don't match!"
            displayAlert(myTitle: "Error", myMessage: message)
            clearPasswords()
            return
        }
        
        // [START create_user]
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            // [START_EXCLUDE]
            if let error = error {
                print(error.localizedDescription )
                let message:String = error.localizedDescription
                self.displayAlert(myTitle: "Error", myMessage: message)
            } else {
                print("\(user!.email!) created")
                let userID = Auth.auth().currentUser!.uid
                self.dbReference = Database.database().reference()
                self.dbReference?.child("users").child(userID).child("name").setValue(name)
                self.dbReference?.child("users").child(userID).child("email").setValue(email)
                self.dbReference?.child("users").child(userID).child("password").setValue(password)
                
                // jump to profile view
                self.performSegue(withIdentifier: self.profileSegueIdentifier, sender: self)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func backgroundTap(_ sender: UIControl) {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        rePasswordTextField.resignFirstResponder()
    }
    
    @IBAction func textFieldFinishedEditing(_ sender: UITextField) {
        sender.resignFirstResponder()
    }

    private func clearFields(){
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        rePasswordTextField.text = ""
    }
    
    private func clearPasswords(){
        passwordTextField.text = ""
        rePasswordTextField.text = ""
    }
    
    private func displayAlert(myTitle: String, myMessage: String) {
        let myAlert = UIAlertController(title: myTitle, message: myMessage, preferredStyle: UIAlertControllerStyle.alert);
        myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(myAlert,animated:true,completion: nil)
    }

}
